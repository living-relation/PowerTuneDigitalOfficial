#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
# Requires GNU coreutils (`date`) and git.

TRUNK_BRANCH="${TRUNK_BRANCH:-main}"
SNAPSHOT_PREFIX="${SNAPSHOT_PREFIX:-branch-hygiene}"
OUT_ROOT="${OUT_ROOT:-$ROOT/artifacts/branch-hygiene}"
TIMESTAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
OUT_DIR="${OUT_ROOT}/${TIMESTAMP}"

mkdir -p "$OUT_DIR"

if ! git rev-parse --verify --quiet "refs/remotes/origin/${TRUNK_BRANCH}" >/dev/null; then
  echo "Missing origin/${TRUNK_BRANCH}. Run 'git fetch --all --prune' (or fetch origin) and verify TRUNK_BRANCH." >&2
  exit 1
fi

SANITIZED_TRUNK="${TRUNK_BRANCH//\//-}"
SNAPSHOT_TAG="archive/${SNAPSHOT_PREFIX}/${TIMESTAMP}/${SANITIZED_TRUNK}"
if git rev-parse --verify --quiet "refs/tags/${SNAPSHOT_TAG}" >/dev/null; then
  echo "WARN: snapshot tag ${SNAPSHOT_TAG} already exists; leaving existing tag unchanged." >&2
else
  git tag "${SNAPSHOT_TAG}" "refs/remotes/origin/${TRUNK_BRANCH}"
fi

while IFS= read -r ref; do
  branch="${ref#origin/}"
  branch_safe="${branch//\//-}"
  git update-ref "refs/backup/${SNAPSHOT_PREFIX}/${TIMESTAMP}/${branch_safe}" "refs/remotes/origin/${branch}"
done < <(git for-each-ref --format='%(refname:short)' refs/remotes/origin | grep -v '^origin/HEAD$')

git for-each-ref \
  --format='%(refname:short)|%(committerdate:iso8601)|%(authorname)|%(subject)' \
  refs/remotes/origin \
  | sed 's#^origin/##' \
  | grep -v '^HEAD|' \
  > "${OUT_DIR}/branch-map.txt"

{
  echo "branch|ahead|behind|merged_into_${TRUNK_BRANCH}"
  while IFS= read -r branch; do
    [[ "$branch" == "HEAD" ]] && continue
    set +e
    counts="$(git rev-list --left-right --count "origin/${TRUNK_BRANCH}...origin/${branch}" 2>/dev/null)"
    rc=$?
    set -e
    if [[ $rc -ne 0 ]]; then
      echo "WARN: failed divergence check for branch ${branch}" >&2
      echo "${branch}|n/a|n/a|unknown"
      continue
    fi
    ahead="$(awk '{print $2}' <<<"$counts")"
    behind="$(awk '{print $1}' <<<"$counts")"
    merged_state="no"
    if git merge-base --is-ancestor "origin/${branch}" "origin/${TRUNK_BRANCH}" >/dev/null 2>&1; then
      merged_state="yes"
    fi
    echo "${branch}|${ahead}|${behind}|${merged_state}"
  done < <(git for-each-ref --format='%(refname:short)' refs/remotes/origin | sed 's#^origin/##' | grep -v '^HEAD$' | sort)
} > "${OUT_DIR}/branch-divergence.txt"

git for-each-ref --format='%(refname:short)' refs/remotes/origin \
  | sed 's#^origin/##' \
  | grep -v '^HEAD$' \
  | while IFS= read -r branch; do
      if [[ "$branch" == "$TRUNK_BRANCH" ]]; then
        continue
      fi
      if git merge-base --is-ancestor "origin/${branch}" "origin/${TRUNK_BRANCH}" >/dev/null 2>&1; then
        continue
      fi
      echo "$branch"
    done \
  > "${OUT_DIR}/orphan-risk-unmerged-branches.txt"

git for-each-ref --format='%(refname:short)' refs/heads \
  | while IFS= read -r local_branch; do
      if ! git rev-parse --verify --quiet "refs/remotes/origin/${local_branch}" >/dev/null; then
        echo "${local_branch}"
      fi
    done \
  > "${OUT_DIR}/orphan-risk-local-only-branches.txt"

if git rev-parse --verify --quiet "origin/${TRUNK_BRANCH}" >/dev/null; then
  git rev-list --all --not "origin/${TRUNK_BRANCH}" > "${OUT_DIR}/commits-not-on-trunk.txt"
fi

if ! git fsck --no-reflogs --lost-found --unreachable --no-progress \
  > "${OUT_DIR}/git-fsck.txt" 2>&1; then
  echo "WARN: git fsck returned non-zero status (possible repository integrity or object reachability issues); review ${OUT_DIR}/git-fsck.txt" >&2
fi
grep 'dangling commit' "${OUT_DIR}/git-fsck.txt" | awk '{print $3}' > "${OUT_DIR}/lost-change-candidates-dangling.txt" || true

git reflog --date=iso --all > "${OUT_DIR}/reflog-all.txt"

{
  echo "# Branch hygiene audit"
  echo ""
  echo "- timestamp: ${TIMESTAMP}"
  echo "- trunk: ${TRUNK_BRANCH}"
  echo "- snapshot_tag: ${SNAPSHOT_TAG}"
  echo "- backup_refs_prefix: refs/backup/${SNAPSHOT_PREFIX}/${TIMESTAMP}/"
  echo ""
  echo "## Files"
  echo "- branch-map.txt"
  echo "- branch-divergence.txt"
  echo "- orphan-risk-unmerged-branches.txt"
  echo "- orphan-risk-local-only-branches.txt"
  echo "- commits-not-on-trunk.txt"
  echo "- git-fsck.txt"
  echo "- lost-change-candidates-dangling.txt"
  echo "- reflog-all.txt"
} > "${OUT_DIR}/SUMMARY.md"

echo "Branch hygiene audit written to ${OUT_DIR}"
