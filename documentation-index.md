# Documentation and Reference Index for LAN Runner + Ollama

## Overview
This index provides a comprehensive mapping of all documentation, configuration files, and reference materials for the LAN Runner + Ollama project. It serves as a quick reference for developers, AI agents, and automated tools to efficiently locate relevant information and adhere to project workflows.

## Workflow Requirements
- **Always Verified Commits**: All commits must be GPG-signed. Ensure `git config commit.gpgsign true` and a valid signing key is configured. Never commit without verification.
- **Branch Protection**: Main branch requires signed commits, no force pushes/deletions, enforced for admins.
- **Vigilant Mode**: Dependabot automated security fixes enabled for proactive vulnerability management.
- **Public Repository**: Repository is public to enable free branch protection features.

## Documentation Files

### Core Project Documentation
| File | Purpose | Key Sections | References |
|------|---------|--------------|------------|
| `README.md` | Main project overview and usage guide | Prerequisites, Configuration, Deployment, Troubleshooting | GitHub Actions docs, Ollama Docker guide |
| `PROJECT.md` | Project status tracker and roadmap | Current Status, Completed Features, Future Enhancements | Internal progress tracking |
| `context.md` | Detailed project specification and context | Project Specification, Setup Guide, Copilot Prompts | Full spec with sourced data |

### Infrastructure Documentation
| File | Purpose | Key Sections | References |
|------|---------|--------------|------------|
| `infra/lan-runner/README.md` | Infrastructure setup guide | Layout, Prereqs, Configure, Run profiles, Verify | Docker Compose, Kubernetes with ARC |

### AI Agent and Development Guides
| File | Purpose | Key Sections | References |
|------|---------|--------------|------------|
| `.github/copilot-instructions.md` | GitHub Copilot development rules | Project shape, Config inputs, Service details | Official docs alignment |
| `.clinerules` | Claude Code development rules | Development Principles, Workflow, References | Coding standards, common tasks |
| `.cursorrules` | Cursor IDE development rules | Project Context, Coding Guidelines, Security | File organization, development workflow |
| `prompts/README.md` | Overview of reusable prompts | Available Prompts | Development assistance |
| `prompts/development.md` | General development guidance | Current State, Guidelines, Common Tasks | Quality checks, documentation updates |
| `prompts/feature-addition.md` | Template for new features | Implementation Plan, Files Checklist, Testing Plan | Security considerations, rollout steps |
| `prompts/troubleshooting.md` | Debugging and issue resolution | Common Issues, Debugging Steps | Getting help, official docs |

### Configuration Files
| File | Purpose | Key Variables/Components | Notes |
|------|---------|-------------------------|-------|
| `.env.example` | Environment variable template | RUNNER_TOKEN, REPO_URL/ORG_URL, RUNNER_LABELS, OLLAMA_* | Copy to `.env` and populate |
| `infra/lan-runner/docker-compose.yml` | Base Docker Compose configuration | github-runner, ollama services, lan network | CPU-optimized defaults |
| `infra/lan-runner/docker-compose.lite.yml` | Resource-limited overlay | Lower CPU/memory limits | For laptop/constrained hosts |
| `infra/lan-runner/docker-compose.gpu.yml` | GPU-enabled overlay | OLLAMA_GPU=all | Requires NVIDIA drivers |
| `infra/lan-runner/test.sh` | Health check script | Service validation, API tests | Run after changes |

### Kubernetes Manifests
| Path | Purpose | Components | Notes |
|------|---------|------------|-------|
| `infra/lan-runner/k8s/base/` | Base Kubernetes manifests | Namespace, Ollama StatefulSet, RunnerDeployment | ARC integration |
| `infra/lan-runner/k8s/overlays/gpu/` | GPU overlay | Ollama GPU patch | Requires GPU nodes |
| `infra/lan-runner/k8s/overlays/lite/` | Resource limits overlay | Lower resource requests | Laptop-friendly |
| `infra/lan-runner/k8s/overlays/nodeport/` | LAN access overlay | NodePort service | Exposes Ollama on nodePort 31134 |

## Quick Reference Commands
- **Setup**: `cp infra/lan-runner/.env.example infra/lan-runner/.env` then edit
- **Deploy CPU**: `cd infra/lan-runner && docker compose up -d`
- **Deploy GPU**: `cd infra/lan-runner && docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d`
- **Test**: `cd infra/lan-runner && ./test.sh`
- **Logs**: `cd infra/lan-runner && docker compose logs -f`
- **K8s Deploy**: `kubectl apply -k infra/lan-runner/k8s/base`
- **Verify Commits**: `git log --show-signature` (check for "gpg: Good signature")

## Development Workflow
1. Review this index and relevant docs
2. Plan changes in `PROJECT.md`
3. Implement with testing
4. Update all affected docs
5. Run tests and validate
6. Commit with GPG signature: `git commit -S -m "message"`

## Security and Trust Boundaries
- Docker socket mounted only for trusted LANs
- Ephemeral tokens with short expiration
- Firewall recommendations in README
- GPU access restricted to labeled nodes

Last updated: December 13, 2025