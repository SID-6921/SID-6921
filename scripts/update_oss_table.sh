#!/usr/bin/env bash
# Mechanically regenerates the OSS-STATS and OSS-TABLE sections of README.md
# from live GitHub data -- pure API calls + templating, no AI involved there.
# Uses only `gh` (its bundled --jq) so it needs no separate jq install, in CI
# or locally. The one exception: a newly-merged repo with no narrative
# write-up yet gets one drafted by Claude (see below), grounded only in the
# real PR data fetched via `gh` -- that's the only step in this script that
# calls an LLM.
set -euo pipefail

USER="SID-6921"
README="README.md"

fmt_k() { local n=$1; if (( n >= 1000 )); then awk -v s="$n" 'BEGIN{printf "%.1fk", s/1000}'; else echo "$n"; fi; }

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

# --- Detect newly-merged repos with no narrative write-up yet ---
# A repo counts as "documented" once it has a "#### [owner/repo]" heading
# somewhere between "### Contributor repos (merged)" and "### Under review".
# Anything merged but missing that heading gets a write-up drafted below by
# Claude (ANTHROPIC_API_KEY), grounded only in the real PR title/body/stars
# fetched via `gh` -- no invented detail. Auto-merged like everything else
# in this script; there is no human review step for this part.
echo "Checking for newly-merged repos with no narrative write-up..."
python3 - "$README" /tmp/merged_repos.txt /tmp/new_repos.txt <<'PYEOF'
import re, sys
readme_path, merged_path, out_path = sys.argv[1], sys.argv[2], sys.argv[3]
text = open(readme_path, encoding="utf-8").read()
# Scans both the "Contributor repos (merged)" and "Co-authored credit"
# sections -- a repo documented in either one counts as covered, so a
# co-authored-only credit (no contributor-graph avatar) isn't re-flagged.
section = re.search(r"### Contributor repos \(merged\)\n(.*?)\n### Under review", text, re.S)
documented = set(re.findall(r"^#### \[([^\]]+)\]", section.group(1), re.M)) if section else set()
with open(merged_path, encoding="utf-8") as fh:
    merged = sorted(set(line.strip() for line in fh if line.strip()))
new_repos = [r for r in merged if r not in documented]
with open(out_path, "w", encoding="utf-8") as fh:
    fh.write("\n".join(new_repos))
PYEOF

