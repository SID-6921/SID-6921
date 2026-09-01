#!/usr/bin/env python3
"""Generate a self-hosted profile stats card from the GitHub GraphQL API.

No third-party badge services: this hits api.github.com/graphql directly
and writes one plain SVG. Run daily by .github/workflows/stats.yml.

Everything lives in a single SVG (one <img> tag in the README) so there is
one coordinate system to reason about instead of three images that have to
stack correctly in GitHub's markdown flow. The card has its own opaque dark
background rather than adapting to prefers-color-scheme: that CSS feature
tracks the OS/browser setting, not GitHub's own theme toggle, so a
theme-adaptive SVG can render invisible (dark-on-dark) when the two
disagree. A fixed dark card is legible on both of GitHub's page themes.
"""
import json
import os
import sys
import urllib.request
from datetime import date

LOGIN = os.environ.get("PROFILE_LOGIN", "SID-6921")
TOKEN = os.environ["GH_TOKEN"]
OUT_DIR = os.environ.get("OUT_DIR", "svg")

QUERY = """
query($login: String!) {
  user(login: $login) {
    contributionsCollection {
      contributionCalendar {
        totalContributions
        weeks {
          contributionDays { date contributionCount }
        }
      }
    }
    repositories(first: 100, ownerAffiliations: OWNER, isFork: false, privacy: PUBLIC) {
      nodes {
        languages(first: 10, orderBy: {field: SIZE, direction: DESC}) {
          edges { size node { name color } }
        }
      }
    }
  }
}
"""

WIDTH = 620
PAD = 24
ROW_H = 24

BG = "#0d1117"
BORDER = "#30363d"
FG = "#e6edf3"
MUTED = "#8b949e"
ACCENT = "#58a6ff"

FONT = (
    'ui-monospace, "Cascadia Code", "SFMono-Regular", Consolas, '
    '"Liberation Mono", Menlo, monospace'
)


def gh_graphql(query, variables):
    body = json.dumps({"query": query, "variables": variables}).encode()
    req = urllib.request.Request(
        "https://api.github.com/graphql",
        data=body,
        headers={
            "Authorization": f"bearer {TOKEN}",
            "Content-Type": "application/json",
            "User-Agent": LOGIN,
        },
    )
    with urllib.request.urlopen(req, timeout=30) as resp:
        payload = json.load(resp)
    if "errors" in payload:
        raise RuntimeError(payload["errors"])
    return payload["data"]


def esc(text):
    return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def truncate(name, max_chars=17):
    return name if len(name) <= max_chars else name[: max_chars - 1] + "…"


def compute_streaks(days):
    counts = [d["contributionCount"] for d in days]
    today_str = date.today().isoformat()
    i = len(counts) - 1
    if days[i]["date"] == today_str and counts[i] == 0:
        i -= 1
    current = 0
    while i >= 0 and counts[i] > 0:
        current += 1
        i -= 1
    longest = running = 0
    for c in counts:
        running = running + 1 if c > 0 else 0
        longest = max(longest, running)
    return current, longest


def section_title(y, label):
    return (
        f'<text x="{PAD}" y="{y}" fill="{ACCENT}" font-size="11" '
        f'letter-spacing="2" font-weight="bold">{label}</text>'
    )


def divider(y):
    return f'<line x1="{PAD}" y1="{y}" x2="{WIDTH - PAD}" y2="{y}" stroke="{BORDER}"/>'


RAMP = " :+#@"


def ramp_char(count, day_max):
    if count <= 0 or day_max <= 0:
        return RAMP[0]
    frac = count / day_max
    idx = min(len(RAMP) - 1, 1 + int(frac * (len(RAMP) - 2)))
    return RAMP[idx]


