#!/usr/bin/env bash
# Mechanically regenerates the OSS-STATS and OSS-TABLE sections of README.md
# from live GitHub data. Does not touch the curated narrative sections above
# them. No AI involved -- pure API calls + templating. Uses only `gh` (its
# bundled --jq) so it needs no separate jq install, in CI or locally.
set -euo pipefail

USER="SID-6921"
README="README.md"

# Repos permanently excluded from the auto-generated table/stats, regardless
# of PR status (e.g. a PR the user asked not to showcase). One per line.
cat > /tmp/exclude_repos.txt <<'EXREPOS'
openai/parameter-golf
EXREPOS

echo "Fetching merged PRs for $USER (excluding own repos)..."
gh search prs --author "$USER" --merged --limit 200 \
  --json repository --jq "[.[] | select(.repository.nameWithOwner | startswith(\"$USER/\") | not)] | .[].repository.nameWithOwner" \
  | grep -vFxf /tmp/exclude_repos.txt > /tmp/merged_repos.txt || true

merged_count=$(wc -l < /tmp/merged_repos.txt | tr -d ' ')
contributor_repo_count=$(sort -u /tmp/merged_repos.txt | wc -l | tr -d ' ')

echo "Fetching open PRs for $USER (excluding own repos)..."
gh search prs --author "$USER" --state open --limit 100 \
  --json repository,number,title \
  --jq "[.[] | select(.repository.nameWithOwner | startswith(\"$USER/\") | not)] | .[] | [.repository.nameWithOwner, (.number|tostring), .title] | @tsv" \
  > /tmp/open_prs_all.tsv

awk -F'\t' 'NR==FNR{ex[$1]=1; next} !($1 in ex)' /tmp/exclude_repos.txt /tmp/open_prs_all.tsv > /tmp/open_prs.tsv

open_count=$(wc -l < /tmp/open_prs.tsv | tr -d ' ')

echo "merged=$merged_count open=$open_count contributor_repos=$contributor_repo_count"

# --- Find which contributor repos are actually trending ---
# "Trending" means real star growth since the last recorded run, not just
# whichever repo happens to have the most stars overall (a repo can be huge
# and flat). Growth is tracked in a small snapshot file committed alongside
# the README, so each run compares against yesterday's real numbers -- no
# fabricated trend, and an honest "no history yet" on the very first run.
# Every repo's delta (not just the biggest mover) is dumped to
# /tmp/star_deltas.json so the per-heading badges further down can tag any
# repo that grew, computed once here rather than re-derived twice.
SNAPSHOT="scripts/.star_snapshot.json"
echo "Computing star deltas since the last snapshot..."

declare -A current_stars
for repo in $(sort -u /tmp/merged_repos.txt); do
  current_stars[$repo]=$(gh api "repos/$repo" --jq '.stargazers_count' 2>/dev/null || echo 0)
done

have_history=0
[[ -f "$SNAPSHOT" ]] && have_history=1

python3 - "$SNAPSHOT" /tmp/star_deltas.json /tmp/top_trend.txt <<PYEOF
import json

current = {
$(for r in "${!current_stars[@]}"; do printf '  "%s": %s,\n' "$r" "${current_stars[$r]}"; done)
}

import sys
snapshot_path, deltas_path, top_path = sys.argv[1], sys.argv[2], sys.argv[3]

try:
    with open(snapshot_path, encoding="utf-8") as fh:
        previous = json.load(fh)
except FileNotFoundError:
    previous = {}

deltas = {repo: current[repo] - previous.get(repo, current[repo]) for repo in current}

with open(snapshot_path, "w", encoding="utf-8") as fh:
    json.dump(current, fh, indent=2, sort_keys=True)
    fh.write("\n")

with open(deltas_path, "w", encoding="utf-8") as fh:
    json.dump(deltas, fh)

top_repo, top_delta = max(deltas.items(), key=lambda kv: kv[1]) if deltas else (None, 0)
with open(top_path, "w", encoding="utf-8", newline="") as fh:
    if top_repo and top_delta > 0:
        fh.write(f"{top_repo}\t{top_delta}\t{current[top_repo]}\n")
