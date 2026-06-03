---
"@ai-hero/sandcastle": patch
---

Fix the Cursor agent Dockerfile failing to build when the host GID collides with a reserved base-image group. The Cursor template was the only one still running `groupmod`/`usermod` without the `-o` (non-unique) flag; align it with the other agent templates.
