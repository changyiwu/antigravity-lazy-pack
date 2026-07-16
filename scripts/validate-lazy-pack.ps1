[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$Failures = [System.Collections.Generic.List[string]]::new()

function Add-Failure {
    param([Parameter(Mandatory)][string]$Message)
    $Failures.Add($Message)
}

function Get-RelativePath {
    param([Parameter(Mandatory)][string]$Path)
    if ($Path.StartsWith($Root, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $Path.Substring($Root.Length).TrimStart('\', '/')
    }
    return $Path
}

function Test-SkillFile {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$ExpectedName
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        Add-Failure "缺少 Skill：$(Get-RelativePath $Path)"
        return
    }

    $Content = Get-Content -Raw -Encoding UTF8 -LiteralPath $Path
    $Relative = Get-RelativePath $Path
    $Frontmatter = [regex]::Match($Content, '(?s)\A---\s*\r?\n(?<body>.*?)\r?\n---')
    if (-not $Frontmatter.Success) {
        Add-Failure "Skill 缺少 YAML frontmatter：$Relative"
        return
    }

    $Body = $Frontmatter.Groups['body'].Value
    $NameMatch = [regex]::Match($Body, '(?m)^name:\s*(?<name>[a-z0-9-]+)\s*$')
    if (-not $NameMatch.Success) {
        Add-Failure "Skill 缺少合法 name：$Relative"
    } elseif ($NameMatch.Groups['name'].Value -ne $ExpectedName) {
        Add-Failure "Skill name 與 manifest 不一致：$Relative -> $($NameMatch.Groups['name'].Value)，預期 $ExpectedName"
    }
    if ($Body -notmatch '(?m)^description:\s*\S') {
        Add-Failure "Skill 缺少 description：$Relative"
    }
}

$ExpectedChapters = [ordered]@{
    '00-一次安裝全部.md' = $null
    '01-連接-NotebookLM.md' = [pscustomobject]@{ Name = 'antigravity-notebooklm'; Source = 'skills\01-notebooklm' }
    '02-連接-GitHub.md' = [pscustomobject]@{ Name = 'antigravity-github'; Source = 'skills\02-github' }
    '03-連接-Firebase.md' = [pscustomobject]@{ Name = 'antigravity-firebase'; Source = 'skills\03-firebase' }
    '04-用Antigravity生圖.md' = [pscustomobject]@{ Name = 'antigravity-draw'; Source = 'skills\04-draw' }
    '05-設定專案工作流程.md' = [pscustomobject]@{ Name = 'antigravity-workflow'; Source = 'skills\05-workflow' }
    '06-連接-Obsidian.md' = [pscustomobject]@{ Name = 'antigravity-obsidian'; Source = 'skills\06-obsidian' }
}
$ExpectedSkills = @($ExpectedChapters.Values | Where-Object { $null -ne $_ })

foreach ($Chapter in $ExpectedChapters.Keys) {
    if (-not (Test-Path -LiteralPath (Join-Path $Root $Chapter))) {
        Add-Failure "缺少說明檔：$Chapter"
    }
}

$NumberedChapters = Get-ChildItem -LiteralPath $Root -File -Filter '*.md' |
    Where-Object { $_.Name -match '^\d{2}-' }
foreach ($Chapter in $NumberedChapters) {
    if ($Chapter.Name -notin $ExpectedChapters.Keys) {
        Add-Failure "發現未登記的章節：$($Chapter.Name)"
    }
}
$DuplicateNumbers = $NumberedChapters |
    Group-Object { [regex]::Match($_.Name, '^(\d{2})-').Groups[1].Value } |
    Where-Object Count -gt 1
foreach ($Group in $DuplicateNumbers) {
    Add-Failure "章號重複：$($Group.Name) -> $($Group.Group.Name -join ', ')"
}

$ManifestPath = Join-Path $Root 'scripts\skill-manifest.psd1'
$ManifestSkills = @()
if (-not (Test-Path -LiteralPath $ManifestPath)) {
    Add-Failure '缺少 scripts\skill-manifest.psd1'
} else {
    try {
        $Manifest = Import-PowerShellDataFile -LiteralPath $ManifestPath
        $ManifestSkills = @($Manifest.Skills)
    } catch {
        Add-Failure "Skill manifest 無法解析：$($_.Exception.Message)"
    }
}

if ($ManifestSkills.Count -ne $ExpectedSkills.Count) {
    Add-Failure "Skill manifest 應有 $($ExpectedSkills.Count) 項，實際為 $($ManifestSkills.Count)"
}
foreach ($ExpectedSkill in $ExpectedSkills) {
    $Matches = @($ManifestSkills | Where-Object { $_.Name -eq $ExpectedSkill.Name })
    if ($Matches.Count -ne 1) {
        Add-Failure "Skill manifest 應且只能包含一次：$($ExpectedSkill.Name)"
        continue
    }
    if ($Matches[0].Source -ne $ExpectedSkill.Source) {
        Add-Failure "Skill manifest 來源錯誤：$($ExpectedSkill.Name) -> $($Matches[0].Source)，預期 $($ExpectedSkill.Source)"
    }
}
foreach ($ManifestSkill in $ManifestSkills) {
    if ($ManifestSkill.Name -notin $ExpectedSkills.Name) {
        Add-Failure "Skill manifest 出現未登記名稱：$($ManifestSkill.Name)"
    }
}

$SkillFiles = @(Get-ChildItem -LiteralPath (Join-Path $Root 'skills') -Recurse -File -Filter 'SKILL.md')
if ($SkillFiles.Count -ne $ExpectedSkills.Count) {
    Add-Failure "功能 Skill 數量應為 $($ExpectedSkills.Count)，實際為 $($SkillFiles.Count)"
}
foreach ($ExpectedSkill in $ExpectedSkills) {
    $SkillPath = Join-Path $Root (Join-Path $ExpectedSkill.Source 'SKILL.md')
    Test-SkillFile -Path $SkillPath -ExpectedName $ExpectedSkill.Name
}
Test-SkillFile -Path (Join-Path $Root 'SKILL.md') -ExpectedName 'antigravity-lazy-packs'

if (Test-Path -LiteralPath (Join-Path $Root 'skills\00-install-all\SKILL.md')) {
    Add-Failure '00 是安裝派送入口，不應再存在 skills\00-install-all\SKILL.md'
}

$TextExtensions = @('.md', '.py', '.ps1', '.psd1', '.yml', '.yaml', '.json')
$SpecialTextNames = @('.gitignore', '.gitattributes', 'LICENSE')
$TextFiles = Get-ChildItem -LiteralPath $Root -Recurse -File |
    Where-Object {
        ($_.Extension -in $TextExtensions -or $_.Name -in $SpecialTextNames) -and
        $_.FullName -notmatch '[\\/]\.git[\\/]'
    }

$RequiredSkillPath = '~/.gemini/config/skills/'
$ForbiddenSkillPaths = @(
    '~/.agents/skills',
    '~/.gemini/skills',
    '~/.gemini/antigravity/skills',
    '~/.gemini/antigravity-cli/skills'
)

foreach ($File in $TextFiles) {
    $Content = Get-Content -Raw -Encoding UTF8 -LiteralPath $File.FullName
    $Relative = Get-RelativePath $File.FullName

    if ($Content.Contains([char]0xfffd)) {
        Add-Failure "發現 Unicode 取代字元：$Relative"
    }
    if ($Content -match '(?m)[\t ]+$') {
        Add-Failure "發現行尾空白：$Relative"
    }
    if ($Content -match '(\r?\n){2,}$') {
        Add-Failure "檔案末尾有多餘空白行：$Relative"
    }
    if ($Relative -ne 'scripts\validate-lazy-pack.ps1') {
        foreach ($Forbidden in $ForbiddenSkillPaths) {
            if ($Content.Contains($Forbidden)) {
                Add-Failure "發現非本專案標準的全域 Skill 路徑 '$Forbidden'：$Relative"
            }
        }
        if ($Content -match '(?im)^(?!.*(?:不要使用|不可使用)).*\bnlm\s+mcp\b') {
            Add-Failure "發現失效的 NotebookLM MCP 子指令：$Relative"
        }
        if ($Content -match '(?i)dall-e(?:\s|-)3') {
            Add-Failure "發現不再建議的舊版 OpenAI 生圖模型：$Relative"
        }
        if ($Content -match '(?i)(sk-[A-Za-z0-9_-]{20,}|AIza[0-9A-Za-z_-]{20,}|gh[pousr]_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{20,}|-----BEGIN [A-Z ]+PRIVATE KEY-----)') {
            Add-Failure "發現疑似敏感資料：$Relative"
        }
    }

    if ($File.Extension -eq '.md') {
        foreach ($Match in [regex]::Matches($Content, '\[[^\]]*\]\((?<target>[^)]+)\)')) {
            $Target = $Match.Groups['target'].Value.Trim('<', '>')
            $TargetWithoutAnchor = $Target.Split('#')[0]
            if (-not $TargetWithoutAnchor -or $TargetWithoutAnchor -match '^(?:https?://|mailto:|/)') {
                continue
            }
            $Resolved = Join-Path $File.DirectoryName ([uri]::UnescapeDataString($TargetWithoutAnchor))
            if (-not (Test-Path -LiteralPath $Resolved)) {
                Add-Failure "失效的 Markdown 連結：$Relative -> $Target"
            }
        }

        foreach ($JsonBlock in [regex]::Matches($Content, '(?ms)^```json\s*\r?\n(?<json>.*?)\r?\n```[ \t]*$')) {
            try {
                $JsonBlock.Groups['json'].Value | ConvertFrom-Json | Out-Null
            } catch {
                Add-Failure "Markdown JSON 範例無法解析：$Relative -> $($_.Exception.Message)"
            }
        }
    }
}

$Rules = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $Root 'ANTIGRAVITY.md')
if ($Rules -notmatch [regex]::Escape('`ANTIGRAVITY.md` 是本專案的主要規則入口')) {
    Add-Failure 'ANTIGRAVITY.md 未宣告自己是主要規則入口'
}
if ($Rules -notmatch [regex]::Escape($RequiredSkillPath)) {
    Add-Failure "ANTIGRAVITY.md 未使用標準全域 Skill 路徑：$RequiredSkillPath"
}

$Readme = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $Root 'README.md')
if ($Readme -notmatch [regex]::Escape('https://github.com/changyiwu/antigravity-lazy-pack')) {
    Add-Failure 'README.md 未使用正式發布入口 changyiwu/antigravity-lazy-pack'
}
if ($Readme -match [regex]::Escape('https://github.com/mathruffian-dot/antigravity-lazy-pack')) {
    Add-Failure 'README.md 仍包含舊的 Antigravity repo 入口'
}