PYEOF

fmt_k() { local n=$1; if (( n >= 1000 )); then awk -v s="$n" 'BEGIN{printf "%.1fk", s/1000}'; else echo "$n"; fi; }

if [[ -s /tmp/top_trend.txt ]]; then
  IFS=$'\t' read -r top_repo top_delta top_stars_now < /tmp/top_trend.txt
  featured_line="📈 **Trending this run:** [$top_repo](https://github.com/$top_repo) gained +${top_delta} ⭐ since the last check (now $(fmt_k "$top_stars_now") ⭐ total). Recomputed daily from a real snapshot, not a guess."
elif (( have_history == 1 )); then
  featured_line="📈 **Trending this run:** no repo in the list gained stars since the last check. Nothing to feature today, that's the honest answer."
else
  featured_line="📈 **Trending:** first run with star tracking, no history to compare against yet. Check back after tomorrow's update for a real delta."
fi

python3 - "$README" "$featured_line" <<'PYEOF'
import re, sys
path, line = sys.argv[1], sys.argv[2]
text = open(path, encoding="utf-8").read()
if "<!-- FEATURED-REPO:START -->" in text:
    text = re.sub(
        r"(<!-- FEATURED-REPO:START -->\n).*?(\n<!-- FEATURED-REPO:END -->)",
        lambda m: m.group(1) + line + m.group(2),
        text,
        flags=re.S,
    )
else:
    text = re.sub(
        r"(### Contributor repos \(merged\)\n)",
        lambda m: "<!-- FEATURED-REPO:START -->\n" + line + "\n<!-- FEATURED-REPO:END -->\n\n" + m.group(1),
        text,
        count=1,
    )
open(path, "w", encoding="utf-8").write(text)
PYEOF

# --- Regenerate stats line ---
stats_line="**Snapshot:** ${contributor_repo_count} repos where I am a credited contributor (merged commits) plus 1 co-authored credit (not reflected in the count above -- see below) · ${merged_count} merged PRs · ~${open_count} open PRs under review."

python3 - "$README" "$stats_line" <<'PYEOF'
import re, sys
path, new_line = sys.argv[1], sys.argv[2]
text = open(path, encoding="utf-8").read()
text = re.sub(
    r"(<!-- OSS-STATS:START -->\n).*?(\n<!-- OSS-STATS:END -->)",
    lambda m: m.group(1) + new_line + m.group(2),
    text,
    flags=re.S,
)
open(path, "w", encoding="utf-8").write(text)
PYEOF

# --- Regenerate the "Under review" table ---
# One row per open external PR: repo, stars (cached per repo to avoid rate limits), PR link, PR title.
rows=""
declare -A star_cache
while IFS=$'\t' read -r repo number title; do
  [[ -z "$repo" ]] && continue
  if [[ -z "${star_cache[$repo]:-}" ]]; then
    stars=$(gh api "repos/$repo" --jq '.stargazers_count' 2>/dev/null || echo 0)
    if (( stars >= 1000 )); then
      star_cache[$repo]=$(awk -v s="$stars" 'BEGIN{printf "%.1fk", s/1000}')
    else
      star_cache[$repo]=$stars
    fi
  fi
  rows+="| [$repo](https://github.com/$repo) | ${star_cache[$repo]} | [#$number](https://github.com/$repo/pull/$number) | $title |"$'\n'
done < /tmp/open_prs.tsv

{
  printf '| Repo | Stars | PR | What it fixes |\n'
  printf '|---|---|---|---|\n'
  printf '%s' "$rows"
} > /tmp/oss_table.md

python3 - "$README" /tmp/oss_table.md <<'PYEOF'
import re, sys
path, table_path = sys.argv[1], sys.argv[2]
table = open(table_path, encoding="utf-8").read().strip()
text = open(path, encoding="utf-8").read()
text = re.sub(
    r"(<!-- OSS-TABLE:START -->\n).*?(\n<!-- OSS-TABLE:END -->)",
    lambda m: m.group(1) + table + m.group(2),
    text,
    flags=re.S,
)
open(path, "w", encoding="utf-8").write(text)
PYEOF

