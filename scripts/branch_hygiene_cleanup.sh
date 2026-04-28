#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
# Requires GNU coreutils (`date`) and git.

TRUNK_BRANCH="${TRUNK_BRANCH:-main}"
STALE_DAYS="${STALE_DAYS:-90}"
DRY_RUN="${DRY_RUN:-true}"
PRESERVE_ARCHIVE_TAGS="${PRESERVE_ARCHIVE_TAGS:-true}"
OUT_ROOT="${OUT_ROOT:-$ROOT/artifacts/branch-hygiene}"
TIMESTAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
OUT_DIR="${OUT_ROOT}/${TIMESTAMP}"
mkdir -p "$OUT_DIR"

if ! git rev-parse --verify --quiet "refs/remotes/origin/${TRUNK_BRANCH}" >/dev/null; then
  echo "Missing origin/${TRUNK_BRANCH}. Run 'git fetch --all --prune' (or fetch origin) and verify TRUNK_BRANCH." >&2
  exit 1
fi

cutoff_epoch="$(date -u -d "-${STALE_DAYS} days" +%s)"

is_protected_branch() {
  local branch="$1"
  [[ "$branch" == "$TRUNK_BRANCH" ]] && return 0
  [[ "$branch" == "main" || "$branch" == "master" || "$branch" == "develop" ]] && return 0
  [[ "$branch" =~ ^(release|support|hotfix)/ ]] && return 0
  [[ "$branch" =~ ^(recovery|archive)/ ]] && return 0
  return 1
}

{
  echo "branch|last_commit_utc|status"
  while IFS='|' read -r branch commit_date; do
    if is_protected_branch "$branch"; then
      echo "${branch}|${commit_date}|protected"
      continue
    fi

    commit_epoch="$(date -u -d "$commit_date" +%s)"
    if (( commit_epoch > cutoff_epoch )); then
      echo "${branch}|${commit_date}|recent"
      continue
    fi

    if ! git merge-base --is-ancestor "origin/${branch}" "origin/${TRUNK_BRANCH}" >/dev/null 2>&1; then
      echo "${branch}|${commit_date}|unmerged"
      continue
    fi

    echo "${branch}|${commit_date}|delete-candidate"
  done < <(
    git for-each-ref --format='%(refname:short)|%(committerdate:iso8601)' refs/remotes/origin \
      | sed 's#^origin/##' \
      | grep -v '^HEAD|'
  )
} > "${OUT_DIR}/stale-branch-evaluation.txt"

awk -F'|' '$3=="delete-candidate"{print $1}' "${OUT_DIR}/stale-branch-evaluation.txt" \
  > "${OUT_DIR}/delete-candidates.txt"

while IFS= read -r branch; do
  [[ -z "$branch" ]] && continue
  if [[ "$PRESERVE_ARCHIVE_TAGS" == "true" ]]; then
    tag_name="archive/deleted-branches/${TIMESTAMP}/${branch//\//-}"
    if [[ "$DRY_RUN" == "true" ]]; then
      echo "DRY-RUN tag ${tag_name} -> origin/${branch}" >> "${OUT_DIR}/actions.log"
    else
      git tag -f "${tag_name}" "refs/remotes/origin/${branch}" >/dev/null
      echo "TAGGED ${tag_name} -> origin/${branch}" >> "${OUT_DIR}/actions.log"
    fi
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    echo "DRY-RUN delete remote branch ${branch}" >> "${OUT_DIR}/actions.log"
  else
    git push origin --delete "${branch}"
    echo "DELETED remote branch ${branch}" >> "${OUT_DIR}/actions.log"
  fi
done < "${OUT_DIR}/delete-candidates.txt"

{
  echo "# Branch hygiene cleanup"
  echo ""
  echo "- timestamp: ${TIMESTAMP}"
  echo "- trunk: ${TRUNK_BRANCH}"
  echo "- stale_days: ${STALE_DAYS}"
  echo "- dry_run: ${DRY_RUN}"
  echo "- preserve_archive_tags: ${PRESERVE_ARCHIVE_TAGS}"
  echo ""
  echo "## Outputs"
  echo "- stale-branch-evaluation.txt"
  echo "- delete-candidates.txt"
  echo "- actions.log"
} > "${OUT_DIR}/SUMMARY.md"

echo "Branch cleanup results written to ${OUT_DIR}"
