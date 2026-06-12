---
name: cross-platform-readiness-review
description: Audit repositories and canonical AI context for cross-platform readiness across Windows, Linux, and macOS. Use when Codex must inspect .ai assets, skills, commands, agents, templates, docs, scripts, MCP configs, Docker/devcontainer setup, environment variables, line endings, shell assumptions, hardcoded paths, and external tool dependencies, then produce a compatibility score, findings, matrices, and a prioritized remediation and pull request plan.
---

# Cross Platform Readiness Review

Use this skill to audit whether the repository and canonical `.ai` ecosystem can run without manual adaptation on Windows, Linux, and macOS.

By default, produce a review report and correction plan only. Make code or documentation changes only when the user explicitly asks to implement fixes.

## Scope

Inspect the whole repository, with special attention to:

```text
.ai/rules/**
.ai/skills/**
.ai/commands/**
.ai/agents/**
.ai/templates/**
.ai/workflows/**
.ai/docs/**
.ai/mcp/**
scripts/**
tools/**
automation/**
README.md
docs/**
.editorconfig
.gitattributes
.gitignore
Dockerfile
docker-compose*.yml
.devcontainer/**
.github/codespaces/**
```

If a listed path does not exist, record it as absent rather than treating it as a failure unless the project standard requires it.

## Audit Workflow

1. Identify the repository root and enumerate tracked and untracked files relevant to the scope.
2. Read `.ai/README.md`, `.ai/rules/**`, representative existing skills, and any project root guidance before judging conventions.
3. Search for platform-specific path, shell, symlink, environment, tool, MCP, Docker, and line-ending patterns.
4. Inspect every `.ai` skill, command, agent, template, workflow, and doc file for OS assumptions.
5. Inspect scripts under `scripts/`, `tools/`, and `automation/` and classify each script by supported OS.
6. Inspect configuration files that control portability: `.editorconfig`, `.gitattributes`, `.gitignore`, package manifests, Docker/devcontainer files, and MCP configs.
7. Produce findings with file paths and line numbers whenever possible.
8. Produce matrices, score, remediation plan, and pull request plan.

Prefer portable inspection commands such as:

```bash
rg --files
rg -n "pattern"
git ls-files --eol
git status --short
```

When running on Windows, PowerShell is acceptable for inspection, but do not classify repository content as portable merely because it works in the current shell.

## Required Checks

### File Paths

Flag hardcoded host paths and user directories:

```text
C:\...
D:\...
\\server\share
%USERPROFILE%
%APPDATA%
%LOCALAPPDATA%
%TEMP%
$HOME
$TMPDIR
~/...
```

Recommend repository-relative or abstract forms:

```text
<project-root>
${PROJECT_ROOT}
${WORKSPACE_ROOT}
${AI_HOME}
$(pwd)
path.join(...)
Path.Combine(...)
```

### Directory Separators

Flag hardcoded backslash paths in docs, commands, scripts, and templates when they are not clearly Windows-specific examples:

```text
.ai\skills\backend
scripts\init.ps1
```

Prefer slash-form paths in documentation and command examples:

```text
.ai/skills/backend
scripts/init.ps1
```

In code, prefer the language's path library instead of manual concatenation.

### Shell Dependencies

Classify command examples and scripts as:

```text
Portable
Windows Only
Linux Only
macOS Only
Linux/macOS
Mixed / Needs Abstraction
```

Flag shell-specific commands, including:

```text
PowerShell: Get-ChildItem, Copy-Item, Remove-Item, New-Item, Join-Path
CMD: dir, copy, move, del, mklink
Bash/Zsh/Fish: grep, sed, awk, find, xargs, chmod, ln -s, export
```

Commands that rely on standard cross-platform tools such as `git`, `node`, `npm`, `pnpm`, `python`, `dotnet`, `docker`, or `java` can be portable only when invocation, quoting, path handling, and installation guidance work across all target systems.

### Git Links And Filesystem Features

Audit symlink and junction assumptions:

```text
ln -s
mklink
mklink /J
New-Item -ItemType SymbolicLink
```

Check whether Windows developer mode, administrator privileges, directory junctions, or POSIX symlinks are assumed. Recommend portable alternatives such as copy-on-bootstrap, tool-managed links with OS detection, or explicit fallback behavior.

### AI Assets

For `.ai/agents/**`, `.ai/skills/**`, and `.ai/commands/**`, identify assumptions about:

```text
Windows Explorer
PowerShell
CMD
Registry
bash
zsh
fish
Unix permissions
case-sensitive filesystems
absolute local paths
tool-specific command syntax
```

Validate `.ai/commands/**` for use across Claude Code, Codex CLI, Cursor, Gemini CLI, OpenCode, and Aider. Flag commands that depend on one tool's slash-command behavior unless they document a portable fallback.

### External Tools

Map every referenced external tool:

```text
git
gh
docker
node
npm
pnpm
python
dotnet
java
make
openspec
```

For each tool, report:

