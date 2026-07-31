[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [string[]]$Skill = @(),
    [switch]$All,
    [switch]$Force,
    [switch]$MigrateLegacy
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$TargetRoot = Join-Path ([Environment]::GetFolderPath('UserProfile')) '.gemini\config\skills'
$ManifestPath = Join-Path $PSScriptRoot 'skill-manifest.psd1'
$Manifest = Import-PowerShellDataFile -LiteralPath $ManifestPath
$SkillMap = [ordered]@{}
foreach ($Entry in @($Manifest.Skills)) {
    if ($SkillMap.Contains($Entry.Name)) {
        throw "Skill manifest 名稱重複：$($Entry.Name)"
    }
    $SkillMap[$Entry.Name] = $Entry
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

$Results = foreach ($Name in $Selected) {
    $Entry = $SkillMap[$Name]
    $Source = Join-Path $Root $Entry.Source
    $Target = Join-Path $TargetRoot $Name
    $LegacyNames = if ($Entry.ContainsKey('LegacyNames')) { @($Entry.LegacyNames) } else { @() }
    $LegacyTargets = @(
        foreach ($LegacyName in $LegacyNames) {
            $LegacyTarget = Join-Path $TargetRoot $LegacyName
            if (Test-Path -LiteralPath $LegacyTarget) {
                $LegacyTarget
            }
        }
    )

    if (-not (Test-Path -LiteralPath (Join-Path $Source 'SKILL.md'))) {
        throw "來源 Skill 不完整：$Source"
    }

    if ($LegacyTargets.Count -gt 0 -and -not $MigrateLegacy) {
        [pscustomobject]@{
            Skill = $Name
            Status = '偵測到舊名稱，未安裝；確認後使用 -MigrateLegacy'
            Path = $Target
            Legacy = $LegacyTargets -join ', '
        }
        continue
    }

    $TargetReady = $false
    $Status = $null
    if ((Test-Path -LiteralPath $Target) -and -not $Force) {
        $InstalledSkill = Join-Path $Target 'SKILL.md'
        if (-not (Test-Path -LiteralPath $InstalledSkill)) {
            [pscustomobject]@{ Skill = $Name; Status = '目標已存在但缺少 SKILL.md，未處理'; Path = $Target; Legacy = '' }
            continue
        }
        $InstalledContent = Get-Content -Raw -Encoding UTF8 -LiteralPath $InstalledSkill
        if ($InstalledContent -notmatch "(?m)^name:\s*$([regex]::Escape($Name))\s*$") {
            [pscustomobject]@{ Skill = $Name; Status = '目標已存在但 name 不符，未處理'; Path = $Target; Legacy = '' }
            continue
        }
        $TargetReady = $true
        $Status = '已存在，未覆蓋'
    } else {
        $Approved = $PSCmdlet.ShouldProcess($Target, "安裝 $Name")
        if ($Approved) {
            New-Item -ItemType Directory -Force -Path $TargetRoot | Out-Null
            New-Item -ItemType Directory -Force -Path $Target | Out-Null
            Copy-Item -Path (Join-Path $Source '*') -Destination $Target -Recurse -Force
            $TargetReady = $true
        }
        $Status = if ($WhatIfPreference) {
            '模擬，未寫入'
        } elseif (-not $Approved) {
            '使用者跳過'
        } elseif ($Force) {
            '已安裝／更新'
        } else {
            '已安裝'
        }
    }

    $LegacyStatus = ''
    if ($MigrateLegacy -and $TargetReady -and $LegacyTargets.Count -gt 0) {
        $LegacyResults = foreach ($LegacyTarget in $LegacyTargets) {
            $LegacyApproved = $PSCmdlet.ShouldProcess($LegacyTarget, "移除已由 $Name 取代的舊版 Skill")
            if ($LegacyApproved) {
                Remove-Item -LiteralPath $LegacyTarget -Recurse -Force
                "已移除：$LegacyTarget"
            } else {
                "未移除：$LegacyTarget"
            }
        }
        $LegacyStatus = $LegacyResults -join '; '
    }
    [pscustomobject]@{ Skill = $Name; Status = $Status; Path = $Target; Legacy = $LegacyStatus }
}

$Results | Format-Table -AutoSize
