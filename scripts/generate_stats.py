#!/usr/bin/env python3
"""Generate self-hosted profile SVGs from the GitHub GraphQL API.

No third-party badge services: this hits api.github.com/graphql directly
and writes plain SVG. Run daily by .github/workflows/stats.yml.

Cards render as an opaque dark panel rather than adapting to
prefers-color-scheme: that CSS feature tracks the OS/browser setting, not
GitHub's own light/dark theme toggle, so a theme-adaptive SVG goes invisible
(dark-on-dark) for anyone whose GitHub theme and OS theme disagree. A fixed
dark card is legible on both of GitHub's page themes, always.
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

BG = "#0d1117"
BORDER = "#30363d"
FG = "#e6edf3"
MUTED = "#8b949e"
ACCENT = "#58a6ff"
PAD = 20

STYLE = (
    'text { font-family: ui-monospace, "Cascadia Code", "SFMono-Regular", '
    "Consolas, \"Liberation Mono\", Menlo, monospace; }"
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


def card(width, height, title, body):
    return (
        f'<svg width="{width}" height="{height}" viewBox="0 0 {width} {height}" '
        f'xmlns="http://www.w3.org/2000/svg">\n<style>{STYLE}</style>\n'
        f'<rect x="0.5" y="0.5" width="{width - 1}" height="{height - 1}" rx="10" '
        f'fill="{BG}" stroke="{BORDER}"/>\n'
        f'<text x="{PAD}" y="{PAD + 4}" fill="{ACCENT}" font-size="11" '
        f'letter-spacing="2" font-weight="bold">{title}</text>\n'
        f"{body}</svg>\n"
    )


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


def make_stats_svg(total, current, longest):
    rows = [
        ("contributions, past year", f"{total:,}"),
        ("current streak", f"{current} day{'s' if current != 1 else ''}"),
        ("longest streak", f"{longest} day{'s' if longest != 1 else ''}"),
    ]
    width = 460
    lines = []
    y = PAD + 34
    for label, value in rows:
        lines.append(f'<text x="{PAD}" y="{y}" fill="{MUTED}" font-size="13">{label}</text>')
        lines.append(
            f'<text x="{width - PAD}" y="{y}" fill="{FG}" font-size="13" '
            f'text-anchor="end">{value}</text>'
        )
        y += 26
    return card(width, y + PAD - 26 + 6, "CONTRIBUTIONS", "\n".join(lines))


def make_langs_svg(nodes):
    totals = {}
    colors = {}
    for repo in nodes:
        for edge in repo["languages"]["edges"]:
            name = edge["node"]["name"]
            totals[name] = totals.get(name, 0) + edge["size"]
            colors.setdefault(name, edge["node"]["color"] or MUTED)
    ranked = sorted(totals.items(), key=lambda kv: kv[1], reverse=True)[:6]
    grand_total = sum(totals.values()) or 1

    width = 460
    bar_x = PAD + 150
    bar_w = width - bar_x - PAD - 46
    lines = []
    y = PAD + 34
    for name, size in ranked:
        pct = size / grand_total
        lines.append(f'<text x="{PAD}" y="{y}" fill="{FG}" font-size="13">{name}</text>')
        lines.append(
            f'<rect x="{bar_x}" y="{y - 11}" width="{bar_w}" height="10" rx="2" '
            f'fill="{MUTED}" fill-opacity="0.25"/>'
        )
        lines.append(
            f'<rect x="{bar_x}" y="{y - 11}" width="{bar_w * pct:.1f}" height="10" rx="2" '
            f'fill="{colors[name]}"/>'
        )
        lines.append(
            f'<text x="{width - PAD}" y="{y}" fill="{MUTED}" font-size="12" '
            f'text-anchor="end">{pct * 100:.1f}%</text>'
        )
        y += 24
    return card(width, y + PAD - 24 + 6, "TOP LANGUAGES", "\n".join(lines))


RAMP = " :+#@"


def ramp_char(count, day_max):
    if count <= 0 or day_max <= 0:
        return RAMP[0]
    frac = count / day_max
    idx = min(len(RAMP) - 1, 1 + int(frac * (len(RAMP) - 2)))
    return RAMP[idx]


def make_year_svg(weeks):
    day_max = max((d["contributionCount"] for w in weeks for d in w["contributionDays"]), default=0)
    rows = []
    for row in range(7):
        chars = []
        for week in weeks:
            days = week["contributionDays"]
            chars.append(ramp_char(days[row]["contributionCount"], day_max) if row < len(days) else " ")
        rows.append("".join(chars))

    width = 620
    top = PAD + 30
    lines = [
        f'<text x="{PAD}" y="{top + i * 15}" fill="{ACCENT}" font-size="13" '
        f'xml:space="preserve" style="letter-spacing:1px">{row}</text>'
        for i, row in enumerate(rows)
    ]
    footer_y = top + 7 * 15 + 12
    lines.append(
        f'<text x="{PAD}" y="{footer_y}" fill="{MUTED}" font-size="11">'
        f"one character per day, quiet {RAMP[1]!r} to loud {RAMP[-1]!r}</text>"
    )
    return card(width, footer_y + PAD - 4, "THE LAST YEAR", "\n".join(lines))


def main():
    data = gh_graphql(QUERY, {"login": LOGIN})
    user = data["user"]
    calendar = user["contributionsCollection"]["contributionCalendar"]
    weeks = calendar["weeks"]
    all_days = [d for w in weeks for d in w["contributionDays"]]
    current, longest = compute_streaks(all_days)

    os.makedirs(OUT_DIR, exist_ok=True)
    outputs = {
        "stats.svg": make_stats_svg(calendar["totalContributions"], current, longest),
        "langs.svg": make_langs_svg(user["repositories"]["nodes"]),
        "year.svg": make_year_svg(weeks),
    }
    for name, svg in outputs.items():
        path = os.path.join(OUT_DIR, name)
        with open(path, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(svg)
        print(f"wrote {path}")


if __name__ == "__main__":
    sys.exit(main())
