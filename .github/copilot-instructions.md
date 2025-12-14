# Copilot Instructions for LAN Runner + Ollama

- **Project shape**: Docker Compose stack with two services in `docker-compose.yml`: `github-runner` (GitHub Actions self-hosted runner) and `ollama` (LLM API). Uses a bridge network `lan` and a named volume `runner-workdir` for the runner workdir.
- **Authoritative docs**: Keep behavior aligned with README and official sources (GitHub self-hosted runner and Ollama Docker docs). Default is CPU-only; avoid adding GPU flags unless `OLLAMA_GPU` is set.
- **Config inputs**: Copy `.env.example` to `.env` before running. Required: `RUNNER_TOKEN` plus exactly one of `REPO_URL` or `ORG_URL`. Defaults: `RUNNER_NAME=lan-runner-01`, `RUNNER_LABELS=lan,cpu,intel`, `RUNNER_WORKDIR=/actions`, `OLLAMA_HOST_PORT=11434`, `OLLAMA_MODELS_DIR=./ollama_data`.
- **Runner service details**: Uses `ghcr.io/actions/actions-runner:latest`, reads envs via `env_file: .env`. Mounts `/var/run/docker.sock` for jobs that build/run containers (trust boundary). Persistent workdir via `runner-workdir:${RUNNER_WORKDIR}`.
- **Ollama service details**: Uses `ollama/ollama:latest`, binds `${OLLAMA_HOST_PORT}:11434`, sets `OLLAMA_HOST=0.0.0.0`, `OLLAMA_GPU=${OLLAMA_GPU}`. Models persist at `${OLLAMA_MODELS_DIR}` (default `./ollama_data`). CPU-only when `OLLAMA_GPU` is empty; set to `all` only when the LAN host running Ollama has NVIDIA toolkit installed and you intend to expose that GPU locally on the LAN (no remote GPU hops).
- **Proxies**: Optional `HTTP_PROXY`, `HTTPS_PROXY`, `NO_PROXY` supported; avoid hardcoding inside compose—use `.env` vars.
- **Bring-up workflow**: `cp .env.example .env`, fill envs, then `docker compose pull && docker compose up -d` from repo root. Inspect with `docker compose ps`. Use `docker compose logs -f github-runner` to confirm registration on first start.
- **Health checks**: Validate Ollama with `curl http://localhost:${OLLAMA_HOST_PORT}/api/tags` (or LAN host IP). Runner status visible in GitHub UI (repo/org Runners) or logs above.
- **Cleanup**: `docker compose down`; remove state with `rm -rf ollama_data` if you want to reclaim model storage.
- **Patterns to keep**: Minimal images (no custom Dockerfiles), env-driven configuration, CPU-safe defaults, short-lived registration tokens (do not bake tokens into code), and keeping README in sync with compose/env expectations.
- **Documentation Index**: Refer to `documentation-index.md` for comprehensive mapping of all docs, configs, and references.
- **Workflow Requirements**: Always create verified commits using GPG signing. Ensure `git config commit.gpgsign true` is set. Update `PROJECT.md` for progress tracking and sync all docs when making changes.

## Tooling Setup with uv

- Use uv for all Python dependency management. Never use raw pip commands.
- Install dependencies: `uv sync`
- Add dev dependencies: `uv add --dev <package>`
- Run tools: `uv run <command>`

## Devcontainer Usage

- Use the `.devcontainer` for consistent development environment.
- Includes tty support for interactive terminal sessions.
- Session display enabled via X11 forwarding for GUI applications.
- Post-create command syncs dependencies with uv.
