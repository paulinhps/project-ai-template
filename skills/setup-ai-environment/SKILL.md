---
name: setup-ai-environment
description: Configure, initialize, review, and repair the project AI environment according to this repository's canonical AI conventions. Use when Codex needs root AI setup: canonical .ai context, project-specific .ai-overlay, .codex/.claude/.agents links, docs and sources folders, AGENTS.md and .gitignore assertions, Git initialization, .ai reference registration or ignore configuration, and the root initial commit.
---

# Setup AI Environment

Use this skill to prepare a repository for the shared AI workflow used by this project. Keep `.ai` canonical, keep tool-specific paths as links to `.ai`, and make the root repository a predictable AI-governed workspace.

## Operating Mode

When configuring or repairing the AI environment:

1. Inspect the root before changing anything.
2. Check `AGENTS.md`, `.gitignore`, `.gitmodules`, `.ai/`, `.ai-overlay/`, `docs/`, `sources/`, and Git status.
3. Treat `.ai` as canonical. Do not create independent `.codex`, `.claude`, or `.agents` directory trees.
4. For new projects, ensure the `.ai` context has already been cloned or downloaded into the project root before root initialization.
5. Use `scripts/setup-ai-environment.mjs` when Node.js is available; it is the cross-platform setup path for Windows, Linux, and macOS.
6. On Windows, `scripts/setup-ai-environment.ps1` remains a supported PowerShell equivalent.
7. If neither script can be used, follow the script behavior manually and keep the same safety checks.
8. Use `assets/seeds/AGENTS.md`, `assets/seeds/.gitignore`, and `assets/seeds/AI_OVERLAY_README.md` as the source templates for new projects.
9. When root files already exist, compare them against the required assertions before changing anything.
10. If an existing `AGENTS.md`, `.gitignore`, README, documentation structure, or source layout conflicts with the canonical structure, stop and ask for one of these decisions:
   - Merge: preserve project-specific content and add missing canonical context.
   - Replace: overwrite the conflicting file or structure with the canonical seed.
   - Restructure: move documentation and source code into the expected `docs/` and `sources/` locations before continuing.
11. After changing any shared skill, rule, command, agent, template, MCP asset, setup convention, or seed file, create the next immutable prompt registry file under `.ai/prompts/registry`.

Do not tell the user to run `git init`, `git submodule add`, or the initial root commit manually before this skill in the standard flow.

## Required Principles

Every setup decision must respect:

- **Canonical AI Context**: `.ai` is the source of truth for shared AI assets.
- **AI Overlay**: `.ai-overlay` is the versioned project-specific AI context overlay. It mirrors `.ai` conceptually but starts with only `README.md` and grows on demand.
- **Tool Links, Not Copies**: `.codex`, `.claude`, and `.agents` must point to `.ai`.
- **Root Workspace Ownership**: the root owns AI governance, global documentation, source-module references, and root Git coordination.
- **Source Isolation**: source code belongs under `sources/`, not directly in the root.
- **Documentation Separation**: global documentation belongs under `docs/`.
- **Explicit Repository References**: use `.ai/rules/repository-submodule-references.md` for `.ai` and source-module reference decisions.
- **Safe Existing Project Setup**: preserve existing project-specific guidance unless the user chooses replace or restructure.
- **Project-Specific By Default**: create new project-specific rules, skills, commands, agents, templates, MCP assets, prompts, and overrides under `.ai-overlay` unless the user explicitly asks to change `.ai`.
- **Optional SDD Tooling**: configure SDD/planning tools only when the user explicitly requests a specific tool; tool-specific assets from that setup belong under `.ai-overlay` unless the user explicitly asks to evolve canonical `.ai`.
- **Prompt Registry Audit Trail**: structural canonical AI-context changes require a new immutable prompt registry entry.

## Quick Start

From a new empty project root, place the shared `.ai` context first:

```bash
git clone <AI_REPOSITORY_URL> .ai
```

If the shared context is distributed as a download instead of a Git repository, extract or copy it into `.ai`.

Then ask an AI agent to execute this prompt from the project root:

```text
initialize project using .ai/skills/setup-ai-environment/SKILL.md skill
```

The default Git branch for newly initialized repositories is `main`. Override it only when a project has a documented reason:

```bash
node .ai/skills/setup-ai-environment/scripts/setup-ai-environment.mjs --default-branch main
```

Windows PowerShell equivalent:

```powershell
.\.ai\skills\setup-ai-environment\scripts\setup-ai-environment.ps1 -DefaultBranch "main"
```

When `.ai` is not already present and must be added from a real remote repository during setup, pass the repository URL:

```bash
node .ai/skills/setup-ai-environment/scripts/setup-ai-environment.mjs --ai-repository-url "https://example.com/org/project-ai.git"
```

