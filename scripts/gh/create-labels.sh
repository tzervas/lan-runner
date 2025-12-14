#!/usr/bin/env bash
set -euo pipefail

# Creates a set of repository labels for task tracking. Uses 'gh' CLI.
REPO=${1:-tzervas/lan-runner}

label_create() {
  name="$1"
  color=${2:-"ededed"}
  description=${3:-""}
  if gh label list --repo "$REPO" | grep -q "^$name\b"; then
    echo "label '$name' exists"
  else
    echo "creating label '$name'"
    gh label create "$name" --color "$color" --description "$description" --repo "$REPO"
  fi
}

label_create "type:task" "f9d0c4" "Task"
label_create "type:enhancement" "0e8a16" "Enhancement" 
label_create "area:ci" "1d76db" "CI and automation"
label_create "area:infra" "bfe5bf" "Infrastructure tasks"
label_create "area:monitoring" "c2e0ff" "Monitoring & observability"
label_create "area:ollama" "fef2c0" "Ollama specifics"
label_create "area:k8s" "d4c5f9" "Kubernetes/ARC"
label_create "area:docs" "ffdfba" "Documentation"
label_create "priority:high" "b60205" "High priority"
label_create "priority:medium" "fbca04" "Medium priority"
label_create "priority:low" "0e8a16" "Low priority"
label_create "status:open" "8bb3ff" "Open"

echo "Done creating labels for $REPO"
