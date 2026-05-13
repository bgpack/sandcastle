---
"@ai-hero/sandcastle": patch
---

Force `LC_ALL=C` and `LANG=C` when invoking `git` from `WorktreeManager`. The worktree-add fallback path matches against git's stderr string (`"invalid reference"`) to decide whether to retry with `-b`, which silently failed on hosts running a non-English locale (e.g. German, where git emits `"ungültige Referenz"`). Pinning the C locale makes git's diagnostic messages stable regardless of the host environment.
