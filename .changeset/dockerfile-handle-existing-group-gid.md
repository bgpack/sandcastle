---
"@ai-hero/sandcastle": patch
---

Fix Dockerfile build failure when the base image already has a group occupying `$AGENT_GID`. Now removes the conflicting group (if any) before `groupmod` renames the `node` group, so `sandcastle docker build-image` succeeds on hosts whose UID/GID collides with a pre-existing group in `node:22-bookworm`.