- Where it is used.
- Whether it is available on Windows, Linux, and macOS.
- Minimum version when declared or inferable.
- Recommended installation method per OS.
- Whether the project provides a containerized fallback.

If the repository does not declare a version, mark it as `Not specified` and recommend adding one only when the tool is required for reproducibility.

### Environment Variables

Flag OS-specific variables and recommend canonical abstractions:

```text
AI_HOME
PROJECT_ROOT
WORKSPACE_ROOT
XDG_CONFIG_HOME
TEMP_DIR
```

Prefer documenting both Windows and POSIX examples when an environment variable must be set manually.

### Encoding And Line Endings

Inspect line-ending and encoding policy:

```text
.editorconfig
.gitattributes
git ls-files --eol
```

Recommend `UTF-8` and `LF` as the canonical repo standard unless the project has a documented reason for a different policy. Ensure executable scripts and shell files have explicit line-ending rules, for example:

```text
* text=auto
*.sh text eol=lf
*.ps1 text eol=crlf
```

Flag BOM usage when inconsistent or harmful for scripts.

### MCPs

Inspect `.ai/mcp/**` and any MCP references in docs or skills. Validate per operating system:

- Installation command.
- Runtime command.
- Required environment variables.
- Required package manager or language runtime.
- Whether paths and quoting are portable.
- Whether network or credential assumptions are documented.

### Docker, DevContainer, And Codespaces

Check whether the project can be run through Docker, DevContainer, or Codespaces without host-specific setup. Inspect:

```text
Dockerfile
docker-compose*.yml
.devcontainer/**
.github/codespaces/**
```

Flag host dependencies that leak into containers, such as Windows drive mounts, `/var/run/docker.sock` assumptions without alternatives, hardcoded UID/GID, or missing runtime/tool installation.

## Scoring

Start from `100` and subtract:

- `Critical`: 15 points each.
- `High`: 8 points each.
- `Medium`: 3 points each.
- `Low`: 1 point each.

Clamp the final score to `0..100`. Use severity based on impact:

- `Critical`: blocks core `.ai` usage on one or more target OSes.
- `High`: blocks common workflows or setup unless manually adapted.
- `Medium`: creates friction, ambiguity, or partial incompatibility.
- `Low`: documentation polish, inconsistent examples, or non-blocking cleanup.

## Report Format

Use this output shape:

```text
Cross Platform Score: XX/100

Executive Summary
- ...

Findings By Severity
| Severity | File | Issue | Impact | Recommendation |

Compatibility Matrix
| Component | Windows | Linux | macOS | Notes |

Script And Automation Matrix
| File | Status | Reason | Required Fix |

Agent Matrix
| Agent | Windows | Linux | macOS | Notes |

Skill Matrix
| Skill | Windows | Linux | macOS | Notes |

Command Matrix
| Command | Claude Code | Codex CLI | Cursor | Gemini CLI | OpenCode | Aider | Notes |

External Tool Matrix
| Tool | Used By | Windows | Linux | macOS | Minimum Version | Install Guidance |

MCP Readiness
| MCP Asset | Windows | Linux | macOS | Notes |

Docker Readiness
- Docker:
- DevContainer:
- Codespaces:

Encoding And Config
- .editorconfig:
- .gitattributes:
- .gitignore:
- Line endings:

Correction Plan
1. ...

Pull Request Plan
1. commit: ...
```

Use `Pass`, `Partial`, `Fail`, or `Not applicable` in matrices. Include concise evidence for every `Partial` or `Fail`.

## Remediation Guidance

Prefer fixes in this order:

1. Replace absolute host paths with project-root placeholders or environment abstractions.
2. Normalize documentation paths to slash-form.
3. Add cross-platform setup instructions before adding OS-specific scripts.
4. Replace shell-only automation with portable scripts when behavior must be shared.
5. Keep OS-specific scripts only behind a documented dispatcher or clearly paired alternatives.
6. Add `.editorconfig` and `.gitattributes` rules for encoding and line endings.
7. Add tool version declarations and installation guidance.
8. Add Docker, DevContainer, or Codespaces fallback when host setup remains complex.

Suggested commit themes:

```text
feat(platform): remove hardcoded host paths
feat(platform): add path and environment abstractions
feat(platform): standardize cross-platform setup guidance
feat(platform): add linux and macos bootstrap support
feat(platform): normalize line endings and encoding policy
feat(platform): document toolchain and mcp prerequisites
feat(platform): add containerized development fallback
```

## Approval Criteria

Consider the project approved only when:

- No skill depends exclusively on Windows.
- No command depends exclusively on Windows.
- No agent depends exclusively on Windows.
- Documentation includes Windows, Linux, and macOS instructions where setup or execution is described.
- The `.ai` ecosystem can be executed without manual modifications on every supported OS.
- Encoding and line-ending policy is explicit and enforceable.
- Required external tools have versions or installation guidance.
- Docker, DevContainer, or Codespaces readiness is documented when host parity cannot be guaranteed.
