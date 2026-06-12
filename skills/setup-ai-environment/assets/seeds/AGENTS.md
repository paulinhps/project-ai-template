# AI Agent Guide

This project uses SDD with OpenSpec as the source for propose -> apply -> archive workflows.

OpenSpec was installed with:

```bash
npm install -g @fission-ai/openspec@latest
```

OpenSpec was initialized with:

```bash
openspec init --tools "codex,claude" .
```

The unquoted PowerShell form split the comma-separated tool list, so the successful command quoted `codex,claude`.

## AI Context

`.ai` is the canonical AI context directory.

`.codex`, `.claude`, and `.agents` point to `.ai`. The requested symbolic links required administrator privileges in this Windows environment, so directory junctions were used as the non-duplicating fallback. Changes made through `.ai`, `.codex`, `.claude`, or `.agents` affect the same underlying files.

Do not create independent `.codex`, `.claude`, or `.agents` directory trees.

Because Git traverses these Windows junctions as directories on this host, `.gitignore` excludes `.codex/`, `.claude/`, and `.agents/`. Track canonical files through `.ai`.

## Project Initialization

New projects must start by cloning or downloading the shared `.ai` context into the project root. After `.ai` exists, ask an AI agent to execute this prompt from the root:

```text
initialize project using .ai\skills\setup-ai-environment\SKILL.md skill
```

The setup skill is responsible for initializing the root Git repository, creating root directories and seed files, creating tool links, initializing OpenSpec, registering or ignoring the `.ai` reference according to its repository state, and creating the initial root commit. Do not perform those root initialization steps manually in the standard flow.

## Repository References

The root repository tracks reproducible references, not copied implementation trees.

- If `.ai` was copied or downloaded without Git metadata, keep `.ai/` ignored in the root repository.
- If `.ai` is a Git repository without `origin`, keep `.ai/` ignored and report `remote origin pending`, unless the project owner explicitly chooses local `.ai` submodule mode.
- If `.ai` has `origin`, register it as a submodule using the remote URL.
- Projects under `sources/` always become submodules: local repositories without `origin` use local URLs, and repositories with `origin` use remote URLs.
- Follow `.ai/rules/repository-submodule-references.md` for all reference decisions.

## Shared Assets

- Shared rules must live in `.ai/rules`.
- All agents must follow `.ai/rules/conventional-commits.md` before creating commits in any repository of this project.
- Shared skills must live in `.ai/skills`.
- Shared commands must live in `.ai/commands`.
- Shared agents must live in `.ai/agents`.
- Shared templates must live in `.ai/templates`.
- MCP-related assets must live in `.ai/mcp`.

## Tool-Specific Overrides

- Codex-specific behavior must live in `.ai/codex/overrides`.
- Claude-specific behavior must live in `.ai/claude/overrides`.

Use overrides only for genuine tool-specific behavior. Shared instructions should stay in the shared folders.

## Prompt Registry

Prompt source files are immutable and versioned under `.ai/prompts/registry`.

Use this format:

```text
####-prompt-name.md
```

The number is a global incremental sequence. Never edit an existing prompt file after it has been created. If a skill, rule, command, agent, template, or MCP changes, create a new prompt file documenting the change.

The prompt registry is the audit trail of AI-driven project evolution.

## OpenSpec Notes

OpenSpec initialized the project-local `openspec/` structure. During initialization, Codex setup attempted to write user-level prompt files under the local Codex home and was blocked by environment permissions, but project-local OpenSpec skills were generated and consolidated into the shared `.ai/skills` directory.
