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

$Expected = [ordered]@{
    '00-一次安裝全部.md' = 'antigravity-install-all'
    '01-連接-NotebookLM.md' = 'antigravity-notebooklm'
    '02-連接-GitHub.md' = 'antigravity-github'
    '03-連接-Firebase.md' = 'antigravity-firebase'
    '04-用Antigravity生圖.md' = 'antigravity-draw'
    '05-設定專案工作流程.md' = 'antigravity-workflow'
    '06-連接-Obsidian.md' = 'antigravity-obsidian'
}

foreach ($Chapter in $Expected.Keys) {
    if (-not (Test-Path -LiteralPath (Join-Path $Root $Chapter))) {
        Add-Failure "缺少說明檔：$Chapter"
    }
}

$NumberedChapters = Get-ChildItem -LiteralPath $Root -File -Filter '*.md' |
    Where-Object { $_.Name -match '^(?<number>0[0-6])-' }
$DuplicateNumbers = $NumberedChapters |
    Group-Object { [regex]::Match($_.Name, '^(0[0-6])-').Groups[1].Value } |
    Where-Object Count -gt 1
foreach ($Group in $DuplicateNumbers) {
    Add-Failure "章號重複：$($Group.Name) -> $($Group.Group.Name -join ', ')"
}

$SkillFiles = Get-ChildItem -LiteralPath (Join-Path $Root 'skills') -Recurse -File -Filter 'SKILL.md'
if ($SkillFiles.Count -ne $Expected.Count) {
    Add-Failure "功能 Skill 數量應為 $($Expected.Count)，實際為 $($SkillFiles.Count)"
}

$SkillNames = [System.Collections.Generic.List[string]]::new()
foreach ($SkillFile in $SkillFiles) {
    $Content = Get-Content -Raw -Encoding UTF8 -LiteralPath $SkillFile.FullName
    $Relative = Get-RelativePath $SkillFile.FullName
    $Frontmatter = [regex]::Match($Content, '(?s)\A---\s*\r?\n(?<body>.*?)\r?\n---')
    if (-not $Frontmatter.Success) {
        Add-Failure "Skill 缺少 YAML frontmatter：$Relative"
        continue
    }

    $Body = $Frontmatter.Groups['body'].Value
    $NameMatch = [regex]::Match($Body, '(?m)^name:\s*(?<name>[a-z0-9-]+)\s*$')
    if (-not $NameMatch.Success) {
        Add-Failure "Skill 缺少合法 name：$Relative"
        continue
    }
    if ($Body -notmatch '(?m)^description:\s*\S') {
        Add-Failure "Skill 缺少 description：$Relative"
    }
    $SkillNames.Add($NameMatch.Groups['name'].Value)
}

foreach ($Name in $Expected.Values) {
    if ($Name -notin $SkillNames) {
        Add-Failure "說明檔缺少對應 Skill：$Name"
    }
}
foreach ($Duplicate in ($SkillNames | Group-Object | Where-Object Count -gt 1)) {
    Add-Failure "Skill name 重複：$($Duplicate.Name)"
}

$TextExtensions = @('.md', '.py', '.ps1', '.yml', '.yaml', '.json')
$TextFiles = Get-ChildItem -LiteralPath $Root -Recurse -File |
    Where-Object { $_.Extension -in $TextExtensions -and $_.FullName -notmatch '[\\/]\.git[\\/]' }

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
        foreach ($Match in [regex]::Matches($Content, '\[[^\]]*\]\((?<target>[^)]+\.md)(?:#[^)]*)?\)')) {
            $Target = $Match.Groups['target'].Value.Trim('<', '>')
            if ($Target -match '^(?:https?://|mailto:|/)') {
                continue
            }
            $Resolved = Join-Path $File.DirectoryName ([uri]::UnescapeDataString($Target))
            if (-not (Test-Path -LiteralPath $Resolved)) {
                Add-Failure "失效的 Markdown 連結：$Relative -> $Target"
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

$Python = Get-Command python -ErrorAction SilentlyContinue
if (-not $Python) {
    Add-Failure '找不到 python，無法驗證 draw_openai.py'
} else {
    $DrawScript = Join-Path $Root 'skills/04-draw/scripts/draw_openai.py'
    & $Python.Source -c "import ast, pathlib; ast.parse(pathlib.Path(r'$DrawScript').read_text(encoding='utf-8'))"
    if ($LASTEXITCODE -ne 0) {
        Add-Failure 'draw_openai.py Python AST 驗證失敗'
    }
    & $Python.Source $DrawScript --help | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Add-Failure 'draw_openai.py --help 驗證失敗'
    }
}

if ($Failures.Count -gt 0) {
    Write-Host "Validation failed with $($Failures.Count) issue(s):" -ForegroundColor Red
    foreach ($Failure in $Failures) {
        Write-Host "- $Failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'Validation passed: chapters, links, Skill mapping, fixed rules, paths, safety patterns, UTF-8 text, and Python script are valid.' -ForegroundColor Green
