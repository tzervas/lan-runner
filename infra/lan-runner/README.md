# LAN Runner + Ollama Stack

Run a GitHub self-hosted runner and an Ollama endpoint on your LAN via Docker Compose. Defaults are CPU-only; GPU is opt-in when the host has NVIDIA drivers + container toolkit. Based on official runner docs: https://docs.github.com/en/actions/hosting-your-own-runners/about-self-hosted-runners and Ollama Docker guidance.

## Layout
- `docker-compose.yml`: CPU-safe defaults.
- `docker-compose.lite.yml`: laptop-friendly overlay with lower CPU/mem limits.
- `docker-compose.gpu.yml`: optional overlay to enable GPU (`OLLAMA_GPU=all`).
- `.env.example`: copy to `.env` and fill.
- `test.sh`: non-destructive health checks.

## What this provides
- `github-runner`: registers to a repo or org with short-lived token; labels `lan,cpu,intel` by default; mounts docker.sock for nested builds.
- `ollama`: API on `${OLLAMA_HOST_PORT:-11434}`; models stored in `${OLLAMA_MODELS_DIR:-./ollama_data}`.

## Prereqs (host)
1) Docker Engine + Compose v2 (official docs).
2) User in `docker` group (re-login).
3) Outbound HTTPS to github.com and model registries.
4) GPU mode only: NVIDIA driver + NVIDIA Container Toolkit installed.

## Configure
```bash
cd infra/lan-runner
cp .env.example .env
# edit .env: set RUNNER_TOKEN, and exactly one of REPO_URL or ORG_URL
```
Key envs:
- `RUNNER_TOKEN` (short-lived; regenerate per bring-up)
- `REPO_URL` **or** `ORG_URL` (not both)
- `RUNNER_NAME`, `RUNNER_LABELS` (optional tuning)
- `OLLAMA_HOST_PORT` (adjust if 11434 conflicts)
- `OLLAMA_GPU` empty for CPU, `all` for GPU hosts only

## Run profiles
- CPU default:
```bash
cd infra/lan-runner
docker compose pull
docker compose up -d
```

- Laptop-friendly (lower resources):
```bash
cd infra/lan-runner
docker compose -f docker-compose.yml -f docker-compose.lite.yml up -d
```

- GPU (opt-in, requires NVIDIA driver + container toolkit, and `OLLAMA_GPU=all` in .env):
```bash
cd infra/lan-runner
docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d
```

- Scale runners (more concurrent jobs; one job per runner container):
```bash
cd infra/lan-runner
docker compose up -d --scale github-runner=4
```

## Verify
```bash
./test.sh                 # quick checks
curl http://localhost:${OLLAMA_HOST_PORT:-11434}/api/tags
# or check runner registration in GitHub Settings → Actions → Runners
```

## Trust boundary & networking
- `docker.sock` is mounted into the runner: only run this on trusted hosts/LAN; restrict who can reach the host.
- Suggested firewall example (adjust subnet): `sudo iptables -A INPUT -s 192.168.16.0/24 -j ACCEPT` and default-drop others.
- Proxies: set `HTTP_PROXY/HTTPS_PROXY/NO_PROXY` in `.env`; keep `NO_PROXY` covering `localhost,127.0.0.1`.
- Large GPU hosts: ensure only trusted users can schedule containers; GPUs are exposed to `ollama` when GPU overlay is used.

## Troubleshooting
- Token expired: get a new `RUNNER_TOKEN` and restart the runner service.
- Both REPO_URL and ORG_URL set: clear one.
- Port conflict on 11434: change `OLLAMA_HOST_PORT` in `.env` and restart.
- GPU not detected: ensure NVIDIA driver + toolkit installed; rerun with GPU overlay.

## Cleanup
```bash
cd infra/lan-runner
docker compose down
rm -rf ollama_data runner-workdir  # optional: removes models and runner workdir
```

## Kubernetes (k3s/k0s/microk8s/kind) with ARC
Opinionated path: k3s + Actions Runner Controller (ARC) for ephemeral, secure runners; plain k8s manifests for Ollama. Manifests live in `infra/lan-runner/k8s/` and use only core APIs plus ARC CRDs.

### Prereqs
- A Kubernetes cluster (k3s recommended for lightweight; works on k0s/microk8s/kind).
- `kubectl` and `kustomize` (kubectl has built-in kustomize via `-k`).
- NVIDIA GPU nodes (optional) with drivers + device plugin (for GPU overlay).
- GitHub PAT (repo or org admin scope) to let ARC mint registration tokens.

### Install ARC (example with Helm)
```bash
helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller
helm repo update
helm upgrade --install arc actions-runner-controller/actions-runner-controller \
	--namespace actions-runner-system --create-namespace
```

### Configure secrets and repo/org
Set your repo or org in `k8s/base/runners-runnerdeployment.yaml` (`repository: github.com/your/repo` or `organization: your-org`).
Create the PAT secret (short-lived, rotate regularly):
```bash
kubectl create namespace lan-runner  # harmless if exists
kubectl create secret generic github-token -n lan-runner \
	--from-literal=github_token=ghp_your_pat_here
```

### Apply (CPU default)
```bash
kubectl apply -k k8s/base
```

### Overlays
- GPU (requires labeled GPU nodes `gpu=true`):
```bash
kubectl apply -k k8s/overlays/gpu
```
- Lite (laptop-friendly resource limits):
```bash
kubectl apply -k k8s/overlays/lite
```
- NodePort for LAN Ollama access (uses nodePort 31134):
```bash
kubectl apply -k k8s/overlays/nodeport
```

### What the k8s base includes
- Ollama StatefulSet + PVC for models, ClusterIP Service on 11434, readiness probe `/api/tags`.
- RunnerDeployment (ARC) with labels `lan,cpu,intel`; no host docker.sock required.

### Scaling
- Runners: ARC scales via `kubectl scale deploy/arc-runnerdeploy-github-runner -n lan-runner --replicas=N` or via ARC autoscaling.
- Ollama: scale replicas or add an HPA (CPU/custom metrics) if desired.

### Trust boundary
- ARC runners are per-job containers; avoid mounting host docker.sock.
- GPU overlay exposes GPUs to Ollama pods; label only trusted nodes (`gpu=true`) and scope NodePort overlay to trusted LANs.
