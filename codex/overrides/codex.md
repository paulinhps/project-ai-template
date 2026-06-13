# Codex

Codex-specific behavior for users running Codex against a project that uses this canonical AI context. This file is shared Codex behavior and lives in the canonical `.ai/codex/overrides`. It records only what is specific to Codex; shared guidance belongs in `AGENTS.md`, `.ai/rules`, and the other shared folders.

## How Codex discovers instructions

- Codex uses `AGENTS.md` as the shared root operating guide.
- `AGENTS.md` remains the canonical project entry point even when other tools require bridge files such as `CLAUDE.md`.
- A project initialized for Codex creates or preserves a `.codex` pointer to `.ai` when Codex-specific path identity is activated.

## The `.codex` pointer

In this structure, `.codex` is a pointer to `.ai` and must not become an independent tree. Shared Codex-specific behavior belongs in `.ai/codex/overrides`. Project-specific Codex behavior belongs in `.ai-overlay/codex/overrides`, created only when needed.

Keep personal Codex configuration outside the canonical `.ai` tree unless a project explicitly documents a shared configuration requirement.

## Setup activation

The setup skill can initialize a root for Codex-only, Claude-only, or both Codex and Claude:

```bash
node .ai/skills/setup-ai-environment/scripts/setup-ai-environment.mjs --ai-tool codex
node .ai/skills/setup-ai-environment/scripts/setup-ai-environment.mjs --ai-tool claude
node .ai/skills/setup-ai-environment/scripts/setup-ai-environment.mjs --ai-tool both
```

`both` is the compatibility default. Use a narrower tool activation when the root should expose only the active AI surface.
