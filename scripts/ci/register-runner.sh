#!/usr/bin/env bash
set -eu -o pipefail
repo=${1:-${GITHUB_REPOSITORY}}
runner_name=${RUNNER_NAME:-lan-runner-ci-01}
runner_token=${RUNNER_TOKEN:-}

if [[ -z "${runner_token}" ]]; then
  echo "RUNNER_TOKEN is empty; aborting" >&2
  exit 1
fi

echo "Starting Docker Compose (runner: ${runner_name}) against repo: $repo"
export RUNNER_TOKEN="$runner_token"
export REPO_URL="https://github.com/$repo"
export RUNNER_NAME="$runner_name"
cd "$(dirname "$0")/../../infra/lan-runner" || exit 1
docker compose up -d --scale github-runner=1

echo "Waiting for runner to be listed in repository…"
for i in {1..60}; do
  id=$(gh api -H 'Accept: application/vnd.github+json' "/repos/$repo/actions/runners" --jq '.runners[] | select(.name == "'"$runner_name"'") | .id' || true)
  if [[ -n "$id" ]]; then
    echo "Runner registered as #$id"
    break
  fi
  printf '.'
  sleep 2
done
if [[ -z "$id" ]]; then
  echo "Runner was not registered in time" >&2
  docker compose logs --tail=100 || true
  docker compose down -v || true
  exit 1
fi

echo "Checking runner state..."
state=$(gh api -H 'Accept: application/vnd.github+json' "/repos/$repo/actions/runners/$id" --jq '.status')
echo "Runner #$id state: $state"
if [[ "$state" != 'online' ]]; then
  echo "Runner not online: $state" >&2
  docker compose logs --tail=100 || true
  docker compose down -v || true
  exit 1
fi

echo "Runner #$id is online — test success. Cleaning up." 
gh api --method DELETE "/repos/$repo/actions/runners/$id" || true
docker compose down -v || true
echo "Done."
