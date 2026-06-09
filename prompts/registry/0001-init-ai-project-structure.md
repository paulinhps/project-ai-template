# 0001 - Init AI Project Structure

This file preserves the full initialization prompt used to create the shared AI and OpenSpec project structure.

````text
# Init AI-Driven Project Structure with OpenSpec

You are initializing this repository for AI-assisted development using SDD with OpenSpec.

The project will be used with both OpenAI Codex and Claude Code. Create a shared AI structure while preserving tool-specific identities when required.

## Goals

Initialize the project with:

- OpenSpec installed and initialized.
- Git repository initialized, but without any commit.
- Shared `.ai` directory as the canonical source for AI instructions.
- `.codex` as a symbolic link to `.ai`.
- `.claude` as a symbolic link to `.ai`.
- Root `AGENTS.md` documenting all decisions.
- Documentation folders for product, architecture, decisions, specs and engineering references.
- Prompt registry using immutable, incrementally numbered prompt files.

## Requirements

### 1. Create canonical AI directory

Create this structure:

```text
.ai/
├── README.md
├── rules/
├── skills/
├── commands/
├── agents/
├── templates/
├── prompts/
│   └── registry/
├── mcp/
│   ├── servers/
│   ├── configs/
│   ├── prompts/
│   └── skills/
├── codex/
│   └── overrides/
└── claude/
    └── overrides/
```

`.ai` is the source of truth for AI configuration.

### 2. Create `.codex` and `.claude` as links

Create symbolic links:

```bash
ln -s .ai .codex
ln -s .ai .claude
```

If the OS does not support symlinks, document the fallback clearly and do not duplicate the directories silently.

Important:

* Changes made through `.ai`, `.codex`, or `.claude` must affect the same underlying files.
* Preserve AI-specific identity through:

  * `.ai/codex/overrides/`
  * `.ai/claude/overrides/`

Do not create independent `.codex` and `.claude` directory trees.

### 3. Create AI documentation files

Create `.ai/README.md` explaining:

* `.ai` is canonical.
* `.codex` and `.claude` are symlinks.
* Shared folders:

  * `rules/`
  * `skills/`
  * `commands/`
  * `agents/`
  * `templates/`
  * `prompts/registry/`
  * `mcp/`
* Tool-specific overrides:

  * `codex/overrides/`
  * `claude/overrides/`

### 4. Create root `AGENTS.md`

Create `AGENTS.md` in the project root.

It must document:

* The project uses SDD with OpenSpec.
* `.ai` is the canonical AI context directory.
* `.codex` and `.claude` are symbolic links to `.ai`.
* Shared rules must live in `.ai/rules`.
* Shared skills must live in `.ai/skills`.
* Shared commands must live in `.ai/commands`.
* Shared agents must live in `.ai/agents`.
* Shared templates must live in `.ai/templates`.
* MCP-related assets must live in `.ai/mcp`.
* Codex-specific behavior must live in `.ai/codex/overrides`.
* Claude-specific behavior must live in `.ai/claude/overrides`.
* Prompt source files are immutable and versioned under `.ai/prompts/registry`.

### 5. Create prompt registry rule

Inside `.ai/prompts/registry/`, create:

```text
0001-init-ai-project-structure.md
```

This file must contain the full initialization prompt used for this setup.

Add a README or rule file explaining:

* Prompt files must use this format:

```text
####-prompt-name.md
```

Examples:

```text
0001-init-ai-project-structure.md
0002-create-dotnet-architecture-skill.md
0003-create-github-mcp.md
```

Rules:

* `####` is an incremental global number.
* Prompt files are immutable.
* Never edit an existing prompt file after it has been created.
* If a skill, rule, command, agent, template, or MCP changes, create a new prompt file documenting the change.
* The prompt registry is an audit trail of AI-driven project evolution.

### 6. Create documentation structure

Create:

```text
docs/
├── README.md
├── product/
├── business/
├── requirements/
├── architecture/
├── engineering/
├── decisions/
├── adr/
├── specs/
└── references/
```

Create minimal README files where useful.

### 7. Install and initialize OpenSpec

Install OpenSpec using the current recommended CLI:

```bash
npm install -g @fission-ai/openspec@latest
```

Then initialize OpenSpec in the project.

If the CLI provides an init command, use it.

If the exact init command differs in the installed version, run the OpenSpec help command and choose the appropriate initialization command.

After initialization, document the actual command used in `AGENTS.md`.

OpenSpec is used as the SDD source for propose → apply → archive workflows.

### 8. Initialize Git

If the repository is not already a Git repository, run:

```bash
git init
```

Do not create any commit.

Do not push anything.

### 9. Validation

After setup, verify:

```bash
ls -la
ls -la .ai
ls -la .codex
ls -la .claude
git status
```

Confirm that:

* `.codex` points to `.ai`.
* `.claude` points to `.ai`.
* `AGENTS.md` exists.
* OpenSpec files exist.
* Git is initialized.
* No commit was created.

## Output expected

At the end, provide a concise summary with:

* Created directories.
* Created files.
* OpenSpec command used.
* Git status.
* Any fallback applied, especially if symlinks were not possible.

```

Observação: o site oficial do OpenSpec recomenda instalação com `npm install -g @fission-ai/openspec@latest`, e ele lista suporte nativo para Claude Code e Codex. :contentReference[oaicite:0]{index=0}
```
````
