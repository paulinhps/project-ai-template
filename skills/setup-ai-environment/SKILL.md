---
name: setup-ai-environment
description: Configure, initialize, review, and repair the project AI environment according to this repository's OpenSpec/SDD conventions. Use when Codex needs root AI setup: canonical .ai context, .codex/.claude/.agents links, docs and sources folders, AGENTS.md and .gitignore assertions, OpenSpec initialization, Git initialization, .ai reference registration or ignore configuration, and the root initial commit.
---

# Setup AI Environment

Use this skill to prepare a repository for the shared AI workflow used by this project. Keep `.ai` canonical, keep tool-specific paths as links to `.ai`, and make the root repository a predictable AI-governed workspace.

## Operating Mode

When configuring or repairing the AI environment:

1. Inspect the root before changing anything.
2. Check `AGENTS.md`, `.gitignore`, `.gitmodules`, `.ai/`, `openspec/`, `docs/`, `sources/`, and Git status.
3. Treat `.ai` as canonical. Do not create independent `.codex`, `.claude`, or `.agents` directory trees.
4. For new projects, ensure the `.ai` context has already been cloned or downloaded into the project root before root initialization.
5. Use `scripts/setup-ai-environment.ps1` when possible.
6. If the script cannot be used, follow its behavior manually and keep the same safety checks.
7. Use `assets/seeds/AGENTS.md` and `assets/seeds/.gitignore` as the source templates for new projects.
8. When root files already exist, compare them against the required assertions before changing anything.
9. If an existing `AGENTS.md`, `.gitignore`, README, documentation structure, or source layout conflicts with the canonical structure, stop and ask for one of these decisions:
   - Merge: preserve project-specific content and add missing canonical context.
   - Replace: overwrite the conflicting file or structure with the canonical seed.
   - Restructure: move documentation and source code into the expected `docs/` and `sources/` locations before continuing.
10. After changing any shared skill, rule, command, agent, template, MCP asset, setup convention, or seed file, create the next immutable prompt registry file under `.ai/prompts/registry`.

Do not tell the user to run `git init`, `git submodule add`, or the initial root commit manually before this skill in the standard flow.

## Required Principles

Every setup decision must respect:

- **Canonical AI Context**: `.ai` is the source of truth for shared AI assets.
- **Tool Links, Not Copies**: `.codex`, `.claude`, and `.agents` must point to `.ai`.
- **Root Workspace Ownership**: the root owns AI governance, OpenSpec, global documentation, source-module references, and root Git coordination.
- **Source Isolation**: source code belongs under `sources/`, not directly in the root.
- **Documentation Separation**: global documentation belongs under `docs/`.
- **Explicit Repository References**: use `.ai/rules/repository-submodule-references.md` for `.ai` and source-module reference decisions.
- **Safe Existing Project Setup**: preserve existing project-specific guidance unless the user chooses replace or restructure.
- **Prompt Registry Audit Trail**: structural AI-context changes require a new immutable prompt registry entry.

## Quick Start

From a new empty project root, place the shared `.ai` context first:

```powershell
git clone <AI_REPOSITORY_URL> .ai
```

If the shared context is distributed as a download instead of a Git repository, extract or copy it into `.ai`.

Then ask an AI agent to execute this prompt from the project root:

```text
initialize project using .ai\skills\setup-ai-environment\SKILL.md skill
```

The default Git branch for newly initialized repositories is `main`. Override it only when a project has a documented reason:

```powershell
.\.ai\skills\setup-ai-environment\scripts\setup-ai-environment.ps1 -DefaultBranch "main"
```

When `.ai` is not already present and must be added from a real remote repository during setup, pass the repository URL:

```powershell
.\.ai\skills\setup-ai-environment\scripts\setup-ai-environment.ps1 -AiRepositoryUrl "https://example.com/org/project-ai.git"
```

## Root Setup Responsibilities

This skill owns:

- Root Git initialization when missing.
- Root directory and seed file creation.
- Root tool links.
- OpenSpec initialization.
- `.ai` reference registration or ignore configuration.
- Root initial commit when the root repository has no commits.

The skill handles the rest of the project initialization:

- Initializes the root Git repository when missing.
- Creates the expected root directories and seed files.
- Creates `.codex`, `.claude`, and `.agents` links to `.ai`.
- Initializes OpenSpec when missing.
- Registers `.ai` as a submodule/gitlink only when `.ai` has a remote repository URL.
- Ignores local-only `.ai` contexts in the root repository when `.ai` is copied manually or has no remote.
- Creates the initial root commit when the root repository has no commits.

## Required Root Shape

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
- `.agents` -> `.ai`

On Windows, try symbolic links first. If privileges block symbolic links, use directory junctions and document the fallback in `AGENTS.md`.

## Root File Assertions

Seed files live in:

```text
assets/seeds/AGENTS.md
assets/seeds/.gitignore
```

When setting up a new project, recreate missing root files from those seeds before applying assertions. When a structural rule changes and impacts future projects, update the relevant seed in this skill.

When a root file already exists, do not silently overwrite it. If it is missing required canonical assertions, request a decision:

- Merge canonical assertions into the existing file while preserving project-specific guidance.
- Replace the existing file with the canonical seed.
- Restructure the project first, moving root documentation into `docs/` and source code into `sources/` before applying the seed.

`AGENTS.md` must specify:

- The project uses SDD with OpenSpec.
- `.ai` is canonical.
- `.codex`, `.claude`, and `.agents` point to `.ai`.
- Shared rules, skills, commands, agents, templates, and MCP assets live under `.ai`.
- Prompt registry files are immutable and incrementally numbered.

`.gitignore` must include the root link paths so Git does not traverse them:

```text
.codex/
.claude/
.agents/
```

## OpenSpec Rules

OpenSpec must be initialized when its root structure is missing. Use:

```powershell
openspec init --tools "codex,claude" .
```

If the OpenSpec CLI is unavailable, stop and tell the user the command that must be installed or approved. Do not fake the OpenSpec structure when the CLI should own it.

Keep `codex,claude` quoted in PowerShell so the comma-separated tool list is passed as one value.

## Git Reference Rules

The standard new-project flow is to clone or download `.ai` first, then ask an AI agent to execute this skill. If the root is not a Git repository, the skill initializes it with `git init --initial-branch=main`, usually by running `scripts/setup-ai-environment.ps1`. The setup script defaults to `main` through the `-DefaultBranch` parameter and falls back to `git branch -M main` when the installed Git version does not support `--initial-branch`.

Use `.ai/rules/repository-submodule-references.md` for reference decisions.

If `.ai` is copied or downloaded without Git metadata, do not register it as a submodule. Add `.ai/` to the root `.gitignore` and report that the AI context is local-only.

If `.ai` is a Git repository without `origin`, do not register it as a submodule automatically. Add `.ai/` to the root `.gitignore` and report `remote origin pending`.

If the project owner explicitly chooses local `.ai` submodule mode, run the setup script with `-RegisterLocalAiSubmodule` and use `./.ai` as the local bootstrap URL.

If `.ai` has `origin`, or if `-AiRepositoryUrl` is provided, register it from the root as the `.ai` submodule/gitlink and write the remote URL to `.gitmodules`. Do not use `./.ai` as the final submodule URL for reusable projects.

If `.ai` does not exist and `-AiRepositoryUrl` is provided, add it with:

```powershell
git submodule add <AiRepositoryUrl> .ai
```

Create the root initial commit only when the root repository has no commits. Use the repository's conventional commit rule; default to:

```text
chore: initialize AI project environment
```

Before committing, inspect status and avoid staging unrelated user work in established repositories.

## Validation Checklist

Before finishing, verify:

- [ ] `.ai` exists at the repository root.
- [ ] `.codex` points to `.ai`.
- [ ] `.claude` points to `.ai`.
- [ ] `.agents` points to `.ai`.
- [ ] `docs/` exists at the repository root.
- [ ] `sources/` exists at the repository root.
- [ ] `AGENTS.md` exists and includes the required canonical assertions.
- [ ] `.gitignore` includes `.codex/`, `.claude/`, and `.agents/`.
- [ ] OpenSpec exists or the setup stopped with a clear CLI installation/approval message.
- [ ] `.ai` reference handling follows `.ai/rules/repository-submodule-references.md`.
- [ ] Root Git initialization and initial commit behavior followed the standard flow.
- [ ] Existing project files were merged, replaced, or restructured only after the user chose that path.