$GitIgnore = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $Root '.gitignore')
foreach ($RequiredIgnore in @('!.env.example', '__pycache__/', '.venv/')) {
    if ($GitIgnore -notmatch "(?m)^$([regex]::Escape($RequiredIgnore))$") {
        Add-Failure ".gitignore 缺少：$RequiredIgnore"
    }
}
foreach ($ForbiddenIgnore in @('package-lock.json', 'pnpm-lock.yaml', '*.png', '*.pdf', '*.docx', '*.pptx')) {
    if ($GitIgnore -match "(?m)^$([regex]::Escape($ForbiddenIgnore))$") {
        Add-Failure ".gitignore 不應全面忽略：$ForbiddenIgnore"
    }
}

foreach ($PowerShellFile in @('scripts\install-skills.ps1', 'scripts\validate-lazy-pack.ps1')) {
    $Tokens = $null
    $ParseErrors = $null
    [System.Management.Automation.Language.Parser]::ParseFile(
        (Join-Path $Root $PowerShellFile),
        [ref]$Tokens,
        [ref]$ParseErrors
    ) | Out-Null
    foreach ($ParseError in @($ParseErrors)) {
        Add-Failure "PowerShell 語法錯誤：$PowerShellFile -> $($ParseError.Message)"
    }
}