# --- Generate the "#1 in this list" seal and find who currently wears it ---
# Based on absolute star count right now, so it's always true today -- not
# dependent on day-to-day growth like the 🔥 trending badges below, which
# can legitimately show nothing on a quiet day. This one always has an
# answer. Recomputed every run: if a bigger repo joins the list, the seal
# moves to it automatically.
echo "Generating the top-repo seal badge..."
python3 scripts/generate_top_badge.py

biggest_repo=""
biggest_stars=-1
for repo in "${!current_stars[@]}"; do
  if (( current_stars[$repo] > biggest_stars )); then
    biggest_stars=${current_stars[$repo]}
    biggest_repo=$repo
  fi
done
echo "Biggest repo right now: $biggest_repo ($biggest_stars stars)"

# --- Refresh the inline star count + trending badge on each repo heading ---
# These lines look like: #### 🥇 [OWNER/REPO](url) ⭐ 8.3k 🔥 +12 today — description
# Re-fetch each repo's current star count via the API, tag it with a
# "🔥 +N today" badge if /tmp/star_deltas.json shows it actually grew since
# the last run (any repo that grew gets tagged here, not just the single
# biggest mover called out in the FEATURED-REPO line above), and give the
# single biggest-by-size repo the seal image. A repo with no growth/no
# longer the biggest loses its badge/seal cleanly -- both are matched and
# replaced each run, not just appended, so re-runs can't pile up duplicates.
python3 - "$README" /tmp/star_deltas.json "$biggest_repo" <<'PYEOF'
import json, re, subprocess, sys

path, deltas_path, biggest_repo = sys.argv[1], sys.argv[2], sys.argv[3]
text = open(path, encoding="utf-8").read()

try:
    with open(deltas_path, encoding="utf-8") as fh:
        deltas = json.load(fh)
except FileNotFoundError:
    deltas = {}

def fmt_stars(n):
    return f"{n/1000:.1f}k" if n >= 1000 else str(n)

def refresh(m):
    owner_repo = m.group("repo")
    try:
        out = subprocess.run(
            ["gh", "api", f"repos/{owner_repo}", "--jq", ".stargazers_count"],
            capture_output=True, text=True, check=True,
        )
        stars = fmt_stars(int(out.stdout.strip()))
    except Exception:
        stars = m.group("stars")  # leave unchanged on any API hiccup

    delta = deltas.get(owner_repo, 0)
    badge = f" 🔥 +{delta} today" if delta > 0 else ""
    seal = '<img src="svg/top-repo-badge.svg" width="26" align="absmiddle" alt="#1 by stars"/> ' if owner_repo == biggest_repo else ""
    heading = m.group("heading")
    return f"#### {seal}{heading}{stars}{badge}{m.group('suffix')}"

pattern = re.compile(
    r"^#### "
    r"(?:<img src=\"svg/top-repo-badge\.svg\"[^>]*/> )?"  # consume a stale seal, if present
    r"(?P<heading>\[[^\]]+\]\(https://github\.com/(?P<repo>[^)]+)\) ⭐ )"
    r"(?P<stars>[\d.,]+k?)"
    r"(?: 🔥 \+\d+ today)?"  # consume a stale trending badge, if present
    r"(?P<suffix>(?= |$))",
    re.MULTILINE,
)
text = pattern.sub(refresh, text)
open(path, "w", encoding="utf-8").write(text)
PYEOF

# --- Cumulative stars across every repo I'm a credited contributor to ---
# Sums stargazers_count for the unique repos in merged_repos.txt (same list
# that drives contributor_repo_count above), so it's always the same set.
echo "Summing stars across contributor repos..."
total_stars=0
for repo in $(sort -u /tmp/merged_repos.txt); do
  s=$(gh api "repos/$repo" --jq '.stargazers_count' 2>/dev/null || echo 0)
  total_stars=$((total_stars + s))
done
if (( total_stars >= 1000 )); then
  total_stars_fmt=$(awk -v s="$total_stars" 'BEGIN{printf "%.1fk", s/1000}')
else
  total_stars_fmt="$total_stars"
