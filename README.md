# AI Project Context

`.ai` is the canonical source of truth for AI-assisted development in this repository. It stores the shared operating rules, skills, commands, agents, templates, MCP assets, and prompt history used to start and maintain projects with AI.

Root `.codex`, `.claude`, and `.agents` paths should point to `.ai`, so changes made through any of those tool paths affect the same underlying files. On Windows, true symbolic links can require administrator privileges; directory junctions are the supported non-duplicating fallback.

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

The project initialization decision is: first place the shared `.ai` content in the project root, then run the configuration skill. The setup skill/script owns root repository initialization, root files and directories, `.ai` submodule registration, OpenSpec initialization, and the initial root commit.

1. Create or open the empty project directory. Do not run `git init` in the root manually.

```powershell
mkdir my-project
cd my-project
```

2. Clone or download the shared `.ai` context into the project root.

Use the shared AI repository when one exists:

```powershell
git clone <AI_REPOSITORY_URL> .ai
```

For a local bootstrap, copy the prepared `.ai` directory into the project root:

```powershell
Copy-Item -Recurse <AI_CONTEXT_SOURCE> .ai
```

3. Run the setup skill script from the project root.

```powershell
.\.ai\skills\configurar-ambiente-ai\scripts\setup-ai-environment.ps1
```

The script is responsible for these root initialization tasks:

- Initialize the root Git repository when it does not exist.
- Create root directories and seed files such as `docs/`, `sources/`, `AGENTS.md`, and `.gitignore`.
- Create `.codex`, `.claude`, and `.agents` links to `.ai`.
- Initialize OpenSpec when `openspec/` is missing.
- Register `.ai` as a submodule/gitlink of the root repository.
- Create the initial root commit when the root repository has no commits.

4. Initialize OpenSpec manually only if the setup script could not run it.

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
.agents/     -> .ai
docs/
openspec/
sources/
```

6. Review the initialized project.

```powershell
git status
```

The setup script creates the initial root commit automatically when the root repository has no commits. Follow `.ai/rules/conventional-commits.md` for every later commit in the root repository and in the `.ai` repository.

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
