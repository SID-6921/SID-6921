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

# --- Find the single highest-starred repo in the contributor list ---
# Recomputed from live data every run, so "featured" means "biggest right
# now," not a number typed in once and left to go stale.
echo "Finding the highest-starred contributor repo..."
top_repo=""
top_stars=-1
for repo in $(sort -u /tmp/merged_repos.txt); do
  s=$(gh api "repos/$repo" --jq '.stargazers_count' 2>/dev/null || echo 0)
  if (( s > top_stars )); then
    top_stars=$s
    top_repo=$repo
  fi
done
if (( top_stars >= 1000 )); then
  top_stars_fmt=$(awk -v s="$top_stars" 'BEGIN{printf "%.1fk", s/1000}')
else
  top_stars_fmt="$top_stars"
fi
featured_line="🏆 **Biggest repo in this list right now:** [$top_repo](https://github.com/$top_repo) — ${top_stars_fmt} ⭐ (recomputed daily, so this moves if a bigger repo joins the list or the ranking shifts)."

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

# --- Refresh the inline star count on each "Contributor repos" heading ---
# These lines look like: #### [OWNER/REPO](url) ⭐ 8.3k — description
# Re-fetch each repo's current star count via the API and rewrite just the
# number, leaving the rest of the (manually curated) line untouched.
python3 - "$README" <<'PYEOF'
import re, subprocess, sys

path = sys.argv[1]
text = open(path, encoding="utf-8").read()

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
    return f"{m.group('prefix')}{stars}{m.group('suffix')}"

pattern = re.compile(
    r"(?P<prefix>^#### \[[^\]]+\]\(https://github\.com/(?P<repo>[^)]+)\) ⭐ )"
    r"(?P<stars>[\d.,]+k?)"
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

rm -f /tmp/exclude_repos.txt /tmp/merged_repos.txt /tmp/open_prs_all.tsv /tmp/open_prs.tsv /tmp/oss_table.md
echo "Done."
