# Claude Code

Claude-specific behavior for users running **Claude Code** against a project that uses this canonical AI context. This file is shared Claude behavior and lives in the canonical `.ai/claude/overrides`. It does not duplicate the shared guidance in `AGENTS.md` or `README.md`; it records only what is specific to Claude Code.

## How Claude Code discovers instructions

- Claude Code automatically reads `CLAUDE.md` from the project root (and from a working subdirectory when entered) as memory.
- Claude Code does **not** read `AGENTS.md` natively. Therefore the project root must keep a short `CLAUDE.md` bridge that points to `AGENTS.md` and `.ai`.
- The bridge `CLAUDE.md` is seeded for new projects by the setup skill (`assets/seeds/CLAUDE.md`) and is short by design. The authoritative content stays in `AGENTS.md`, `.ai/rules`, and the other shared folders. Do not move shared documentation into `CLAUDE.md`.

## The `.claude` pointer vs Claude Code's own config directory

Claude Code normally uses a project-level `.claude/` directory for its own configuration (for example `settings.json`, `settings.local.json`, and `commands/`). In this structure, `.claude` is a pointer (Windows directory junction, or a symlink when available) to `.ai`, and it is gitignored. Two consequences follow:

- Anything Claude Code would write under project `.claude/` resolves into the canonical `.ai` tree and is untracked because `.claude/` is gitignored. Do not rely on project-level `.claude/` for Claude Code configuration here.
- Keep personal Claude Code configuration at the user level (`~/.claude`) instead of the project `.claude/` pointer.

This structure keeps the `.claude` junction (the canonical model is preserved) and does not create an independent `.claude` tree. If a project genuinely needs shared Claude instructions, put them in `.ai/claude/overrides`. If it needs project-specific Claude instructions, put them in `.ai-overlay/claude/overrides`, created only when needed.

## Bootstrap and replication for Claude Code users

1. Fork or create the project and place the canonical `.ai` context in the project root (clone the shared `.ai` repository, or copy it for a local bootstrap). See `README.md` "Start a New Project from Zero".
2. From the project root, run the setup skill prompt:

   ```text
   initialize project using .ai/skills/setup-ai-environment/SKILL.md skill
   ```

   The setup skill seeds the root `CLAUDE.md` bridge alongside `AGENTS.md`, creates the `.codex`/`.claude`/`.agents` pointers, and registers or ignores `.ai` per `.ai/rules/repository-submodule-references.md`.
3. Open the project in Claude Code. It reads root `CLAUDE.md`, which directs it to `AGENTS.md` and the `.ai` context.

## Windows junctions and symlinks

True symbolic links can require administrator privileges on Windows. The setup script creates symbolic links when permitted and falls back to directory junctions otherwise. Because Git traverses these junctions as directories on Windows, `.codex/`, `.claude/`, and `.agents/` are gitignored; canonical files are tracked only through `.ai`. This applies identically to Claude Code.

## Optional SDD / OpenSpec flow

SDD and planning tools (including an OpenSpec `propose -> apply -> archive` flow) are **optional opt-ins**, not part of this canonical setup. No such tool is wired by default. Configure one only when the user explicitly asks for that specific tool, and register the rules, skills, commands, agents, templates, MCP assets, prompts, or overrides it requires under `.ai-overlay`, not under canonical `.ai`, unless the user explicitly asks to evolve the shared context. The same rule applies whether the requesting agent is Claude Code or another tool.
