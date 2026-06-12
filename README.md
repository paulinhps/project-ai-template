# AI Project Context

`.ai` is the canonical source of truth for AI-assisted development in this repository. It stores the shared operating rules, skills, commands, agents, templates, MCP assets, and prompt history used to start and maintain projects with AI.

Project-specific AI context belongs in `.ai-overlay`, which is versioned by the root repository. `.ai-overlay` mirrors `.ai` conceptually but starts with only `README.md`; create folders there only when project-specific rules, skills, commands, agents, templates, MCP assets, prompts, notes, or overrides are needed.

Root `.codex`, `.claude`, and `.agents` paths should point to `.ai`, so changes made through any of those tool paths affect the same underlying files. On Windows, true symbolic links can require administrator privileges; directory junctions are the supported non-duplicating fallback.

## Prerequisites

Before using this structure to initialize a new project from zero, install or confirm these tools:

- Git, available as `git` in the terminal.
- Node.js 20 LTS or newer and npm, available as `node` and `npm`.
- PowerShell 7 or Windows PowerShell only when using the Windows-specific `.ps1` setup path.
- OpenSpec CLI:

```bash
npm install -g @fission-ai/openspec@latest
```

- At least one AI coding tool that can read repository instructions, such as Codex and/or Claude.
- Optional: administrator privileges on Windows if you want symbolic links instead of directory junctions.
- Optional: a remote Git repository for `.ai` when the AI context should be shared across multiple projects as a submodule.

### Tool Versions And Installation

| Tool | Minimum | Windows | Linux | macOS | Notes |
| --- | --- | --- | --- | --- | --- |
| Git | 2.28+ preferred | `winget install Git.Git` | Use the distro package manager | `brew install git` | `git init --initial-branch` needs modern Git; scripts fall back to `git branch -M main`. |
| Node.js | 20 LTS+ | `winget install OpenJS.NodeJS.LTS` | Use NodeSource, `nvm`, or the distro package manager | `brew install node@20` or `nvm install 20` | Required for the cross-platform setup script. |
| npm | Bundled with Node.js | Bundled with Node.js | Bundled with Node.js | Bundled with Node.js | Required to install OpenSpec. |
| OpenSpec CLI | Latest stable | `npm install -g @fission-ai/openspec@latest` | Same command | Same command | Required for propose, apply, sync, and archive workflows. |
| PowerShell | 7+ preferred | Built-in Windows PowerShell works for the `.ps1` path; PowerShell 7 recommended | Install `powershell` only if using `.ps1` scripts | Install `powershell` only if using `.ps1` scripts | Optional when using the Node setup script. |

## Start a New Project from Zero

Use this sequence when creating a new repository that should adopt the shared AI structure.

The project initialization decision is: first place the shared `.ai` content in the project root, then ask an AI agent to execute the configuration skill. The skill owns root repository initialization, root files and directories, `.ai` reference registration, OpenSpec initialization, and the initial root commit.

1. Create or open the empty project directory. Do not run `git init` in the root manually.

```bash
mkdir my-project
cd my-project
```

2. Clone or download the shared `.ai` context into the project root.

Use the shared AI repository when one exists:

```bash
git clone <AI_REPOSITORY_URL> .ai
```

For a local bootstrap, copy the prepared `.ai` directory into the project root:

```bash
cp -R <AI_CONTEXT_SOURCE> .ai
```

Windows PowerShell equivalent:

```powershell
Copy-Item -Recurse <AI_CONTEXT_SOURCE> .ai
```

3. Execute this prompt from the project root:

```text
initialize project using .ai/skills/setup-ai-environment/SKILL.md skill
```

The skill is responsible for these root initialization tasks:

- Initialize the root Git repository when it does not exist.
- Create root directories and seed files such as `docs/`, `sources/`, `.ai-overlay/README.md`, `AGENTS.md`, and `.gitignore`.
- Create `.codex`, `.claude`, and `.agents` links to `.ai`.
- Initialize OpenSpec when `openspec/` is missing.
- Register `.ai` as a submodule/gitlink only when `.ai` has a remote repository URL.
- Ignore local-only `.ai` contexts in the root repository when `.ai` is copied manually or has no remote.
- Create the initial root commit when the root repository has no commits.

4. Run the cross-platform setup script when executing the skill manually.

```bash
node .ai/skills/setup-ai-environment/scripts/setup-ai-environment.mjs
```

Windows PowerShell equivalent:

```powershell
.\.ai\skills\setup-ai-environment\scripts\setup-ai-environment.ps1
```

5. Initialize OpenSpec manually only if the setup script could not run it.

```bash
openspec init --tools "codex,claude" .
```

Keep `codex,claude` quoted in shells so the comma-separated tool list is passed as one value.

6. Confirm the expected root shape.

```text
AGENTS.md
.gitignore
.gitmodules
.ai/
.ai-overlay/
  README.md
.codex/      -> .ai
.claude/     -> .ai
.agents/     -> .ai
docs/
openspec/
sources/
```

7. Review the initialized project.

```bash
git status
```

The skill creates the initial root commit automatically when the root repository has no commits. Follow `.ai/rules/conventional-commits.md` for every later commit in the root repository and in the `.ai` repository.

## Repository References

The root repository tracks reproducible references, not copied implementation trees.

- Copied `.ai` directories without Git metadata are local-only and should be ignored from the root repository.
- Local `.ai` Git repositories without `origin` are local bootstrap state; they may be ignored from the root repository or explicitly registered as local submodules.
- Remote-backed `.ai` repositories should be registered as submodules using the remote URL.
- Source projects under `sources/` always become submodules: local repositories without `origin` use local URLs, and repositories with `origin` use remote URLs.

See `.ai/rules/repository-submodule-references.md` for the full rule.

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
9. Load `.ai-overlay/` after `.ai` when it exists. Treat it as the project-specific overlay.
10. Put project-specific AI assets in `.ai-overlay` unless the user explicitly asks to evolve the canonical `.ai` context.
11. Put shared behavior in shared folders first. Use `.ai/codex/overrides/` or `.ai/claude/overrides/` only for genuine shared tool-specific behavior.
12. Never create independent `.codex`, `.claude`, or `.agents` directory trees. Those paths must remain links to the canonical `.ai` assets.

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

Project-specific overrides belong in `.ai-overlay/codex/overrides/` or `.ai-overlay/claude/overrides/` and should be created only when needed.

## Prompt Registry

Prompt source files are immutable and versioned under `.ai/prompts/registry`.

Use this format:

```text
####-prompt-name.md
```

Create the next registry file whenever a shared skill, rule, command, agent, template, MCP asset, setup convention, or seed file changes. The prompt registry is the audit trail of AI-driven project evolution.
