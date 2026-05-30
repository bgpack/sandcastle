#!/usr/bin/env bash
# Rebuilds `bgpack-main` from scratch as: upstream/main + every branch in BRANCHES.
# See FORK_MAINTENANCE.md for the full workflow.

set -euo pipefail

# Branches to stack on top of upstream/main.
# Add a branch here when you create a new local patch.
# Remove a branch here once it's merged upstream.
# `fork/maintenance` carries this script + the docs; keep it in the list.
BRANCHES=(
  feat/gitea-issue-tracker
  fork/maintenance
)

echo "==> Fetching upstream"
git fetch upstream

echo "==> Fast-forwarding main to upstream/main"
git checkout main
if ! git merge --ff-only upstream/main; then
  echo "ERROR: main has diverged from upstream/main." >&2
  echo "       See 'Re-aligning if main drifts' in FORK_MAINTENANCE.md." >&2
  exit 1
fi
git push origin main

echo "==> Rebuilding bgpack-main from main"
git branch -D bgpack-main 2>/dev/null || true
git checkout -b bgpack-main main

echo "==> Merging branches: ${BRANCHES[*]}"
git merge --no-ff "${BRANCHES[@]}" \
  -m "Integrate: $(IFS=', '; echo "${BRANCHES[*]}")"

echo "==> Force-pushing bgpack-main"
git push --force-with-lease origin bgpack-main

echo "==> Done. bgpack-main = upstream/main + ${#BRANCHES[@]} branches."