def build_card(total, current, longest, lang_nodes, weeks):
    parts = []
    y = PAD + 4

    # --- contributions ---------------------------------------------------
    parts.append(section_title(y, "CONTRIBUTIONS"))
    y += 30
    rows = [
        ("contributions, past year", f"{total:,}"),
        ("current streak", f"{current} day{'s' if current != 1 else ''}"),
        ("longest streak", f"{longest} day{'s' if longest != 1 else ''}"),
    ]
    for label, value in rows:
        parts.append(f'<text x="{PAD}" y="{y}" fill="{MUTED}" font-size="13">{label}</text>')
        parts.append(
            f'<text x="{WIDTH - PAD}" y="{y}" fill="{FG}" font-size="13" '
            f'text-anchor="end">{value}</text>'
        )
        y += ROW_H

    y += 12
    parts.append(divider(y))
    y += 30

    # --- languages ---------------------------------------------------------
    totals, colors = {}, {}
    for repo in lang_nodes:
        for edge in repo["languages"]["edges"]:
            name = edge["node"]["name"]
            totals[name] = totals.get(name, 0) + edge["size"]
            colors.setdefault(name, edge["node"]["color"] or MUTED)
    ranked = sorted(totals.items(), key=lambda kv: kv[1], reverse=True)[:6]
    grand_total = sum(totals.values()) or 1

    parts.append(section_title(y, "TOP LANGUAGES"))
    y += 30
    name_col_w = 180
    pct_col_w = 50
    bar_x = PAD + name_col_w
    bar_w = WIDTH - bar_x - PAD - pct_col_w
    for name, size in ranked:
        pct = size / grand_total
        parts.append(f'<text x="{PAD}" y="{y}" fill="{FG}" font-size="13">{esc(truncate(name))}</text>')
        parts.append(
            f'<rect x="{bar_x}" y="{y - 11}" width="{bar_w}" height="10" rx="2" '
            f'fill="{MUTED}" fill-opacity="0.25"/>'
        )
        parts.append(
            f'<rect x="{bar_x}" y="{y - 11}" width="{max(bar_w * pct, 2):.1f}" height="10" rx="2" '
            f'fill="{colors[name]}"/>'
        )
        parts.append(
            f'<text x="{WIDTH - PAD}" y="{y}" fill="{MUTED}" font-size="12" '
            f'text-anchor="end">{pct * 100:.1f}%</text>'
        )
        y += ROW_H

    y += 12
    parts.append(divider(y))
    y += 30

    # --- last year heatmap ---------------------------------------------------
    parts.append(section_title(y, "THE LAST YEAR"))
    y += 26
    day_max = max((d["contributionCount"] for w in weeks for d in w["contributionDays"]), default=0)
    for row in range(7):
        chars = []
        for week in weeks:
            days = week["contributionDays"]
            chars.append(ramp_char(days[row]["contributionCount"], day_max) if row < len(days) else " ")
        parts.append(
            f'<text x="{PAD}" y="{y}" fill="{ACCENT}" font-size="13" xml:space="preserve" '
            f'style="letter-spacing:1px">{"".join(chars)}</text>'
        )
        y += 15
    y += 8
    parts.append(
        f'<text x="{PAD}" y="{y}" fill="{MUTED}" font-size="11">'
        f"one character per day, quiet {RAMP[1]!r} to loud {RAMP[-1]!r}</text>"
    )
    y += PAD - 4

    height = y
    body = "\n".join(parts)
    return (
        f'<svg width="{WIDTH}" height="{height}" viewBox="0 0 {WIDTH} {height}" '
        f'xmlns="http://www.w3.org/2000/svg">\n'
        f"<style>text {{ font-family: {FONT}; }}</style>\n"
        f'<rect x="0.5" y="0.5" width="{WIDTH - 1}" height="{height - 1}" rx="10" '
        f'fill="{BG}" stroke="{BORDER}"/>\n'
        f"{body}</svg>\n"
    )


def main():
    data = gh_graphql(QUERY, {"login": LOGIN})
    user = data["user"]
    calendar = user["contributionsCollection"]["contributionCalendar"]
    weeks = calendar["weeks"]
    all_days = [d for w in weeks for d in w["contributionDays"]]
    current, longest = compute_streaks(all_days)

    svg = build_card(
        calendar["totalContributions"], current, longest, user["repositories"]["nodes"], weeks
    )

    os.makedirs(OUT_DIR, exist_ok=True)
    path = os.path.join(OUT_DIR, "card.svg")
    with open(path, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(svg)
    print(f"wrote {path}")

    for stale in ("stats.svg", "langs.svg", "year.svg"):
        stale_path = os.path.join(OUT_DIR, stale)
        if os.path.exists(stale_path):
            os.remove(stale_path)
            print(f"removed {stale_path}")


if __name__ == "__main__":
    sys.exit(main())
