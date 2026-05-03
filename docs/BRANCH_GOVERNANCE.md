# Branch Governance and Recovery Runbook

## Canonical trunk and merge strategy

- Canonical trunk: `main`
- Default PR merge strategy: **Rebase and merge**
- Linear policy: no merge commits into trunk
- PR target policy: only `living-relation/PowerTuneDigitalOfficial` with base branch `main`

## Branch automation

`/.github/workflows/feature-merge-command.yml` controls feature-branch merge and delete automation:

- `ALLOW_FEATURE_BRANCH_AUTOMATION: "true"` — feature-branch merge automation is **enabled**
- `ALLOW_BRANCH_DELETE: "true"` — branch deletion after merge is **enabled**

Set either value to `"false"` in the workflow file to freeze the corresponding automation during branch cleanup or recovery work.

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
