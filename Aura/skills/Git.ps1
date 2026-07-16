function Invoke-AuraGitStatus {
    Write-AuraLog -Action 'GIT_STATUS' -Message 'git status --short --branch'
    git status --short --branch
}

function Invoke-AuraCheckpoint {
    Write-AuraLog -Action 'CHECKPOINT' -Message 'local checkpoint requested; no push will be performed'
    Write-Host 'Aura checkpoint (local only; no auto-push).'
    git status --short --branch
    Write-Host "Git push allowed: $($script:Aura.Git.AllowPush)"
    if (-not $script:Aura.Git.AllowPush) { Write-Host 'git push is blocked by permissions.json.' }
}
