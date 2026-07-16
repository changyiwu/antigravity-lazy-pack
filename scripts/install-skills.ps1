[CmdletBinding(SupportsShouldProcess)]
param(
    [string[]]$Skill = @(),
    [switch]$All,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$TargetRoot = Join-Path ([Environment]::GetFolderPath('UserProfile')) '.gemini\config\skills'
$SkillMap = [ordered]@{
    'antigravity-install-all' = 'skills\00-install-all'
    'antigravity-notebooklm' = 'skills\01-notebooklm'
    'antigravity-github' = 'skills\02-github'
    'antigravity-firebase' = 'skills\03-firebase'
    'antigravity-draw' = 'skills\04-draw'
    'antigravity-workflow' = 'skills\05-workflow'
    'antigravity-obsidian' = 'skills\06-obsidian'
}

if ($All -and $Skill.Count -gt 0) {
    throw '請使用 -All 或 -Skill，不要同時使用。'
}
if (-not $All -and $Skill.Count -eq 0) {
    throw "請指定 -Skill <名稱>，或使用 -All。可用名稱：$($SkillMap.Keys -join ', ')"
}

$Selected = if ($All) { @($SkillMap.Keys) } else { @($Skill) }
foreach ($Name in $Selected) {
    if (-not $SkillMap.Contains($Name)) {
        throw "未知的 Skill：$Name。可用名稱：$($SkillMap.Keys -join ', ')"
    }
}

if ($PSCmdlet.ShouldProcess($TargetRoot, '建立 AntiGravity 全域 Skill 目錄')) {
    New-Item -ItemType Directory -Force -Path $TargetRoot | Out-Null
}

$Results = foreach ($Name in $Selected) {
    $Source = Join-Path $Root $SkillMap[$Name]
    $Target = Join-Path $TargetRoot $Name

    if (-not (Test-Path -LiteralPath (Join-Path $Source 'SKILL.md'))) {
        throw "來源 Skill 不完整：$Source"
    }

    if ((Test-Path -LiteralPath $Target) -and -not $Force) {
        [pscustomobject]@{ Skill = $Name; Status = '已存在，未覆蓋'; Path = $Target }
        continue
    }

    if ($PSCmdlet.ShouldProcess($Target, "安裝 $Name")) {
        New-Item -ItemType Directory -Force -Path $Target | Out-Null
        Copy-Item -Path (Join-Path $Source '*') -Destination $Target -Recurse -Force
    }
    $Status = if ($WhatIfPreference) {
        '模擬，未寫入'
    } elseif ($Force) {
        '已安裝／更新'
    } else {
        '已安裝'
    }
    [pscustomobject]@{ Skill = $Name; Status = $Status; Path = $Target }
}

$Results | Format-Table -AutoSize
