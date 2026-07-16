function Test-AuraHttpEndpoint {
    param([Parameter(Mandatory=$true)][string]$Url)
    if (Test-AuraPlaceholderUrl -Value $Url) {
        Write-AuraLog -Action 'HEALTH_BLOCKED' -Message "placeholder URL blocked: $Url"
        return @{ Url = $Url; Ok = $false; StatusCode = $null; Error = 'Placeholder URL blocked' }
    }
    try {
        $response = Invoke-WebRequest -Uri $Url -Method Head -UseBasicParsing -TimeoutSec 15
        return @{ Url = $Url; Ok = ($response.StatusCode -ge 200 -and $response.StatusCode -lt 500); StatusCode = $response.StatusCode; Error = $null }
    } catch {
        return @{ Url = $Url; Ok = $false; StatusCode = $null; Error = $_.Exception.Message }
    }
}

function Invoke-AuraHealth {
    $primary = [string]$script:Aura.Health.PrimaryUrl
    Write-AuraLog -Action 'HEALTH' -Message "checking primary $primary"
    $result = Test-AuraHttpEndpoint -Url $primary
    Write-Host "Primary: $($result.Url) OK=$($result.Ok) Status=$($result.StatusCode) Error=$($result.Error)"
    if (-not $result.Ok) {
        $fallback = [string]$script:Aura.Health.FallbackUrl
        if (-not [string]::IsNullOrWhiteSpace($fallback)) {
            Write-AuraLog -Action 'HEALTH_FALLBACK' -Message "checking fallback $fallback"
            $fallbackResult = Test-AuraHttpEndpoint -Url $fallback
            Write-Host "Fallback: $($fallbackResult.Url) OK=$($fallbackResult.Ok) Status=$($fallbackResult.StatusCode) Error=$($fallbackResult.Error)"
        } else {
            Write-Host 'Fallback: no latest known Vercel production URL configured.'
        }
    }
}
