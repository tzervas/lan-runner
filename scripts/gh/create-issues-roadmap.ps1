param(
  [string]$Repo = 'tzervas/lan-runner',
  [switch]$Apply
)

function Get-ExistingIssueNumber($title) {
  try {
    $json = gh issue list --repo $Repo --limit 100 --json number,title 2>$null | ConvertFrom-Json
  } catch {
    return $null
  }
  $found = $json | Where-Object { $_.title -eq $title }
  if ($found) { return $found.number } else { return $null }
}

$issues = @(
  @{ Title = 'Add CI integration test workflow'; Body = 'Implement E2E tests to validate Docker Compose + test.sh; run in CI using Docker in Docker or a self-hosted runner; include retries and environment validation.'; Labels='area:ci,priority:high,type:task' },
  @{ Title = 'Add image security scanning'; Body = 'Add Trivy/other scanning in CI for images and dependencies; enforce PR checks; enable repo secrets storage to store credentials if needed.'; Labels='area:ci,priority:high,type:task' },
  @{ Title = 'Add integration tests for runner registration'; Body = 'Create a minimal e2e test to create ephemeral runner and validate it registers in GitHub; docs for running tests locally.'; Labels='area:ci,priority:high,type:task' },
  @{ Title = 'Add Ollama model preloading'; Body = 'Create a script and/or init step to prefetch models into OLLAMA_MODELS_DIR and document how to configure models to preload.'; Labels='area:ollama,priority:medium,type:enhancement' },
  @{ Title = 'Add monitoring and logging stack'; Body = 'Add Prometheus & Grafana + Loki (or other log aggregator), with metrics for Ollama and Runner; add dashboards and example alerts.'; Labels='area:monitoring,priority:medium,type:enhancement' },
  @{ Title = 'Create Helm chart'; Body = 'Create a Helm chart for the k8s manifests and overlays (values and templates) to ease k8s deployments.'; Labels='area:k8s,priority:medium,type:enhancement' },
  @{ Title = 'ARM64 multi-arch support'; Body = 'Add instructions and tests to support ARM64 deployments; consider adding build/test matrix for ARM if possible.'; Labels='area:infra,priority:low,type:enhancement' },
  @{ Title = 'Ansible playbook for host setup'; Body = 'Add an Ansible role to setup Docker/Compose, user groups, firewall rules and optionally install NVIDIA toolkit for GPU hosts.'; Labels='area:infra,priority:low,type:enhancement' },
  @{ Title = 'Add CONTRIBUTING.md and GPG guidance'; Body = 'Add CONTRIBUTING.md that documents GPG commit signing, PR workflow, changelog expectations and how to use the provided prompts and agent aids.'; Labels='area:docs,priority:low,type:task' }
)

$meta = "This meta-issue tracks the repo roadmap and links to the created tasks:`n`n"
$createdIds = @()

foreach ($issue in $issues) {
  Write-Host "Preparing issue: $($issue.Title)"
  $meta += "- $($issue.Title)`n"
  $exist = Get-ExistingIssueNumber($issue.Title)
  if ($exist) {
    Write-Host "Issue exists: #$exist - skipping creation"
    $createdIds += $exist
    $meta += "  - https://github.com/$Repo/issues/$exist`n"
    continue
  }
  if ($Apply) {
    Write-Host "Creating issue: $($issue.Title)"
  # Create using gh issue create with repeated --label flags for compatibility
  $labelArgs = @()
  foreach ($lbl in ($issue.Labels -split ',')) { $labelArgs += '--label'; $labelArgs += $lbl }
  Write-Host "Running: gh issue create --repo $Repo --title '$($issue.Title)' --body '...body...' --label $($issue.Labels)"
  $resp = & gh issue create --repo $Repo --title "$($issue.Title)" --body "$($issue.Body)" @labelArgs
  # response from gh issue create is the URL; extract trailing number
  if ($resp -match '/issues/(\d+)') { $id = $Matches[1] } else { $id = "" }
    $createdIds += $id
    $meta += "  - https://github.com/$Repo/issues/$id`n"
  }
}

if ($Apply) {
  Write-Host "All issues created. Creating meta-issue"
  $resp2 = gh issue create --repo $Repo --title 'Roadmap: next steps and critical tasks' --body "$meta" --label 'type:task' --label 'status:open'
  if ($resp2 -match '/issues/(\d+)') { $meta_id = $Matches[1] } else { $meta_id = "" }
  Write-Host "Meta Issue: https://github.com/$Repo/issues/$meta_id"
} else {
  Write-Host "Dry run complete. Pass -Apply to create issues.\n Planned items:`n$meta"
}
