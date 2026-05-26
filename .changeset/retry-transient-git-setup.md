---
"@ai-hero/sandcastle": patch
---

Retry transient git setup exec failures during `withSandboxLifecycle`. Under heavy parallelism the `git config` / `git rev-parse` commands run at sandbox start could fail with exit 126 (`cannot exec`) or 137 (killed) from a momentary container exec race rather than a real git error. These are now retried (each attempt still bounded by the existing per-command timeout); genuine non-transient git failures and hangs still fail fast. `ExecError` also gains an optional `exitCode` field carrying the failing command's exit code.
