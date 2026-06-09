# AI Project Context

`.ai` is the canonical source of truth for AI-assisted development in this repository.

`.codex` and `.claude` are links to `.ai`, so changes made through `.ai`, `.codex`, or `.claude` affect the same underlying files. On this Windows environment, true symbolic links required administrator privileges, so directory junctions were used as the non-duplicating fallback.

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
- `agents/overrides/`: Codex-specific behavior and local overrides.
- `claude/overrides/`: Claude-specific behavior and local overrides.

Shared behavior should live in shared folders first. Use tool-specific override folders only when Codex and Claude need different behavior.
