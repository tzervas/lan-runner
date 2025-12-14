param(
  [string]$Repo = 'tzervas/lan-runner'
)

function New-LabelIfMissing {
  param(
    [string]$Name,
    [string]$Color = 'ededed',
    [string]$Desc = ''
  )
  $labels = gh label list --repo $Repo --limit 200 --json name --jq '.[] | .name' 2>$null | Out-String
  if ($labels -match "^$Name$" -or $labels -match "\n$Name\n") {
    Write-Host "label '$Name' exists"
  } else {
    Write-Host "creating label '$Name'"
    gh label create $Name --color $Color --description $Desc --repo $Repo
  }
}

New-LabelIfMissing -Name 'type:task' -Color 'f9d0c4' -Desc 'Task'
New-LabelIfMissing -Name 'type:enhancement' -Color '0e8a16' -Desc 'Enhancement'
New-LabelIfMissing -Name 'area:ci' -Color '1d76db' -Desc 'CI and automation'
New-LabelIfMissing -Name 'area:infra' -Color 'bfe5bf' -Desc 'Infrastructure tasks'
New-LabelIfMissing -Name 'area:monitoring' -Color 'c2e0ff' -Desc 'Monitoring & observability'
New-LabelIfMissing -Name 'area:ollama' -Color 'fef2c0' -Desc 'Ollama specifics'
New-LabelIfMissing -Name 'area:k8s' -Color 'd4c5f9' -Desc 'Kubernetes/ARC'
New-LabelIfMissing -Name 'area:docs' -Color 'ffdfba' -Desc 'Documentation'
New-LabelIfMissing -Name 'priority:high' -Color 'b60205' -Desc 'High priority'
New-LabelIfMissing -Name 'priority:medium' -Color 'fbca04' -Desc 'Medium priority'
New-LabelIfMissing -Name 'priority:low' -Color '0e8a16' -Desc 'Low priority'
New-LabelIfMissing -Name 'status:open' -Color '8bb3ff' -Desc 'Open'

Write-Host "Done creating labels for $Repo"
