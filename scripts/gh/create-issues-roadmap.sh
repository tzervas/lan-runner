#!/usr/bin/env bash
set -euo pipefail

# Create a set of issues for the remaining tasks and a roadmap issue to track them.
# Uses `gh` CLI for repo management. Accepts optional repo and --apply to actually make edits.

REPO=${1:-tzervas/lan-runner}
APPLY=${2:-false}

die() { echo "$@" >&2; exit 1; }

issues=(
  "Add CI integration test workflow|Implement E2E tests to validate Docker Compose + test.sh; run in CI using Docker in Docker or a self-hosted runner; include retries and environment validation.|area:ci,priority:high,type:task"
  "Add image security scanning|Add Trivy/other scanning in CI for images and dependencies; enforce PR checks; enable repo secrets storage to store credentials if needed.|area:ci,priority:high,type:task"
  "Add integration tests for runner registration|Create a minimal e2e test to create ephemeral runner and validate it registers in GitHub; docs for running tests locally.|area:ci,priority:high,type:task"
  "Add Ollama model preloading|Create a script and/or init step to prefetch models into OLLAMA_MODELS_DIR and document how to configure models to preload.|area:ollama,priority:medium,type:enhancement"
  "Add monitoring and logging stack|Add Prometheus & Grafana + Loki (or other log aggregator), with metrics for Ollama and Runner; add dashboards and example alerts.|area:monitoring,priority:medium,type:enhancement"
  "Create Helm chart|Create a Helm chart for the k8s manifests and overlays (values and templates) to ease k8s deployments.|area:k8s,priority:medium,type:enhancement"
  "ARM64 multi-arch support|Add instructions and tests to support ARM64 deployments; consider adding build/test matrix for ARM if possible.|area:infra,priority:low,type:enhancement"
  "Ansible playbook for host setup|Add an Ansible role to setup Docker/Compose, user groups, firewall rules and optionally install NVIDIA toolkit for GPU hosts.|area:infra,priority:low,type:enhancement"
  "Add CONTRIBUTING.md and GPG guidance|Add CONTRIBUTING.md that documents GPG commit signing, PR workflow, changelog expectations and how to use the provided prompts and agent aids.|area:docs,priority:low,type:task"
)

created_ids=()
meta_issue_body='This meta-issue tracks the repo roadmap and links to the created tasks:\n\n'

for item in "${issues[@]}"; do
  IFS='|' read -r title body labels <<< "$item"
  echo "Preparing issue: $title"
  meta_issue_body+="- $title\n"
  if [[ "$APPLY" == "true" ]]; then
    # create the issue
    echo "Creating issue for: $title"
    # skip if issue title exists
    existing=$(gh issue list --repo "$REPO" --json number,title --jq '.[] | select(.title == "'"$title"'") | .number' || true)
    if [[ -n "$existing" ]]; then
      echo "Issue with title exists: #$existing — skipping"
      id="$existing"
    else
      id=$(gh issue create --repo "$REPO" --title "$title" --body "$body" --label "$labels" --json number --jq '.number')
    fi
    created_ids+=("$id")
    meta_issue_body+="  - https://github.com/$REPO/issues/$id\n"
  fi
done

if [[ "$APPLY" == "true" ]]; then
  echo "All issues created. Meta issue body:\n$meta_issue_body"
  echo "Looking for existing roadmap meta-issue"
  existing_meta=$(gh issue list --repo "$REPO" --json number,title --jq '.[] | select(.title == "Roadmap: next steps and critical tasks") | .number' || true)
  if [[ -n "$existing_meta" ]]; then
    echo "Found existing meta issue #$existing_meta — adding a comment update"
    gh issue comment --repo "$REPO" --body "Updated roadmap: $meta_issue_body" --issue-number "$existing_meta"
  else
    echo "No existing meta issue found: creating one"
    meta_id=$(gh issue create --repo "$REPO" --title "Roadmap: next steps and critical tasks" --body "$meta_issue_body" --label "type:task,status:open" --json number --jq '.number')
    echo "Meta issue created: https://github.com/$REPO/issues/$meta_id"
  fi
else
  echo "Dry run: No issues created. Rerun with APPLY=true to actually create."
  echo "Planned issue list:\n$meta_issue_body"
fi
