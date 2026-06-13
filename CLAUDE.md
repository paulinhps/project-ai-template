# CLAUDE.md

This repository is the canonical AI context (`.ai`) for AI-assisted development. Claude Code reads this file automatically as project memory. Claude Code does **not** read `AGENTS.md` natively, so this file is the discovery bridge for Claude Code. It does not duplicate the canonical context; it points to it.

## Read first

- `README.md` — full structure, bootstrap sequence, and usage of the `.ai` context.
- `claude/overrides/claude-code.md` — Claude Code specifics: discovery, the `.claude` junction, Windows notes, bootstrap, and the optional SDD/OpenSpec flow.
- `rules/` — operating rules every agent must follow, including `rules/conventional-commits.md` and `rules/repository-submodule-references.md`.

## Canonical rules (do not violate)

- The contents of this repository are the canonical `.ai` context and the single source of truth.
- In a generated project, `.codex`, `.claude`, and `.agents` are pointers (Windows directory junctions, or symlinks when available) to `.ai`. Never turn them into independent trees and never duplicate `.ai` content into them.
- Put shared behavior in the shared folders first: `rules/`, `skills/`, `commands/`, `agents/`, `templates/`, `mcp/`.
- Put Claude-specific shared behavior in `claude/overrides/`. In a generated project, project-specific context goes in `.ai-overlay/` (and `.ai-overlay/claude/overrides/` for project-specific Claude behavior), only when needed.
- Prompt files under `prompts/registry/` are immutable. Add a new sequential `####-name.md`; never edit existing ones.