Windows PowerShell equivalent:

```powershell
.\.ai\skills\setup-ai-environment\scripts\setup-ai-environment.ps1 -AiRepositoryUrl "https://example.com/org/project-ai.git"
```

## Root Setup Responsibilities

This skill owns:

- Root Git initialization when missing.
- Root directory and seed file creation.
- Root tool links.
- Project-specific AI overlay initialization.
- `.ai` reference registration or ignore configuration.
- Root initial commit when the root repository has no commits.

The skill handles the rest of the project initialization:

- Initializes the root Git repository when missing.
- Creates the expected root directories and seed files.
- Creates `.ai-overlay/README.md` only, leaving the rest of the overlay structure to be created on demand.
- Creates `.codex`, `.claude`, and `.agents` links to `.ai`.
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
.ai-overlay/
  README.md
```

`.ai-overlay` may later mirror the `.ai` structure, but setup must not create the full tree before it is needed:

```text
.ai-overlay/
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
assets/seeds/AI_OVERLAY_README.md
```

When setting up a new project, recreate missing root files from those seeds before applying assertions. When a structural rule changes and impacts future projects, update the relevant seed in this skill.

When a root file already exists, do not silently overwrite it. If it is missing required canonical assertions, request a decision:

- Merge canonical assertions into the existing file while preserving project-specific guidance.
- Replace the existing file with the canonical seed.
- Restructure the project first, moving root documentation into `docs/` and source code into `sources/` before applying the seed.

`AGENTS.md` must specify:

- SDD/planning tools are optional and must be configured only when explicitly requested.
- `.ai` is canonical.
- `.ai-overlay` is the project-specific AI context overlay and is versioned with the root repository.
- `.codex`, `.claude`, and `.agents` point to `.ai`.
- Shared rules, skills, commands, agents, templates, and MCP assets live under `.ai`.
- Project-specific rules, skills, commands, agents, templates, and MCP assets live under `.ai-overlay` unless the user explicitly asks to change `.ai`.
- Prompt registry files are immutable and incrementally numbered.

`.gitignore` must include the root link paths so Git does not traverse them:

```text
.codex/
.claude/
.agents/
```

## Optional SDD Tooling Rules

Do not install, initialize, or scaffold SDD/planning tooling during the standard setup flow.

When the user explicitly asks to configure a specific SDD/planning tool, keep any generated or supporting AI assets project-specific:

```text
.ai-overlay/rules/
.ai-overlay/skills/
.ai-overlay/commands/
.ai-overlay/agents/
.ai-overlay/templates/
.ai-overlay/mcp/
.ai-overlay/prompts/registry/
```

Use canonical `.ai` for that tooling only when the user explicitly asks to evolve the shared context.

## Git Reference Rules

The standard new-project flow is to clone or download `.ai` first, then ask an AI agent to execute this skill. If the root is not a Git repository, the skill initializes it with `git init --initial-branch=main`, usually by running `scripts/setup-ai-environment.mjs`. The setup scripts default to `main` through the `--default-branch` or `-DefaultBranch` parameter and fall back to `git branch -M main` when the installed Git version does not support `--initial-branch`.

Use `.ai/rules/repository-submodule-references.md` for reference decisions.

If `.ai` is copied or downloaded without Git metadata, do not register it as a submodule. Add `.ai/` to the root `.gitignore` and report that the AI context is local-only.

If `.ai` is a Git repository without `origin`, do not register it as a submodule automatically. Add `.ai/` to the root `.gitignore` and report `remote origin pending`.

If the project owner explicitly chooses local `.ai` submodule mode, run the setup script with `--register-local-ai-submodule` or `-RegisterLocalAiSubmodule` and use `./.ai` as the local bootstrap URL.

If `.ai` has `origin`, or if `-AiRepositoryUrl` is provided, register it from the root as the `.ai` submodule/gitlink and write the remote URL to `.gitmodules`. Do not use `./.ai` as the final submodule URL for reusable projects.

If `.ai` does not exist and `-AiRepositoryUrl` is provided, add it with:

```bash
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
- [ ] `.ai-overlay/README.md` exists and is versioned by the root repository.
- [ ] `.codex` points to `.ai`.
- [ ] `.claude` points to `.ai`.
- [ ] `.agents` points to `.ai`.
- [ ] `docs/` exists at the repository root.
- [ ] `sources/` exists at the repository root.
- [ ] `AGENTS.md` exists and includes the required canonical assertions.
- [ ] `.gitignore` includes `.codex/`, `.claude/`, and `.agents/`.
- [ ] `.ai` reference handling follows `.ai/rules/repository-submodule-references.md`.
- [ ] Root Git initialization and initial commit behavior followed the standard flow.
- [ ] Existing project files were merged, replaced, or restructured only after the user chose that path.
