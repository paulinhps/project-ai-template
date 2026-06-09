---
name: configurar-ambiente-ai
description: Configure the project AI environment according to this repository's OpenSpec/SDD conventions. Use when Codex needs to initialize or repair root AI setup: .ai canonical structure, .codex/.claude/.agents links, docs and sources folders, AGENTS.md and .gitignore assertions, OpenSpec initialization, Git initialization, .ai submodule registration, and the root initial commit.
---

# Configurar Ambiente AI

Use this skill to prepare a repository for the shared AI workflow used by this project.

## Workflow

1. Inspect the root before changing anything:
   - Check `AGENTS.md`, `.gitignore`, `.gitmodules`, `.ai/`, `openspec/`, `docs/`, `sources/`, and Git status.
   - Treat `.ai` as canonical. Do not create independent `.codex`, `.claude`, or `.agents` directory trees.
2. Prefer running `scripts/setup-ai-environment.ps1` from the project root.
3. If the script cannot be used, follow its behavior manually and keep the same safety checks.
4. Use `assets/seeds/AGENTS.md` and `assets/seeds/.gitignore` as the source templates for new projects.
5. After changing any shared skill, rule, command, agent, template, MCP asset, setup convention, or seed file, create the next immutable prompt registry file under `.ai/prompts/registry`.

## Quick Start

From the project root:

```powershell
.\.ai\skills\configurar-ambiente-ai\scripts\setup-ai-environment.ps1
```

When `.ai` must be added as a submodule from a real remote repository:

```powershell
.\.ai\skills\configurar-ambiente-ai\scripts\setup-ai-environment.ps1 -AiRepositoryUrl "https://example.com/org/project-ai.git"
```

## Required Shape

Ensure these root paths exist:

```text
docs/
  adr/
  architecture/
  business/
  decisions/
  engineering/
  product/
  references/
  requirements/
  specs/
sources/
```

Ensure `.ai` contains the shared AI structure:

```text
.ai/
  agents/
  claude/overrides/
  codex/overrides/
  commands/
  mcp/
  prompts/registry/
  rules/
  skills/
  templates/
```

Ensure root links are mapped as:

- `.codex` -> `.ai`
- `.claude` -> `.ai`
- `.agents` -> `.ai/agents`

On Windows, try symbolic links first. If privileges block symbolic links, use directory junctions and document the fallback in `AGENTS.md`.

## Assertions

Seed files live in:

```text
assets/seeds/AGENTS.md
assets/seeds/.gitignore
```

When setting up a new project, recreate missing root files from those seeds before applying assertions. When a structural rule changes and impacts future projects, update the relevant seed in this skill.

`AGENTS.md` must specify:

- The project uses SDD with OpenSpec.
- `.ai` is canonical.
- `.codex` and `.claude` point to `.ai`.
- `.agents` points to `.ai/agents`.
- Shared rules, skills, commands, agents, templates, and MCP assets live under `.ai`.
- Prompt registry files are immutable and incrementally numbered.

`.gitignore` must include the root link paths so Git does not traverse them:

```text
.codex/
.claude/
.agents/
```

OpenSpec must be initialized when its root structure is missing. Use:

```powershell
openspec init --tools "codex,claude" .
```

If the OpenSpec CLI is unavailable, stop and tell the user the command that must be installed or approved. Do not fake the OpenSpec structure when the CLI should own it.

## Git Rules

If the root is not a Git repository, initialize it with `git init`.

If `.ai` exists as its own Git repository, register it from the root as the `.ai` submodule/gitlink. If a real AI repository URL is provided, use it in `.gitmodules`; otherwise preserve an existing `.gitmodules` URL or use `./.ai` only as a local bootstrap placeholder.

If `.ai` does not exist and `-AiRepositoryUrl` is provided, add it with:

```powershell
git submodule add <AiRepositoryUrl> .ai
```

Create the root initial commit only when the root repository has no commits. Use the repository's conventional commit rule; default to:

```text
chore: initialize AI project environment
```

Before committing, inspect status and avoid staging unrelated user work in established repositories.
