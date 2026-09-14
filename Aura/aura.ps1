Set-StrictMode -Version 2.0

$AuraRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigPath = Join-Path $AuraRoot 'config\aura.json'
$PermissionsPath = Join-Path $AuraRoot 'config\permissions.json'
$SkillsPath = Join-Path $AuraRoot 'skills'
$LogsPath = Join-Path $AuraRoot 'logs'
$LogPath = Join-Path $LogsPath 'aura-runtime.log'

if (-not (Test-Path $LogsPath)) { New-Item -ItemType Directory -Path $LogsPath -Force | Out-Null }

function Read-AuraJsonFile {
    param([Parameter(Mandatory=$true)][string]$Path)
    if (-not (Test-Path $Path)) { throw "Missing Aura configuration file: $Path" }
    $raw = Get-Content -Path $Path -Raw
    return ($raw | ConvertFrom-Json)
}

function Write-AuraLog {
    param(
        [Parameter(Mandatory=$true)][string]$Action,
        [string]$Message = ''
    )
    $timestamp = (Get-Date).ToString('s')
    $line = "[$timestamp] $Action $Message".Trim()
    Add-Content -Path $script:Aura.Logs.RuntimeLog -Value $line
}

function Test-AuraPlaceholderUrl {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return $false }
    return ($Value -match '^(NEW|PASTE|YOUR|HERE)-' -or $Value -match '(NEW-|PASTE-|YOUR-|HERE)')
}

$config = Read-AuraJsonFile -Path $ConfigPath
$permissions = Read-AuraJsonFile -Path $PermissionsPath

$script:Aura = [ordered]@{
    Root = $AuraRoot
    Config = $config
    Permissions = $permissions
    DryRun = [bool]$config.DryRun
    Git = [ordered]@{ AllowPush = [bool]$permissions.AllowGitPush }
    Vercel = [ordered]@{
        AllowDeploy = [bool]$permissions.AllowVercelDeploy
        AllowAlias = [bool]$permissions.AllowVercelAlias
        RequiredDomain = [string]$config.RequiredDomain
        PrimaryHealthUrl = [string]$config.PrimaryHealthUrl
        LatestKnownProductionUrl = [string]$config.LatestKnownVercelProductionUrl
    }
    Health = [ordered]@{
        PrimaryUrl = [string]$config.PrimaryHealthUrl
        FallbackUrl = [string]$config.LatestKnownVercelProductionUrl
    }
    Skygrid = [ordered]@{
        Product = [string]$config.Product
        Description = [string]$config.Description
    }
    Logs = [ordered]@{ Directory = $LogsPath; RuntimeLog = $LogPath }
}
$global:Aura = $script:Aura

Get-ChildItem -Path $SkillsPath -Filter '*.ps1' | Sort-Object Name | ForEach-Object { . $_.FullName }

function Invoke-Aura {
    param([Parameter(Mandatory=$true, Position=0)][string]$Command)

    $normalized = $Command.Trim().ToLowerInvariant()
    Write-AuraLog -Action 'COMMAND' -Message $Command

    switch ($normalized) {
        'status' { Invoke-AuraStatus; break }
        'git status' { Invoke-AuraGitStatus; break }
        'checkpoint' { Invoke-AuraCheckpoint; break }
        'check vercel' { Test-AuraVercel; break }
        'deploy vercel' { Invoke-AuraVercelDeploy; break }
        'health' { Invoke-AuraHealth; break }
        'where are we' { Invoke-AuraWhereAreWe; break }
        default {
            Write-AuraLog -Action 'UNKNOWN' -Message $Command
            Write-Host "Unknown Aura command: $Command"
            Write-Host 'Available: status, git status, checkpoint, check vercel, deploy vercel, health, where are we'
        }
    }
}

Write-AuraLog -Action 'LOAD' -Message "Aura runtime loaded from $AuraRoot (DryRun=$($script:Aura.DryRun))"
Write-Host "Aura runtime loaded. DryRun=$($script:Aura.DryRun). Use Invoke-Aura `"where are we`"."
