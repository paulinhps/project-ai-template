# AI Project Context

`.ai` is the canonical source of truth for AI-assisted development in this repository. It stores the shared operating rules, skills, commands, agents, templates, MCP assets, and prompt history used to start and maintain projects with AI.

Root `.codex` and `.claude` paths should point to `.ai`, so changes made through `.ai`, `.codex`, or `.claude` affect the same underlying files. Root `.agents` should point to `.ai/agents`. On Windows, true symbolic links can require administrator privileges; directory junctions are the supported non-duplicating fallback.

## Prerequisites

Before using this structure to initialize a new project from zero, install or confirm these tools:

- Git, available as `git` in the terminal.
- Node.js and npm, available as `node` and `npm`.
- PowerShell 7 or Windows PowerShell with script execution allowed for local project scripts.
- OpenSpec CLI:

```powershell
npm install -g @fission-ai/openspec@latest
```

- At least one AI coding tool that can read repository instructions, such as Codex and/or Claude.
- Optional: administrator privileges on Windows if you want symbolic links instead of directory junctions.
- Optional: a remote Git repository for `.ai` when the AI context should be shared across multiple projects as a submodule.

## Start a New Project from Zero

Use this sequence when creating a new repository that should adopt the shared AI structure.

1. Create or open the empty project directory.

```powershell
mkdir my-project
cd my-project
git init --initial-branch=main
```

2. Add the `.ai` context.

Use a shared remote when one exists:

```powershell
git submodule add <AI_REPOSITORY_URL> .ai
```

For a local bootstrap, copy or create `.ai` first, then initialize it as its own repository:

```powershell
mkdir .ai
git -C .ai init --initial-branch=main
```

3. Run the setup skill script from the project root.

```powershell
.\.ai\skills\configurar-ambiente-ai\scripts\setup-ai-environment.ps1
```

When `.ai` should be added from a real remote repository during setup, pass the repository URL:

```powershell
.\.ai\skills\configurar-ambiente-ai\scripts\setup-ai-environment.ps1 -AiRepositoryUrl "<AI_REPOSITORY_URL>"
```

4. Initialize OpenSpec if the setup script did not already create `openspec/`.

```powershell
openspec init --tools "codex,claude" .
```

Keep `codex,claude` quoted in PowerShell so the comma-separated tool list is passed as one value.

5. Confirm the expected root shape.

```text
AGENTS.md
.gitignore
.gitmodules
.ai/
.codex/      -> .ai
.claude/     -> .ai
.agents/     -> .ai/agents
docs/
openspec/
sources/
```

6. Review and commit the initialized project.

```powershell
git status
git add AGENTS.md .gitignore .gitmodules .ai docs openspec sources
git commit -m "chore: initialize AI project environment"
```

Follow `.ai/rules/conventional-commits.md` for every commit in the root repository and in the `.ai` repository.

## How to Use the `.ai` Structure

Treat `.ai` as the project memory and operating system for AI-assisted work.

1. Start every AI session by reading `AGENTS.md` from the project root.
2. Use `.ai/rules/` for shared rules that every agent must follow.
3. Use `.ai/skills/` for repeatable workflows, especially OpenSpec propose, apply, sync, archive, and project setup tasks.
4. Use `.ai/commands/` for command definitions and slash-command assets that should be available across tools.
5. Use `.ai/agents/` for reusable agent definitions.
6. Use `.ai/templates/` for reusable specification, prompt, documentation, and workflow templates.
7. Use `.ai/mcp/` for shared MCP servers, configs, prompts, and skills.
8. Use `.ai/prompts/registry/` as the immutable audit trail of AI-driven project evolution.
9. Put shared behavior in shared folders first. Use `.ai/codex/overrides/` or `.ai/claude/overrides/` only for genuine tool-specific behavior.
10. Never create independent `.codex`, `.claude`, or `.agents` directory trees. Those paths must remain links to the canonical `.ai` assets.

## Shared Folders

- `rules/`: shared AI rules and operating constraints.
- `skills/`: shared skills for AI-assisted workflows.
- `commands/`: shared command definitions and slash-command assets.
- `agents/`: shared agent definitions.
- `templates/`: shared templates for specs, prompts, docs, and workflows.
- `prompts/registry/`: immutable, incrementally numbered prompt source files.
- `mcp/`: shared MCP assets, including servers, configs, prompts, and skills.

## Tool-Specific Overrides

- `codex/overrides/`: Codex-specific behavior and local overrides.
- `claude/overrides/`: Claude-specific behavior and local overrides.

Shared behavior should live in shared folders first. Use tool-specific override folders only when Codex and Claude need different behavior.

## Prompt Registry

Prompt source files are immutable and versioned under `.ai/prompts/registry`.

Use this format:

```text
####-prompt-name.md
```

Create the next registry file whenever a shared skill, rule, command, agent, template, MCP asset, setup convention, or seed file changes. The prompt registry is the audit trail of AI-driven project evolution.
