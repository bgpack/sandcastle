---
"@ai-hero/sandcastle": patch
---

Strengthen the `simple-loop` and `sequential-reviewer` prompts so an empty pre-expanded `LIST_TASKS_COMMAND` result is treated as ground truth, not as a stale snapshot. The empty-list directive is now hoisted into the imperative `## Workflow` section and the `# Done` completion criterion, and the soft "do not re-query" hint is upgraded to a hard "sole source of truth" rule. Prevents the agent from running its own unfiltered `gh issue list` when the filtered list is `[]`.
