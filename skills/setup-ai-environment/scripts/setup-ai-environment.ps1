[CmdletBinding()]
param(
    [string]$ProjectRoot = (Get-Location).Path,
    [string]$AiRepositoryUrl = "",
    [string]$DefaultBranch = "main",
    [string]$InitialCommitMessage = "chore: initialize AI project environment",
    [switch]$RegisterLocalAiSubmodule,
    [switch]$SkipInitialCommit
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($DefaultBranch)) {
    throw "DefaultBranch cannot be empty"
}

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

function Initialize-GitRepository {
    param([string]$Path = "")

    $prefix = @()
    if (-not [string]::IsNullOrWhiteSpace($Path)) {
        $prefix = @("-C", $Path)
    }

    & git @prefix init "--initial-branch=$DefaultBranch"
    if ($LASTEXITCODE -eq 0) {
        return
    }

    Write-Step "Git does not support init --initial-branch; falling back to branch rename"
    $initArgs = $prefix + @("init")
    $renameArgs = $prefix + @("branch", "-M", $DefaultBranch)
    Run-Git @initArgs
    Run-Git @renameArgs
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

function Remove-Line {
    param(
        [string]$Path,
        [string]$Line
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }

    $content = Get-Content -LiteralPath $Path -ErrorAction SilentlyContinue
    $filtered = @($content | Where-Object { $_ -ne $Line })
    if ($filtered.Count -ne $content.Count) {
        Set-Content -LiteralPath $Path -Value $filtered
    }
}

function Get-GitOriginUrl {
    param([string]$Path)

    $origin = & git -C $Path remote get-url origin 2>$null
    if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($origin)) {
        return $origin.Trim()
    }

    return ""
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
            $currentTarget = $item.Target
            if ($currentTarget -is [array]) {
                $currentTarget = $currentTarget[0]
            }

            $resolvedCurrentTarget = ""
            if (-not [string]::IsNullOrWhiteSpace($currentTarget) -and (Test-Path -LiteralPath $currentTarget)) {
                $resolvedCurrentTarget = (Resolve-Path -LiteralPath $currentTarget).Path
            }

            if ($resolvedCurrentTarget -eq $resolvedTarget) {
                Write-Step "Link already exists: $LinkPath"
                return
            }

            Remove-Item -LiteralPath $LinkPath -Force
            Write-Step "Removed link with unexpected target $LinkPath -> $currentTarget"
        }
        else {
            throw "$LinkPath already exists and is not a link. Move it aside before running this setup."
        }
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
        '`.ai-overlay` is the project-specific AI context directory.',
        '`.codex`, `.claude`, and `.agents` point to `.ai`.',
        'Project-specific AI assets must live in `.ai-overlay` unless the user explicitly asks to change `.ai`.',
        'Shared agents must live in `.ai/agents`.',
        'Prompt source files are immutable and versioned under `.ai/prompts/registry`.'
    )

    $text = Get-Content -LiteralPath $Path -Raw
    foreach ($snippet in $required) {
        if (-not $text.Contains($snippet)) {
            throw "AGENTS.md exists but is missing required assertion: $snippet. Choose a setup decision before continuing: merge canonical assertions into the existing file, replace it with the canonical seed, or restructure existing project documentation and source layout first."
        }
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

Shared rules, skills, commands, agents, templates, prompts, and MCP assets live here. Root `.codex`, `.claude`, and `.agents` links point to this directory.
'@ | Set-Content -LiteralPath $readmePath -Encoding UTF8
}

