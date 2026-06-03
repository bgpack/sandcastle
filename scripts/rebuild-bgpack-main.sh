#!/usr/bin/env bash
# Rebuilds the integration branch from scratch as: upstream/main + every branch
# in BRANCHES. See FORK_MAINTENANCE.md for the full workflow.

set -euo pipefail

# The integration branch consumed by downstream projects. Versioned to track
# the upstream release it's built on — bump this when upstream releases a new
# minor (e.g. bgpack-main-0.7.0 -> bgpack-main-0.8.0) so old pins stay stable.
INTEGRATION_BRANCH=bgpack-main-0.7.0

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

echo "==> Rebuilding $INTEGRATION_BRANCH from main"
git branch -D "$INTEGRATION_BRANCH" 2>/dev/null || true
git checkout -b "$INTEGRATION_BRANCH" main

echo "==> Merging branches: ${BRANCHES[*]}"
git merge --no-ff "${BRANCHES[@]}" \
  -m "Integrate: $(IFS=', '; echo "${BRANCHES[*]}")"

echo "==> Force-pushing $INTEGRATION_BRANCH"
git push --force-with-lease origin "$INTEGRATION_BRANCH"

echo "==> Done. $INTEGRATION_BRANCH = upstream/main + ${#BRANCHES[@]} branches."
