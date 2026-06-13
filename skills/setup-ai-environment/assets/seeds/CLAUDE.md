# CLAUDE.md

Claude Code reads this file automatically as project memory. It is a short bridge to the canonical AI context. It does not duplicate that context.

## Discovery order

1. Read `AGENTS.md` in this project root for the shared operating guide.
2. Load `.ai/` — the canonical AI context: rules, skills, commands, agents, templates, MCP assets, and the prompt registry.
3. Load `.ai-overlay/` after `.ai` for project-specific context, when present.
4. For Claude-specific behavior, read `.ai/claude/overrides/`.

## Rules for Claude Code

- `.ai` is the canonical source of truth. Do not duplicate it into `.claude`.
- `.claude`, `.codex`, and `.agents` are pointers (Windows directory junctions, or symlinks when available) to `.ai`. They are gitignored and must not become independent trees.
- `.claude` resolves into `.ai`, so do not rely on project-level `.claude/` for Claude Code's own settings; use user-level `~/.claude` for personal Claude Code configuration. See `.ai/claude/overrides/claude-code.md`.
- Put shared changes in `.ai`, Claude-specific shared changes in `.ai/claude/overrides`, and project-specific changes in `.ai-overlay` (only when needed).
- Follow `.ai/rules/conventional-commits.md` and `.ai/rules/repository-submodule-references.md`.
- Prompt files in `.ai/prompts/registry` are immutable; add the next sequential file and never edit existing ones.