function Ensure-AiSubmodule {
    param([string]$Root)

    $aiPath = Join-Path $Root ".ai"
    $gitModulesPath = Join-Path $Root ".gitmodules"
    $gitIgnorePath = Join-Path $Root ".gitignore"

    if (-not (Test-Path -LiteralPath $aiPath)) {
        if ([string]::IsNullOrWhiteSpace($AiRepositoryUrl)) {
            throw ".ai must exist before setup. Clone, download, or provide -AiRepositoryUrl."
        }
        else {
            Run-Git @("submodule", "add", $AiRepositoryUrl, ".ai")
            return $true
        }
    }

    if (-not (Test-Path -LiteralPath (Join-Path $aiPath ".git"))) {
        Write-Step ".ai is a local copied context without Git metadata; ignoring it in the root repository"
        Ensure-Line $gitIgnorePath ".ai/"
        return $false
    }

    Ensure-AiReadme $aiPath

    $aiHasHead = Test-GitOk @("-C", $aiPath, "rev-parse", "--verify", "HEAD")
    if (-not $aiHasHead) {
        Write-Step "Creating initial commit in .ai repository"
        Run-Git @("-C", $aiPath, "add", "-A")
        Run-Git @("-C", $aiPath, "commit", "-m", "chore: initialize AI context")
    }

    $url = $AiRepositoryUrl
    if ([string]::IsNullOrWhiteSpace($url)) {
        $url = Get-GitOriginUrl $aiPath
    }

    if ([string]::IsNullOrWhiteSpace($url)) {
        if (-not $RegisterLocalAiSubmodule) {
            Write-Step ".ai is a Git repository without remote origin; ignoring it in the root repository"
            Ensure-Line $gitIgnorePath ".ai/"
            return $false
        }

        Write-Step ".ai is a Git repository without remote origin; registering it as a local submodule"
        $url = "./.ai"
    }

    Remove-Line $gitIgnorePath ".ai/"
    Run-Git @("config", "-f", $gitModulesPath, "submodule..ai.path", ".ai")
    Run-Git @("config", "-f", $gitModulesPath, "submodule..ai.url", $url)
    Run-Git @("add", ".gitignore", ".gitmodules", ".ai")
    return $true
}

$root = (Resolve-Path -LiteralPath $ProjectRoot).Path
$originalLocation = (Get-Location).Path
Set-Location -LiteralPath $root

try {
Write-Step "Configuring $root"

if (-not (Test-GitOk @("rev-parse", "--is-inside-work-tree"))) {
    Write-Step "Initializing root Git repository"
    Initialize-GitRepository
}

$aiRoot = Join-Path $root ".ai"
if (-not (Test-Path -LiteralPath $aiRoot)) {
    if ([string]::IsNullOrWhiteSpace($AiRepositoryUrl)) {
        throw ".ai must exist before setup. Clone, download, or provide -AiRepositoryUrl."
    }

    Run-Git @("submodule", "add", $AiRepositoryUrl, ".ai")
}

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

$aiOverlayRoot = Join-Path $root ".ai-overlay"
Ensure-Directory $aiOverlayRoot
Copy-SeedIfMissing "AI_OVERLAY_README.md" (Join-Path $aiOverlayRoot "README.md")

$gitIgnorePath = Join-Path $root ".gitignore"
Ensure-AgentsFile (Join-Path $root "AGENTS.md")
Copy-SeedIfMissing "CLAUDE.md" (Join-Path $root "CLAUDE.md")
Copy-SeedIfMissing ".gitignore" $gitIgnorePath
Ensure-Line $gitIgnorePath ".codex/"
Ensure-Line $gitIgnorePath ".claude/"
Ensure-Line $gitIgnorePath ".agents/"

New-DirectoryLink (Join-Path $root ".codex") $aiRoot
New-DirectoryLink (Join-Path $root ".claude") $aiRoot
New-DirectoryLink (Join-Path $root ".agents") $aiRoot

$aiRegisteredAsSubmodule = Ensure-AiSubmodule $root

if (-not $SkipInitialCommit) {
    $hasHead = Test-GitOk @("rev-parse", "--verify", "HEAD")
    if (-not $hasHead) {
        Write-Step "Creating root initial commit"
        Run-Git @("add", "AGENTS.md", "CLAUDE.md", ".gitignore", ".ai-overlay", "docs", "sources")
        if (Test-Path -LiteralPath ".gitmodules") {
            Run-Git @("add", ".gitmodules")
        }
        if ($aiRegisteredAsSubmodule) {
            Run-Git @("add", ".ai")
        }
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
