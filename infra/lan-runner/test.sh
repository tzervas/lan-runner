#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if [[ ! -f .env ]]; then
  echo "[fail] .env not found. Copy .env.example to .env and fill required values." >&2
  exit 1
fi

set -a
source .env
set +a

if [[ -z "${RUNNER_TOKEN:-}" ]]; then
  echo "[fail] RUNNER_TOKEN is empty; fetch a fresh short-lived token." >&2
  exit 1
fi

if [[ -n "${REPO_URL:-}" && -n "${ORG_URL:-}" ]]; then
  echo "[fail] Set only one of REPO_URL or ORG_URL (not both)." >&2
  exit 1
fi

if [[ -z "${REPO_URL:-}" && -z "${ORG_URL:-}" ]]; then
  echo "[fail] Set REPO_URL (repo) or ORG_URL (org)." >&2
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "[fail] docker is not installed or not on PATH." >&2
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "[fail] curl is required for health checks." >&2
  exit 1
fi

# Service status
echo "[info] docker compose ps"
docker compose ps

# Ollama tag list
OLLAMA_PORT=${OLLAMA_HOST_PORT:-11434}
echo "[info] curl Ollama tags on http://localhost:${OLLAMA_PORT}/api/tags"
if ! curl --fail --silent --show-error "http://localhost:${OLLAMA_PORT}/api/tags"; then
  echo "[warn] Ollama API check failed. Ensure services are up and port ${OLLAMA_PORT} is reachable." >&2
fi

# Runner registration logs (short, bounded)
echo "[info] recent github-runner logs (10s tail)"
if ! timeout 10 docker compose logs -f --tail=50 github-runner; then
  echo "[warn] Unable to stream github-runner logs (may not be running yet)." >&2
fi
