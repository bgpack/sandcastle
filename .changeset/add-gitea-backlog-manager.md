---
"@ai-hero/sandcastle": patch
---

Add Gitea Issues as a backlog manager option in `sandcastle init`. Uses `curl` + `jq` against the Gitea REST API with env vars `GITEA_URL`, `GITEA_TOKEN`, and `GITEA_REPO`.
