---
"@ai-hero/sandcastle": minor
---

Add Gitea Issues as an issue tracker option in `sandcastle init`. Uses curl + jq against the Gitea REST API (both already present in the agent base image), authenticated via GITEA_URL, GITEA_TOKEN, and GITEA_REPO env vars.
