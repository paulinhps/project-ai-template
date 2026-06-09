[CmdletBinding()]
param(
    [string]$ProjectRoot = (Get-Location).Path,
    [string]$AiRepositoryUrl = "",
    [string]$OpenSpecTools = "codex,claude",
    [string]$InitialCommitMessage = "chore: initialize AI project environment",
    [switch]$SkipInitialCommit
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SkillRoot = Split-Path -Parent $PSScriptRoot
$SeedRoot = Join-Path $SkillRoot "assets\seeds"

function Write-Step {
    param([string]$Message)
    Write-Host "[ai-setup] $Message"
}

function Run-Git {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Arguments
    )
    & git @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed with exit code $LASTEXITCODE"
    }
}

function Test-GitOk {
    param([string[]]$Arguments)
    & git @Arguments *> $null
    return $LASTEXITCODE -eq 0
}

function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

function Ensure-Line {
    param(
        [string]$Path,
        [string]$Line
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType File -Path $Path | Out-Null
    }

    $content = Get-Content -LiteralPath $Path -ErrorAction SilentlyContinue
    if ($content -notcontains $Line) {
        Add-Content -LiteralPath $Path -Value $Line
    }
}

function Copy-SeedIfMissing {
    param(
        [string]$SeedName,
        [string]$DestinationPath
    )

    if (Test-Path -LiteralPath $DestinationPath) {
        return
    }

    $seedPath = Join-Path $SeedRoot $SeedName
    if (-not (Test-Path -LiteralPath $seedPath)) {
        throw "Missing seed file: $seedPath"
    }

    Copy-Item -LiteralPath $seedPath -Destination $DestinationPath
    Write-Step "Created $(Split-Path -Leaf $DestinationPath) from seed"
}

function New-DirectoryLink {
    param(
        [string]$LinkPath,
        [string]$TargetPath
    )

    $resolvedTarget = (Resolve-Path -LiteralPath $TargetPath).Path

    if (Test-Path -LiteralPath $LinkPath) {
        $item = Get-Item -LiteralPath $LinkPath -Force
        if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
            Write-Step "Link already exists: $LinkPath"
            return
        }

        throw "$LinkPath already exists and is not a link. Move it aside before running this setup."
    }

    try {
        New-Item -ItemType SymbolicLink -Path $LinkPath -Target $resolvedTarget -ErrorAction Stop | Out-Null
        Write-Step "Created symbolic link $LinkPath -> $resolvedTarget"
    }
    catch {
        New-Item -ItemType Junction -Path $LinkPath -Target $resolvedTarget -ErrorAction Stop | Out-Null
        Write-Step "Created junction fallback $LinkPath -> $resolvedTarget"
    }
}

function Ensure-AgentsFile {
    param([string]$Path)

    Copy-SeedIfMissing "AGENTS.md" $Path

    $required = @(
        '`.ai` is the canonical AI context directory.',
        '`.codex` and `.claude` point to `.ai`.',
        '`.agents` points to `.ai/agents`.',
        'Shared agents must live in `.ai/agents`.',
        'Prompt source files are immutable and versioned under `.ai/prompts/registry`.'
    )

    $text = Get-Content -LiteralPath $Path -Raw
    foreach ($snippet in $required) {
        if (-not $text.Contains($snippet)) {
            throw "AGENTS.md exists but is missing required assertion: $snippet"
        }
    }
}

function Ensure-OpenSpec {
    param([string]$Root)

    $openSpecPath = Join-Path $Root "openspec"
    if (Test-Path -LiteralPath $openSpecPath) {
        Write-Step "OpenSpec structure already exists"
        return
    }

    $command = Get-Command openspec -ErrorAction SilentlyContinue
    if (-not $command) {
        throw "OpenSpec is not available. Install or approve: npm install -g @fission-ai/openspec@latest"
    }

    Write-Step "Initializing OpenSpec"
    & openspec init --tools $OpenSpecTools .
    if ($LASTEXITCODE -ne 0) {
        throw "openspec init failed with exit code $LASTEXITCODE"
    }
}

function Ensure-AiReadme {
    param([string]$AiPath)

    $readmePath = Join-Path $AiPath "README.md"
    if (Test-Path -LiteralPath $readmePath) {
        return
    }

    @'
# AI Context

This directory is the canonical AI context for the project.

Shared rules, skills, commands, agents, templates, prompts, and MCP assets live here. Root `.codex` and `.claude` links point to this directory. Root `.agents` points to `.ai/agents`.
'@ | Set-Content -LiteralPath $readmePath -Encoding UTF8
}

