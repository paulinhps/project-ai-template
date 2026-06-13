[CmdletBinding()]
param(
    [string]$ProjectRoot = (Get-Location).Path,
    [string]$AiRepositoryUrl = "",
    [string]$DefaultBranch = "main",
    [string]$InitialCommitMessage = "chore: initialize AI project environment",
    [string]$AiTool = "both",
    [switch]$RegisterLocalAiSubmodule,
    [switch]$SkipInitialCommit
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($DefaultBranch)) {
    throw "DefaultBranch cannot be empty"
}

$SkillRoot = Split-Path -Parent $PSScriptRoot
$AssetRoot = Join-Path $SkillRoot "assets"
$SeedRoot = Join-Path $AssetRoot "seeds"
$TemplateRoot = Join-Path $AssetRoot "templates"
$ProfileRoot = Join-Path $AssetRoot "tool-profiles"

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
    Run-Git @($prefix + @("init"))
    Run-Git @($prefix + @("branch", "-M", $DefaultBranch))
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

function Render-Template {
    param(
        [string]$TemplateName,
        [hashtable]$Values
    )

    $templatePath = Join-Path $TemplateRoot $TemplateName
    if (-not (Test-Path -LiteralPath $templatePath)) {
        throw "Missing template file: $templatePath"
    }

    $rendered = Get-Content -LiteralPath $templatePath -Raw
    foreach ($key in $Values.Keys) {
        $rendered = $rendered.Replace("{{$key}}", [string]$Values[$key])
    }

    return $rendered
}

function Write-Utf8NoBom {
    param(
        [string]$Path,
        [string]$Value
    )

    $encoding = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($Path, $Value, $encoding)
}

function Write-RenderedIfMissing {
    param(
        [string]$TemplateName,
        [string]$DestinationPath,
        [hashtable]$Values
    )

    if (Test-Path -LiteralPath $DestinationPath) {
        return
    }

    $parent = Split-Path -Parent $DestinationPath
    if (-not [string]::IsNullOrWhiteSpace($parent)) {
        Ensure-Directory $parent
    }

    Write-Utf8NoBom $DestinationPath (Render-Template $TemplateName $Values)
    Write-Step "Created $(Split-Path -Leaf $DestinationPath) from template"
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

function Load-ToolProfile {
    param([string]$Id)

    $profilePath = Join-Path $ProfileRoot "$Id.json"
    if (-not (Test-Path -LiteralPath $profilePath)) {
        throw "Unknown AI tool profile '$Id'. Add $profilePath or use codex, claude, or both."
    }

    return Get-Content -LiteralPath $profilePath -Raw | ConvertFrom-Json
}

function Resolve-ActiveProfiles {
    param([string]$RequestedTool)

    if ($RequestedTool -eq "both") {
        $ids = @("codex", "claude")
    }
    else {
        $ids = @($RequestedTool.Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ })
    }

    if ($ids.Count -eq 0) {
        throw "-AiTool cannot be empty. Use codex, claude, or both."
    }

    $seen = @{}
    $profiles = @()
    foreach ($id in $ids) {
        if ($seen.ContainsKey($id)) {
            continue
        }
        $seen[$id] = $true
        $profiles += Load-ToolProfile $id
    }

    return $profiles
}

function Get-AllToolProfiles {
    Get-ChildItem -LiteralPath $ProfileRoot -Filter "*.json" | ForEach-Object {
        Load-ToolProfile $_.BaseName
    }
}

function Get-CanonicalAiDirectories {
    $toolDirs = @(Get-AllToolProfiles | ForEach-Object { "$($_.id)/overrides" })
    return @(
        "agents",
        "commands",
        "mcp",
        "prompts/registry",
        "rules",
        "skills",
        "templates"
    ) + $toolDirs
}

function Get-ActivePointerNames {
    param([object[]]$Profiles)

    return @(".agents") + @($Profiles | ForEach-Object { $_.pointerName })
}

function Get-InitialCommitPaths {
    param([object[]]$Profiles)

    $entrypoints = @($Profiles | ForEach-Object { $_.rootEntrypoint } | Where-Object { $_ -ne "AGENTS.md" })
    return @("AGENTS.md") + $entrypoints + @(".gitignore", ".ai-overlay", "docs", "sources")
}

function Get-RootAgentsValues {
    param([object[]]$Profiles)

    $enabledToolNames = ($Profiles | ForEach-Object { $_.displayName }) -join ", "
    $activatedPointerNames = (Get-ActivePointerNames $Profiles | ForEach-Object { "``$_``" }) -join ", "
    $toolDiscoverySection = ($Profiles | ForEach-Object { "- $($_.displayName): $($_.discoverySummary)" }) -join "`n"
    $toolOverrideSection = ($Profiles | ForEach-Object {
        "- Shared $($_.displayName)-specific behavior must live in ``$($_.overridePath)``.`n- Project-specific $($_.displayName)-specific behavior must live in ``.ai-overlay/$($_.id)/overrides``."
    }) -join "`n"

    return @{
        enabledToolNames = $enabledToolNames
        activatedPointerNames = $activatedPointerNames
        toolDiscoverySection = $toolDiscoverySection
        toolOverrideSection = $toolOverrideSection
    }
}

