---
"@ai-hero/sandcastle": patch
---

Fix `opencode()` interactive sessions (and the `init` scaffold's opencode `setupCommand`) seeding the prompt with `-p`, which is the `opencode run`/`attach` basic-auth password flag, not a prompt seed. Use `--prompt` (the TUI's long-form-only seed flag) instead. The TUI pre-fills the textbox but does not auto-submit (see [sst/opencode#3937](https://github.com/sst/opencode/issues/3937)).
