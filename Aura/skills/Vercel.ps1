function Get-AuraVercelScope {
    try {
        $who = vercel whoami 2>$null
        if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($who)) { return $who.Trim() }
    } catch { }
    return $null
}

function Test-AuraVercelDomainAccess {
    param([Parameter(Mandatory=$true)][string]$Domain)
    if (Test-AuraPlaceholderUrl -Value $Domain) { return $false }
    try {
        $domains = vercel domains ls 2>$null
        if ($LASTEXITCODE -ne 0) { return $false }
        return (($domains | Out-String) -match [regex]::Escape($Domain))
    } catch { return $false }
}

function Test-AuraVercel {
    $scope = Get-AuraVercelScope
    $domain = [string]$script:Aura.Vercel.RequiredDomain
    $hasDomain = Test-AuraVercelDomainAccess -Domain $domain
    Write-AuraLog -Action 'VERCEL_CHECK' -Message "scope=$scope domain=$domain domainAccess=$hasDomain"
    Write-Host "Vercel scope: $scope"
    Write-Host "Domain access for $domain: $hasDomain"
    Write-Host "Deploy allowed: $($script:Aura.Vercel.AllowDeploy)"
    Write-Host "Alias allowed: $($script:Aura.Vercel.AllowAlias)"
}

function Invoke-AuraVercelDeploy {
    $domain = [string]$script:Aura.Vercel.RequiredDomain
    if (Test-AuraPlaceholderUrl -Value $domain) {
        Write-AuraLog -Action 'VERCEL_DEPLOY_BLOCKED' -Message 'placeholder domain blocked'
        Write-Host 'Blocked: placeholder Vercel domain detected.'
        return
    }
    $scope = Get-AuraVercelScope
    $hasDomain = Test-AuraVercelDomainAccess -Domain $domain
    if (-not $hasDomain) {
        Write-AuraLog -Action 'VERCEL_DEPLOY_BLOCKED' -Message "domain access missing for $domain scope=$scope"
        Write-Host "Blocked: current Vercel scope cannot confirm access to $domain."
        return
    }
    if ($script:Aura.DryRun -or -not $script:Aura.Vercel.AllowDeploy) {
        Write-AuraLog -Action 'VERCEL_DEPLOY_DRYRUN' -Message "DryRun=$($script:Aura.DryRun) AllowDeploy=$($script:Aura.Vercel.AllowDeploy)"
        Write-Host 'DryRun/block: vercel deploy would run only when DryRun=false and AllowVercelDeploy=true.'
        return
    }
    Write-AuraLog -Action 'VERCEL_DEPLOY' -Message "scope=$scope domain=$domain"
    vercel deploy --prod
}
