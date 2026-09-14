function Invoke-AuraWhereAreWe {
    Write-AuraLog -Action 'WHERE_ARE_WE' -Message $script:Aura.Skygrid.Product
    Write-Host $script:Aura.Skygrid.Product
    Write-Host $script:Aura.Skygrid.Description
    Write-Host "Root: $($script:Aura.Root)"
    Write-Host "DryRun: $($script:Aura.DryRun)"
    Write-Host "Log: $($script:Aura.Logs.RuntimeLog)"
}

function Invoke-AuraStatus {
    Write-AuraLog -Action 'STATUS' -Message 'runtime status requested'
    Invoke-AuraWhereAreWe
    Write-Host "Git push allowed: $($script:Aura.Git.AllowPush)"
    Write-Host "Vercel deploy allowed: $($script:Aura.Vercel.AllowDeploy)"
    Write-Host "Vercel alias allowed: $($script:Aura.Vercel.AllowAlias)"
}