$Installer = Join-Path $Root 'scripts\install-skills.ps1'
$InstallerOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $Installer -All -WhatIf 2>&1
if ($LASTEXITCODE -ne 0) {
    Add-Failure 'install-skills.ps1 -All -WhatIf 執行失敗'
} else {
    $InstallerText = $InstallerOutput -join "`n"
    foreach ($ExpectedSkill in $ExpectedSkills) {
        if ($InstallerText -notmatch [regex]::Escape($ExpectedSkill.Name)) {
            Add-Failure "安裝器 -All 未包含：$($ExpectedSkill.Name)"
        }
    }
    if ($InstallerText -match 'antigravity-install-all') {
        Add-Failure '安裝器 -All 不應再安裝 antigravity-install-all'
    }
}

$PythonCommand = $null
$PythonPrefix = @()
foreach ($Candidate in @(
    [pscustomobject]@{ Name = 'python'; Prefix = @() },
    [pscustomobject]@{ Name = 'py'; Prefix = @('-3') }
)) {
    $Command = Get-Command $Candidate.Name -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $Command) {
        continue
    }
    & $Command.Source @($Candidate.Prefix) --version *> $null
    if ($LASTEXITCODE -eq 0) {
        $PythonCommand = $Command.Source
        $PythonPrefix = @($Candidate.Prefix)
        break
    }
}

if (-not $PythonCommand) {
    Add-Failure '找不到可執行的 python 或 py -3，無法驗證 draw_openai.py'
} else {
    $DrawScript = Join-Path $Root 'skills\04-draw\scripts\draw_openai.py'
    & $PythonCommand @PythonPrefix -c "import ast, pathlib, sys; ast.parse(pathlib.Path(sys.argv[1]).read_text(encoding='utf-8'))" $DrawScript
    if ($LASTEXITCODE -ne 0) {
        Add-Failure 'draw_openai.py Python AST 驗證失敗'
    }
    & $PythonCommand @PythonPrefix $DrawScript --help | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Add-Failure 'draw_openai.py --help 驗證失敗'
    }
    $PreviousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & $PythonCommand @PythonPrefix $DrawScript --prompt test --output invalid.jpg --output-format png 2>$null
    $InvalidExtensionExitCode = $LASTEXITCODE
    $ErrorActionPreference = $PreviousErrorActionPreference
    if ($InvalidExtensionExitCode -eq 0) {
        Add-Failure 'draw_openai.py 未拒絕不相符的輸出副檔名'
    }
}

foreach ($RequiredFile in @('LICENSE', '.gitattributes')) {
    if (-not (Test-Path -LiteralPath (Join-Path $Root $RequiredFile))) {
        Add-Failure "缺少發布檔案：$RequiredFile"
    }
}

if ($Failures.Count -gt 0) {
    Write-Host "Validation failed with $($Failures.Count) issue(s):" -ForegroundColor Red
    foreach ($Failure in $Failures) {
        Write-Host "- $Failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'Validation passed: chapters, six Skills, manifest, installer simulation, links, JSON examples, rules, paths, safety patterns, UTF-8 text, PowerShell, Python, license, and release files are valid.' -ForegroundColor Green