if [[ -s /tmp/new_repos.txt ]]; then
  echo "New repos with no write-up yet:"
  cat /tmp/new_repos.txt
  draft_stubs=""
  while IFS= read -r repo; do
    [[ -z "$repo" ]] && continue
    stars=$(gh api "repos/$repo" --jq '.stargazers_count' 2>/dev/null || echo 0)
    stars_fmt=$(fmt_k "$stars")
    desc=$(gh api "repos/$repo" --jq '.description // ""' 2>/dev/null || echo "")
    gh search prs --author "$USER" --merged --repo "$repo" --limit 10 \
      --json number,title,url,body > /tmp/repo_prs.json 2>/dev/null || echo "[]" > /tmp/repo_prs.json

    heading="#### [$repo](https://github.com/$repo) ⭐ ${stars_fmt} — ${desc}"
    body=$(python3 - "$repo" "$stars_fmt" "$desc" /tmp/repo_prs.json <<'PYEOF'
# Drafts the "merged: ..." line plus Impact/Severity bullets for one repo,
# grounded only in the real PR number/title/body/stars passed in -- same
# style as the human-written entries above it in README.md. Returns plain
# markdown on stdout; no heading line (the caller already has that).
import json, os, sys, urllib.request

repo, stars_fmt, desc, prs_path = sys.argv[1:5]
with open(prs_path, encoding="utf-8") as fh:
    prs = json.load(fh)

pr_text = "\n\n".join(
    f"PR #{pr['number']} ({pr['url']})\nTitle: {pr['title']}\nBody:\n{pr.get('body') or '(no description)'}"
    for pr in prs
) or "(no merged PR data available)"

prompt = f"""Draft one entry for a GitHub profile README's "Contributor repos (merged)" list, in the exact style of these existing entries:

#### [nipy/nibabel](https://github.com/nipy/nibabel) ⭐ 810 — neuroimaging I/O library
2 merged PRs: [#1553](https://github.com/nipy/nibabel/pull/1553) generalized `rescale_affine()` to non-4x4 affines (hardcoded to `affine[:3,:3]` despite being documented for arbitrary `(N,N)`); [#1562](https://github.com/nipy/nibabel/pull/1562) added shape validation to `Nifti1Header.set_sform`.
- **Impact:** #1553 fixed a function that raised on any non-square-4 input despite its own docstring promising general support -- a docs/implementation contract break.
- **Severity:** 3/5 -- a hard crash on documented-valid input, but only for users already outside the common 4x4-affine case.

#### [neuralinkcorp/datarepo](https://github.com/neuralinkcorp/datarepo) ⭐ 208 — data-table/query library
2 merged PRs, both first-pass clean: [#75](https://github.com/neuralinkcorp/datarepo/pull/75) added missing `is null`/`is not null` filter support on `ParquetTable`; [#76](https://github.com/neuralinkcorp/datarepo/pull/76) replaced a bare dict-subscript `KeyError` with a clear error.
- **Impact:** #75 closed a feature gap between backends meant to share one filter contract; #76 turned an opaque internal exception into an actionable error.
- **Severity:** 2/5 -- missing feature, opaque error: annoying, not dangerous.

Now write the same shape of entry for this repo, using ONLY the facts given below -- do not invent impact, severity reasoning, or anything about the repo beyond what the PR title/body and description state. If the PR body doesn't support a specific impact claim, keep the Impact bullet general and say only what the text actually supports.

Repo: {repo}
Stars: {stars_fmt}
Description: {desc}

Merged PR(s):
{pr_text}

Output ONLY the markdown body (the "N merged PR(s): ..." line followed by "- **Impact:** ..." and "- **Severity:** N/5 -- ..." bullets). No heading line, no preamble, no extra commentary."""

req = urllib.request.Request(
    "https://api.anthropic.com/v1/messages",
    data=json.dumps({
        "model": "claude-haiku-5-5",
        "max_tokens": 400,
        "messages": [{"role": "user", "content": prompt}],
    }).encode("utf-8"),
    headers={
        "content-type": "application/json",
        "x-api-key": os.environ["ANTHROPIC_API_KEY"],
        "anthropic-version": "2023-06-01",
    },
)
with urllib.request.urlopen(req, timeout=60) as resp:
    result = json.loads(resp.read())
print(result["content"][0]["text"].strip())
PYEOF
)
    draft_stubs+=$'\n'"$heading"$'\n'"$body"$'\n'
  done < /tmp/new_repos.txt

  python3 - "$README" "$draft_stubs" <<'PYEOF'
import re, sys
path, stubs = sys.argv[1], sys.argv[2]
text = open(path, encoding="utf-8").read()
text = re.sub(
    r"(\n### Co-authored credit)",
    lambda m: "\n" + stubs + m.group(1),
    text,
    count=1,
)
open(path, "w", encoding="utf-8").write(text)
PYEOF
fi

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

# --- Refresh the inline star count + trending badge on each repo heading ---
# These lines look like: #### [OWNER/REPO](url) ⭐ 8.3k 🔥 +12 today — description
# Re-fetch each repo's current star count via the API, and tag it with a
# "🔥 +N today" badge if /tmp/star_deltas.json shows it actually grew since
# the last run (any repo that grew gets tagged here, not just the single
# biggest mover called out in the FEATURED-REPO line above). A repo with no
# growth keeps its plain star count, no stale badge left behind from a
# previous run -- the old badge (if any) is matched and replaced, not just
# appended, so re-runs can't pile up duplicate tags.
python3 - "$README" /tmp/star_deltas.json <<'PYEOF'
import json, re, subprocess, sys

path, deltas_path = sys.argv[1], sys.argv[2]
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
    return f"{m.group('prefix')}{stars}{badge}{m.group('suffix')}"

pattern = re.compile(
    r"(?P<prefix>^#### \[[^\]]+\]\(https://github\.com/(?P<repo>[^)]+)\) ⭐ )"
    r"(?P<stars>[\d.,]+k?)"
    r"(?: 🔥 \+\d+ today)?"  # consume a stale badge from a previous run, if present
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
