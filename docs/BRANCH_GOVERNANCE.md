# Branch Governance and Recovery Runbook

## Canonical trunk and merge strategy

- Canonical trunk: `main`
- Default PR merge strategy: **Rebase and merge**
- Linear policy: no merge commits into trunk
- PR target policy: only `living-relation/PowerTuneDigitalOfficial` with base branch `main`

## `/ship` — single-word automation command

The `/ship` command automates the full merge-to-main lifecycle from a PR comment.

### How to trigger

1. Open (or find) the pull request you want to merge into `main`.
2. Post a comment with **exactly** `/ship`.
3. The workflow scans branch-protection rules, required status checks, repo settings, and current CI status, then posts a report.
4. After reviewing the report, post **`/ship confirm`** to execute the merge.

### What the workflow does

**`/ship` (Phase 1 — scan)**
- Verifies the commenter has write/maintain/admin permission.
- Reads branch-protection rules on the target branch (required reviews, required status checks, admin enforcement, push restrictions, conversation resolution).
- Reads repository merge settings (allowed merge methods, auto-delete-on-merge).
- Reads the current PR state (draft, merge conflicts, mergeable state).
- Reads the latest CI check results for the PR head commit.
- Posts a full report listing any blockers and informational notices.
- Asks you to reply `/ship confirm` to proceed.

**`/ship confirm` (Phase 2 — execute)**
- Converts the PR from draft to ready-for-review if needed.
- Enables GitHub's native **auto-merge** (rebase method preferred; falls back to squash, then merge commit).
- Once all required checks pass the PR merges automatically.
- If auto-merge is unavailable, attempts a direct rebase merge.
- Branch deletion is handled automatically by the `delete-merged-branches` workflow on merge.

### Caller requirements

- Must be posted as a comment on a **pull request** (not a plain issue).
- Caller must have **write**, **maintain**, or **admin** permission on the repository.

### Copying to other repos

To enable `/ship` in another `living-relation` repository, copy `.github/workflows/ship.yml` to that repository. No additional secrets are required — it uses the standard `GITHUB_TOKEN`.

## Automation flags — feature-merge-command.yml

`/.github/workflows/feature-merge-command.yml` governs feature-to-feature branch merges:

- `ALLOW_FEATURE_BRANCH_AUTOMATION: "true"` — automation enabled
- `ALLOW_BRANCH_DELETE: "true"` — branch deletion enabled

## Inventory and recovery workflow

Run these from repo root:

```bash
bash scripts/branch_hygiene_audit.sh
```

The audit creates:

- branch map with dates/authors/subjects
- ahead/behind + merged status against trunk
- orphan risk lists (unmerged and local-only branches)
- lost-change candidates (dangling commits + reflog dump)
- safety snapshot refs under `refs/backup/...` and a trunk archive tag

## Recovery branch policy

- Recover orphaned/lost commits under `recovery/*`.
- Preserve deleted branch tips as `archive/*` tags first.
- Never delete branches that are:
  - `main`, `master`, `develop`
  - `release/*`, `support/*`, `hotfix/*`
  - `recovery/*`, `archive/*`

## Stale branch cleanup policy

Use cleanup script in dry-run mode first:

```bash
TRUNK_BRANCH=main STALE_DAYS=90 DRY_RUN=true bash scripts/branch_hygiene_cleanup.sh
```

When validated, enable actual deletions:

```bash
TRUNK_BRANCH=main STALE_DAYS=90 DRY_RUN=false PRESERVE_ARCHIVE_TAGS=true bash scripts/branch_hygiene_cleanup.sh
```

## Verification and sign-off checklist

1. No unreconciled unique commits remain outside `main`, `recovery/*`, or `archive/*`.
2. Recovery branches are deduplicated before integration.
3. Integration PRs are rebased and linear.
4. PR target policy check passes (repo + branch guard).
5. CI is green for integrated commits.
6. Final audit report is stored in `artifacts/branch-hygiene/<timestamp>/`.