function Ensure-AiSubmodule {
    param([string]$Root)

    $aiPath = Join-Path $Root ".ai"
    $gitModulesPath = Join-Path $Root ".gitmodules"

    if (-not (Test-Path -LiteralPath $aiPath)) {
        if ([string]::IsNullOrWhiteSpace($AiRepositoryUrl)) {
            Ensure-Directory $aiPath
            Run-Git @("-C", $aiPath, "init")
        }
        else {
            Run-Git @("submodule", "add", $AiRepositoryUrl, ".ai")
            return
        }
    }

    if (-not (Test-Path -LiteralPath (Join-Path $aiPath ".git"))) {
        Run-Git @("-C", $aiPath, "init")
    }

    Ensure-AiReadme $aiPath

    $aiHasHead = Test-GitOk @("-C", $aiPath, "rev-parse", "--verify", "HEAD")
    if (-not $aiHasHead) {
        Write-Step "Creating initial commit in .ai repository"
        Run-Git @("-C", $aiPath, "add", "-A")
        Run-Git @("-C", $aiPath, "commit", "-m", "chore: initialize AI context")
    }

    $url = $AiRepositoryUrl
    if ([string]::IsNullOrWhiteSpace($url) -and (Test-Path -LiteralPath $gitModulesPath)) {
        $existingUrl = & git config -f $gitModulesPath --get submodule..ai.url
        if ($LASTEXITCODE -eq 0) {
            $url = $existingUrl
        }
    }
    if ([string]::IsNullOrWhiteSpace($url)) {
        $url = "./.ai"
    }

    Run-Git @("config", "-f", $gitModulesPath, "submodule..ai.path", ".ai")
    Run-Git @("config", "-f", $gitModulesPath, "submodule..ai.url", $url)
    Run-Git @("add", ".gitmodules", ".ai")
}

$root = (Resolve-Path -LiteralPath $ProjectRoot).Path
$originalLocation = (Get-Location).Path
Set-Location -LiteralPath $root

try {
Write-Step "Configuring $root"

if (-not (Test-GitOk @("rev-parse", "--is-inside-work-tree"))) {
    Write-Step "Initializing root Git repository"
    Run-Git init
}

$aiRoot = Join-Path $root ".ai"
Ensure-Directory $aiRoot

$aiDirs = @(
    "agents",
    "claude/overrides",
    "codex/overrides",
    "commands",
    "mcp",
    "prompts/registry",
    "rules",
    "skills",
    "templates"
)
foreach ($dir in $aiDirs) {
    Ensure-Directory (Join-Path $aiRoot $dir)
}

$rootDirs = @(
    "docs/adr",
    "docs/architecture",
    "docs/business",
    "docs/decisions",
    "docs/engineering",
    "docs/product",
    "docs/references",
    "docs/requirements",
    "docs/specs",
    "sources"
)
foreach ($dir in $rootDirs) {
    Ensure-Directory (Join-Path $root $dir)
}

$gitIgnorePath = Join-Path $root ".gitignore"
Ensure-AgentsFile (Join-Path $root "AGENTS.md")
Copy-SeedIfMissing ".gitignore" $gitIgnorePath
Ensure-Line $gitIgnorePath ".codex/"
Ensure-Line $gitIgnorePath ".claude/"
Ensure-Line $gitIgnorePath ".agents/"

New-DirectoryLink (Join-Path $root ".codex") $aiRoot
New-DirectoryLink (Join-Path $root ".claude") $aiRoot
New-DirectoryLink (Join-Path $root ".agents") (Join-Path $aiRoot "agents")

Ensure-OpenSpec $root
Ensure-AiSubmodule $root

if (-not $SkipInitialCommit) {
    $hasHead = Test-GitOk @("rev-parse", "--verify", "HEAD")
    if (-not $hasHead) {
        Write-Step "Creating root initial commit"
        Run-Git @("add", "AGENTS.md", ".gitignore", ".gitmodules", "docs", "sources", "openspec", ".ai")
        Run-Git @("commit", "-m", $InitialCommitMessage)
    }
    else {
        Write-Step "Root repository already has commits; leaving commit creation to the user"
    }
}

Write-Step "Done"
Run-Git @("status", "--short")
}
finally {
    Set-Location -LiteralPath $originalLocation
}
