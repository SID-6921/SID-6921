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

rm -f /tmp/exclude_repos.txt /tmp/merged_repos.txt /tmp/open_prs_all.tsv /tmp/open_prs.tsv /tmp/oss_table.md
echo "Done."