function Get-EntrypointValues {
    param([object]$Profile)

    $readFirstBullets = ($Profile.readFirst | ForEach-Object { "1. Read ``$_``." }) -join "`n"
    $ruleBullets = ($Profile.rules | ForEach-Object { "- $_" }) -join "`n"

    return @{
        rootEntrypoint = $Profile.rootEntrypoint
        toolName = $Profile.displayName
        readFirstBullets = $readFirstBullets
        ruleBullets = $ruleBullets
        personalConfigGuidance = $Profile.personalConfigGuidance
    }
}

function Ensure-AgentsFile {
    param(
        [string]$Path,
        [object[]]$Profiles
    )

    Write-RenderedIfMissing "root-agents.md.tpl" $Path (Get-RootAgentsValues $Profiles)

    $required = @(
        '`.ai` is the canonical AI context directory.',
        '`.ai-overlay` is the project-specific AI context directory.',
        'Project-specific AI assets must live in `.ai-overlay` unless the user explicitly asks to change `.ai`.',
        'Activated tool pointer paths point to `.ai`',
        'Shared agents must live in `.ai/agents`.',
        'Prompt source files are immutable and versioned under `.ai/prompts/registry`.'
    )

    $text = Get-Content -LiteralPath $Path -Raw
    foreach ($snippet in $required) {
        if (-not $text.Contains($snippet)) {
            throw "AGENTS.md exists but is missing required assertion: $snippet. Choose a setup decision before continuing: merge canonical assertions into the existing file, replace it with the canonical generated file, or restructure existing project documentation and source layout first."
        }
    }
}

function Copy-ToolEntrypoints {
    param([object[]]$Profiles)

    foreach ($profile in $Profiles) {
        if ($profile.rootEntrypoint -eq "AGENTS.md") {
            continue
        }

        Write-RenderedIfMissing "agent-entrypoint.md.tpl" (Join-Path $root $profile.rootEntrypoint) (Get-EntrypointValues $profile)
    }
}

function Ensure-AiReadme {
    param([string]$AiPath)

    $readmePath = Join-Path $AiPath "README.md"
    if (Test-Path -LiteralPath $readmePath) {
        return
    }

    $content = @'
# AI Context

This directory is the canonical AI context for the project.

Shared rules, skills, commands, agents, templates, prompts, and MCP assets live here. Activated root tool pointers point to this directory.
'@
    Write-Utf8NoBom $readmePath $content
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

        Run-Git @("submodule", "add", $AiRepositoryUrl, ".ai")
        return $true
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

$ActiveProfiles = Resolve-ActiveProfiles $AiTool
$root = (Resolve-Path -LiteralPath $ProjectRoot).Path
$originalLocation = (Get-Location).Path
Set-Location -LiteralPath $root

try {
    Write-Step "Configuring $root"
    Write-Step "Activated AI tools: $(($ActiveProfiles | ForEach-Object { $_.id }) -join ', ')"

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

    foreach ($dir in Get-CanonicalAiDirectories) {
        Ensure-Directory (Join-Path $aiRoot $dir)
    }

    foreach ($dir in @(
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
    )) {
        Ensure-Directory (Join-Path $root $dir)
    }

    $aiOverlayRoot = Join-Path $root ".ai-overlay"
    Ensure-Directory $aiOverlayRoot
    Copy-SeedIfMissing "AI_OVERLAY_README.md" (Join-Path $aiOverlayRoot "README.md")

    $gitIgnorePath = Join-Path $root ".gitignore"
    Ensure-AgentsFile (Join-Path $root "AGENTS.md") $ActiveProfiles
    Copy-ToolEntrypoints $ActiveProfiles
    Copy-SeedIfMissing ".gitignore" $gitIgnorePath

    foreach ($pointer in Get-ActivePointerNames $ActiveProfiles) {
        Ensure-Line $gitIgnorePath "$pointer/"
        New-DirectoryLink (Join-Path $root $pointer) $aiRoot
    }

    $aiRegisteredAsSubmodule = Ensure-AiSubmodule $root

    if (-not $SkipInitialCommit) {
        $hasHead = Test-GitOk @("rev-parse", "--verify", "HEAD")
        if (-not $hasHead) {
            Write-Step "Creating root initial commit"
            Run-Git @(@("add") + (Get-InitialCommitPaths $ActiveProfiles))
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
