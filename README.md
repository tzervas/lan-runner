# LAN Runner + Ollama Stack

Purpose: run a GitHub self-hosted runner and an Ollama endpoint on your LAN host (e.g., 192.168.16.24) using Docker Compose. Tuned for CPU-only Intel E5-2660 v4 (14c x2) with ample RAM. Based on official runner docs: https://docs.github.com/en/actions/hosting-your-own-runners/about-self-hosted-runners

## What this provides
- `github-runner`: registers against a repo/org using a short-lived registration token; labels `lan,cpu,intel` by default.
- `ollama`: CPU-serving endpoint on port 11434 (adjustable via `.env`). Models cached in `./ollama_data`.

## Prereqs on the host (root or sudo)
1) Install Docker + Compose (official): https://docs.docker.com/engine/install/ and https://docs.docker.com/compose/install/
2) Add your user to the docker group and re-login: `sudo usermod -aG docker $USER`
3) Ensure outbound HTTPS works to GitHub and model registries.

## Configure
1) Copy env file: `cp .env.example .env`
2) Get a registration token (short-lived) from GitHub:
   - Repo-level: Settings → Actions → Runners → New self-hosted runner → copy token
   - Or org-level if you prefer shared runners
3) Edit `.env`:
   - `RUNNER_TOKEN`: paste the token
   - `REPO_URL` **or** `ORG_URL`: set one, leave the other empty
   - Adjust `RUNNER_LABELS`, `RUNNER_NAME` if desired
   - Leave `OLLAMA_GPU` empty for CPU; set `OLLAMA_HOST_PORT` if 11434 conflicts

## Run
```bash
cd infra/lan-runner
# First-time pull and start
docker compose pull
docker compose up -d

# Check status
docker compose ps

# View runner logs (registration happens on first start)
docker compose logs -f github-runner
```

## Notes
- The runner mounts `/var/run/docker.sock` to allow jobs that build/run containers. Keep host trust boundaries in mind; restrict LAN access as needed.
- Ollama is exposed on `${OLLAMA_HOST_PORT}` (default 11434). LAN-only exposure assumes a trusted network; add firewall rules if needed.
- CPU-only by default. If you later add NVIDIA GPUs and toolkit, set `OLLAMA_GPU=all` and restart.
- Models are stored under `./ollama_data`; size can be large. Use `docker system df` to monitor disk.

## Cleanup
```bash
cd infra/lan-runner
docker compose down
# Remove models and runner workdir if desired
rm -rf ollama_data
```

## Optional: LAN DNS
If you want friendly names (e.g., `ollama.lan`), add a DNS or hosts entry pointing to 192.168.16.24 and map port 11434.
