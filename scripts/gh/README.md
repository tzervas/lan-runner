# GitHub automation helpers

These scripts use the `gh` CLI to automate creating labels and issues in the repo.

Requirements:
- gh CLI (`https://cli.github.com/`)
- authenticated `gh` session (`gh auth login`) with repo write permissions

Scripts:
- `create-labels.sh [repo]` - create the repo labels used by this project (defaults to `tzervas/lan-runner`).
- `create-issues-roadmap.sh [repo] [APPLY]` - create a set of prioritized issues and a meta roadmap placeholder. `APPLY=true` actually creates issues; default is dry-run.

Examples:
```bash
# Create labels (dry run: only prints what will be created)
bash scripts/gh/create-labels.sh

# Create issues (dry run)
bash scripts/gh/create-issues-roadmap.sh

# Actually create issues
bash scripts/gh/create-issues-roadmap.sh tzervas/lan-runner true
```

PowerShell (Windows) examples:
```powershell
# Create labels
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\gh\create-labels.ps1

# Dry run to plan issues
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\gh\create-issues-roadmap.ps1

# Actually create issues
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\gh\create-issues-roadmap.ps1 -Apply
```

Registration Workflows
----------------------
Two workflows exist to help validate runner registration end-to-end. Both are manual `workflow_dispatch` jobs.

- `.github/workflows/integration-registration-v2.yml` — DIND-based run that executes on `ubuntu-latest` using Docker-in-Docker. Requires a repo secret named `RUNNER_PAT` with a PAT capable of managing runners.
- `.github/workflows/integration-registration-selfhosted.yml` — For testing on a self-hosted runner (label `lan`). The runner host must have Docker & Docker Compose installed; you also need to supply `RUNNER_PAT` as a repo secret.

To safely test runner-registration (creates and removes a temporary runner):
```powershell
# Set the PAT as a repo secret before running the workflow
# ``RUNNER_PAT`` must have scope to create/remove runners for the target repo.
# Trigger the DIND workflow (manual run via GitHub Actions UI) and provide the repo value if needed.
# Or run the self-hosted workflow on your admin self-hosted runner, with RUNNER_PAT in secrets.
```


Notes:
- Scripts are idempotent where it makes sense (e.g. label creation checks for existing labels).
- Run these from the repository root.
