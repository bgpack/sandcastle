# Fork maintenance (bgpack/sandcastle)

This fork keeps `main` as a clean mirror of `mattpocock/sandcastle:main`. Local
patches that aren't yet merged upstream live on individual feature branches and
are integrated into a versioned integration branch, which is what downstream
projects consume.

The integration branch is named after the upstream release it's built on —
currently **`bgpack-main-0.7.0`** (set via `INTEGRATION_BRANCH` in the rebuild
script). Bump it on each upstream minor so existing downstream pins stay stable.
References to `bgpack-main` below mean whatever `INTEGRATION_BRANCH` currently
points at.

```
upstream/main ──fast-forward──▶ main ──┐
                                       ├── octopus-merge ──▶ bgpack-main-<upstream-version>
feat/*, fix/*, fork/maintenance ───────┘
```

## Branches

| Branch             | Purpose                                                                                                                                 | Lifetime              |
| ------------------ | --------------------------------------------------------------------------------------------------------------------------------------- | --------------------- |
| `main`             | Pristine mirror of `mattpocock/sandcastle:main`. Never commit here directly.                                                            | permanent             |
| `bgpack-main`      | Integration view = `main` + all active patches. Force-pushed by the rebuild script. Consumed by downstream projects via `package.json`. | permanent             |
| `feat/*`, `fix/*`  | Single-purpose patches, one per upstream PR. Removed once merged upstream.                                                              | until merged upstream |
| `fork/maintenance` | These docs + the rebuild script. Always merged into `bgpack-main`.                                                                      | permanent             |

## Remotes

```bash
git remote -v
# origin    git@github.com:bgpack/sandcastle.git    (fetch/push)  ← your fork
# upstream  https://github.com/mattpocock/sandcastle.git  (fetch/push)  ← Matt's repo
```

## Rules

1. **Never commit to `main`.** It must stay a fast-forward of `upstream/main`. If you commit there by mistake, the rebuild script will refuse to fast-forward and you'll have to revert.
2. **One concern per feature branch.** No bundling. Each `feat/*` or `fix/*` corresponds to exactly one upstream PR.
3. **Edit only `fork/maintenance` for fork-level meta files.** Anything that should never go upstream (this doc, the rebuild script, fork-specific CI tweaks) belongs on `fork/maintenance`. Keeps the upstream-bound branches clean.
4. **Rebuild `bgpack-main` from scratch each time.** Don't merge ad-hoc into it. The rebuild script is the source of truth.

## Adding a new local patch

```bash
git fetch upstream
git checkout main
git merge --ff-only upstream/main
git checkout -b fix/short-description main
# ...edit, test, commit...
git push -u origin fix/short-description
```

Open a PR from `bgpack/sandcastle:fix/short-description` against your fork's `main` (for fork-local review) or directly against `mattpocock/sandcastle:main` (to send upstream). Then add the branch name to `BRANCHES` in `scripts/rebuild-bgpack-main.sh` and run the script.

## When a local patch lands upstream

When Matt merges one of your PRs:

1. Delete the local + remote branch:
   ```bash
   git branch -D feat/foo
   git push origin --delete feat/foo
   ```
2. Remove the branch name from `BRANCHES` in `scripts/rebuild-bgpack-main.sh`.
3. Commit the script change on `fork/maintenance`, push.
4. Run the rebuild script. `bgpack-main` will now pull in the upstream-merged version and drop the local one.

When `BRANCHES` contains only `fork/maintenance`, you can consume `main` directly from downstream and retire `bgpack-main`.

## Rebuilding `bgpack-main`

```bash
./scripts/rebuild-bgpack-main.sh
```

The script:

1. Fast-forwards `main` to `upstream/main` (errors if `main` has diverged — fix that first).
2. Pushes the fresh `main` to `origin`.
3. Deletes the local `bgpack-main` and recreates it from `main`.
4. Octopus-merges every branch listed in `BRANCHES` (including `fork/maintenance`).
5. Force-pushes `bgpack-main` to `origin` using `--force-with-lease`.

Force-push is safe here because `bgpack-main` is yours and the rebuild is deterministic. `--force-with-lease` still aborts if someone else pushed in the meantime.

## Consuming `bgpack-main` downstream

In a downstream project's `package.json`:

```json
{
  "dependencies": {
    "@ai-hero/sandcastle": "github:bgpack/sandcastle#bgpack-main-0.7.0"
  }
}
```

Or pin to a specific commit SHA for reproducibility:

```json
{
  "dependencies": {
    "@ai-hero/sandcastle": "github:bgpack/sandcastle#<sha>"
  }
}
```

After each rebuild, downstream projects need to `npm install` (or bump the SHA) to pick up the new `bgpack-main` HEAD. The git tag/SHA reference makes the dependency cache-friendly.

## Re-aligning if `main` drifts

If you committed to `main` by accident and the fast-forward fails:

```bash
git fetch upstream
git checkout main
git log upstream/main..main          # see what's there that shouldn't be
git reset --hard upstream/main       # discards local commits on main — only run after moving them to a feature branch
git push --force-with-lease origin main
```
