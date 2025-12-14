param(
  [string]$Repo = 'tzervas/lan-runner',
  [switch]$Apply
)

function Get-Body($num) {
  $current = gh issue view --repo $Repo $num --json body --jq '.body' 2>$null
  return $current
}

function Update-Body($num, $newBody) {
  gh issue edit --repo $Repo $num --body "$newBody"
}

$items = @(
  @{ num = 2;  title = 'Add CI integration test workflow'; body = @(
        '## Acceptance criteria',
        '- [ ] CI runs `docker compose up` (ollama-only) and `test.sh` successfully (timeout and retries)',
        '- [ ] Workflow brings up services on PR push and cleans up after tests',
        '- [ ] No secrets are recorded in logs and the workflow is idempotent',
        '- [ ] Document how to run locally and required secrets (if any)'
      ) -join "`n"
  }
  @{ num = 3; title = 'Add image security scanning'; body = @(
        '## Acceptance criteria',
        '- [ ] Add Trivy (or equivalent) step into CI to scan for vulnerabilities',
        '- [ ] Block PRs on critical vulnerabilities (policy)',
        '- [ ] Document how to run locally and how to customize policy levels'
      ) -join "`n"
  }
  @{ num = 4; title = 'Add integration tests for runner registration'; body = @(
        '## Acceptance criteria',
        '- [ ] Create e2e test verifying ephemeral runner registration to a repo/org (rotating tokens)',
        '- [ ] Automated cleanup to remove test runners',
        '- [ ] Document the manual steps / ephemeral token requirements'
      ) -join "`n"
  }
  @{ num = 5; title = 'Add Ollama model preloading'; body = @(
        '## Acceptance criteria',
        '- [ ] Provide a script to `ollama pull` configured models',
        '- [ ] Integrate preload into compose and k8s init containers or documented steps',
        '- [ ] Add tests to verify models are present post startup'
      ) -join "`n"
  }
  @{ num = 6; title = 'Add monitoring and logging stack'; body = @(
        '## Acceptance criteria',
        '- [ ] Add Prometheus scrape configs or exporters for Ollama and Runner',
        '- [ ] Add a Grafana dashboard skeleton and example alerts',
        '- [ ] Document recommended retention & disk sizing for logs'
      ) -join "`n"
  }
  @{ num = 7; title = 'Create Helm chart'; body = @(
        '## Acceptance criteria',
        '- [ ] Create a Helm chart scaffold and values.yaml for infra/lan-runner',
        '- [ ] Document chart usage and overlays (lite, gpu, nodeport)',
        '- [ ] Provide a simple template for model preloading'
      ) -join "`n"
  }
  @{ num = 8; title = 'ARM64 multi-arch support'; body = @(
        '## Acceptance criteria',
        '- [ ] Document ARM64 limitations and supported images',
        '- [ ] Add multi-arch build or verify existing images on ARM using qemu',
        '- [ ] Add CI test matrix (optional)'
      ) -join "`n"
  }
  @{ num = 9; title = 'Ansible playbook for host setup'; body = @(
        '## Acceptance criteria',
        '- [ ] Provide a role to install Docker, Compose and optionally NVIDIA toolkit',
        '- [ ] Role is idempotent and documented for initial host setup',
        '- [ ] Example playbooks for both CPU-only host and GPU host'
      ) -join "`n"
  }
  @{ num = 10; title = 'Add CONTRIBUTING.md and GPG guidance'; body = @(
        '## Acceptance criteria',
        '- [ ] Add a CONTRIBUTING.md with GPG `git` sign instructions',
        '- [ ] Add PR template and developer guidelines for agent-assisted PRs',
        '- [ ] Add a review checklist for large infra changes'
      ) -join "`n"
  }
  @{ num = 12; title = 'Add auto-scaling for runners'; body = @(
        '## Acceptance criteria',
        '- [ ] Add sample autoscaling recipe to k8s overlay (ARC HPA or custom hook to scale runners)',
        '- [ ] Add tests to verify runner count increases with increased job load',
        '- [ ] Document how to scale down and salvage unused resources'
      ) -join "`n"
  }
)

foreach ($item in $items) {
  $num = $item.num
  $title = $item.title
  $ext = $item.body
  Write-Host ("Enriching issue #{0}: {1}" -f $num, $title)
  $cur = Get-Body $num
  if ($cur -match '<!-- enriched -->') {
    Write-Host "Issue #$num already enriched - skipping"
    continue
  }
  $new = "$cur`n`n$ext`n`n<!-- enriched -->"
  if ($Apply) {
    Update-Body $num $new
    Write-Host ("Updated issue #{0}" -f $num)
  } else {
    Write-Host ("Dry-run: Would update issue #{0} with acceptance criteria" -f $num)
  }
}
