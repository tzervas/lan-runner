#!/usr/bin/env bash
set -eu -o pipefail
REPO=${1:-${GITHUB_REPOSITORY}}
RUNNER_PAT=${2:-${RUNNER_PAT:-}}
if [[ -z "$RUNNER_PAT" ]]; then
  echo "RUNNER_PAT must be supplied as an argument or environment variable; aborting." >&2
  exit 1
fi
token=$(curl -s -X POST -H "Accept: application/vnd.github+json" -H "Authorization: token ${RUNNER_PAT}" "https://api.github.com/repos/$REPO/actions/runners/registration-token" | jq -r '.token')
echo "token=$token" >> $GITHUB_OUTPUT
echo "token: $token"
