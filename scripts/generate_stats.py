#!/usr/bin/env python3
"""Generate self-hosted profile SVGs from the GitHub GraphQL API.

No third-party badge services: this hits api.github.com/graphql directly
and writes plain SVG. Run daily by .github/workflows/stats.yml.
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

STYLE = """
    text { font-family: ui-monospace, "Cascadia Code", "SFMono-Regular", Consolas, "Liberation Mono", Menlo, monospace; }
    .fg { fill: #24292f; }
    .muted { fill: #57606a; }
    .accent { fill: #0969da; }
    @media (prefers-color-scheme: dark) {
      .fg { fill: #c9d1d9; }
      .muted { fill: #8b949e; }
      .accent { fill: #58a6ff; }
    }
"""


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


def svg_wrap(width, height, body):
    return (
        f'<svg width="{width}" height="{height}" viewBox="0 0 {width} {height}" '
        f'xmlns="http://www.w3.org/2000/svg">\n<style>{STYLE}</style>\n{body}</svg>\n'
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
        ("contributions (past year)", f"{total:,}"),
        ("current streak", f"{current} day{'s' if current != 1 else ''}"),
        ("longest streak", f"{longest} day{'s' if longest != 1 else ''}"),
    ]
    lines = []
    y = 30
    for label, value in rows:
        lines.append(f'<text x="0" y="{y}" class="muted" font-size="13">{label}</text>')
        lines.append(f'<text x="440" y="{y}" class="fg" font-size="13" text-anchor="end">{value}</text>')
        y += 28
    return svg_wrap(460, y - 8, "\n".join(lines))


def make_langs_svg(nodes):
    totals = {}
    colors = {}
    for repo in nodes:
        for edge in repo["languages"]["edges"]:
            name = edge["node"]["name"]
            totals[name] = totals.get(name, 0) + edge["size"]
            colors.setdefault(name, edge["node"]["color"] or "#8b949e")
    ranked = sorted(totals.items(), key=lambda kv: kv[1], reverse=True)[:6]
    grand_total = sum(totals.values()) or 1

    lines = []
    y = 24
    bar_x = 170
    bar_w = 260
    for name, size in ranked:
        pct = size / grand_total
        lines.append(f'<text x="0" y="{y}" class="fg" font-size="13">{name}</text>')
        lines.append(
            f'<rect x="{bar_x}" y="{y - 11}" width="{bar_w}" height="12" rx="2" class="muted" '
            f'fill-opacity="0.15" stroke="none"/>'
        )
        lines.append(
            f'<rect x="{bar_x}" y="{y - 11}" width="{bar_w * pct:.1f}" height="12" rx="2" '
            f'fill="{colors[name]}"/>'
        )
        lines.append(
            f'<text x="{bar_x + bar_w + 12}" y="{y}" class="muted" font-size="12">{pct * 100:.1f}%</text>'
        )
        y += 26
    return svg_wrap(460, y - 2, "\n".join(lines))


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

    lines = [f'<text x="0" y="{16 + i * 15}" class="accent" font-size="13" xml:space="preserve" '
             f'style="letter-spacing:1px">{row}</text>' for i, row in enumerate(rows)]
    lines.append(
        f'<text x="0" y="{16 + 7 * 15 + 14}" class="muted" font-size="11">'
        f'one character per day, quiet {RAMP[1]!r} to loud {RAMP[-1]!r}</text>'
    )
    return svg_wrap(620, 16 + 7 * 15 + 26, "\n".join(lines))


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