fi
stars_line="**${total_stars_fmt} combined stars** across the ${contributor_repo_count} repos above (sum of each repo's current count, not a dedup of my own contribution)."

python3 - "$README" "$stars_line" <<'PYEOF'
import re, sys
path, line = sys.argv[1], sys.argv[2]
text = open(path, encoding="utf-8").read()
if "<!-- CUMULATIVE-STARS:START -->" in text:
    text = re.sub(
        r"(<!-- CUMULATIVE-STARS:START -->\n).*?(\n<!-- CUMULATIVE-STARS:END -->)",
        lambda m: m.group(1) + line + m.group(2),
        text,
        flags=re.S,
    )
else:
    text = text.rstrip("\n") + (
        "\n\n<!-- CUMULATIVE-STARS:START -->\n" + line + "\n<!-- CUMULATIVE-STARS:END -->\n"
    )
open(path, "w", encoding="utf-8").write(text)
PYEOF

# --- Stamp the last-run time ---
# Human-readable + explicit UTC so "when does this update" is never a guess.
last_updated="This page refreshes automatically every day around 13:00 UTC (1:00 PM UTC) via GitHub Actions. Last run: $(date -u '+%Y-%m-%d %H:%M UTC')."

python3 - "$README" "$last_updated" <<'PYEOF'
import re, sys
path, line = sys.argv[1], sys.argv[2]
text = open(path, encoding="utf-8").read()
if "<!-- LAST-UPDATED:START -->" in text:
    text = re.sub(
        r"(<!-- LAST-UPDATED:START -->\n).*?(\n<!-- LAST-UPDATED:END -->)",
        lambda m: m.group(1) + line + m.group(2),
        text,
        flags=re.S,
    )
else:
    text = text.rstrip("\n") + (
        "\n\n---\n\n<!-- LAST-UPDATED:START -->\n" + line + "\n<!-- LAST-UPDATED:END -->\n"
    )
open(path, "w", encoding="utf-8").write(text)
PYEOF

# --- Regenerate the organizations badge row ---
# One avatar per distinct owner across merged-PR repos, linking to that
# owner's GitHub page. Reuses merged_repos.txt rather than a second API call.
orgs=$(sort -u /tmp/merged_repos.txt | cut -d/ -f1 | sort -u)
org_count=$(echo "$orgs" | wc -l | tr -d ' ')

org_row=""
while read -r org; do
  [[ -z "$org" ]] && continue
  org_row+="<a href=\"https://github.com/$org\" title=\"$org\"><img src=\"https://github.com/$org.png\" width=\"44\" height=\"44\" style=\"border-radius:50%;margin:0 4px\" alt=\"$org\"/></a> "
done <<< "$orgs"

{
  printf '**%s organizations, %s repos.**\n\n' "$org_count" "$contributor_repo_count"
  printf '<p>%s</p>\n' "$org_row"
} > /tmp/orgs_block.md

python3 - "$README" /tmp/orgs_block.md <<'PYEOF'
import re, sys
path, block_path = sys.argv[1], sys.argv[2]
block = open(block_path, encoding="utf-8").read().strip()
text = open(path, encoding="utf-8").read()
if "<!-- OSS-ORGS:START -->" in text:
    text = re.sub(
        r"(<!-- OSS-ORGS:START -->\n).*?(\n<!-- OSS-ORGS:END -->)",
        lambda m: m.group(1) + block + m.group(2),
        text,
        flags=re.S,
    )
else:
    text = re.sub(
        r"(\n## Contact\n)",
        lambda m: (
            "\n### Organizations\n\n"
            "Owners of the repos above where a PR has actually merged, tagged rather than just named.\n\n"
            "<!-- OSS-ORGS:START -->\n" + block + "\n<!-- OSS-ORGS:END -->\n"
            + m.group(1)
        ),
        text,
        count=1,
    )
open(path, "w", encoding="utf-8").write(text)
PYEOF

rm -f /tmp/exclude_repos.txt /tmp/merged_repos.txt /tmp/open_prs_all.tsv /tmp/open_prs.tsv /tmp/oss_table.md /tmp/orgs_block.md /tmp/star_deltas.json /tmp/top_trend.txt
echo "Done."
