# AI Overlay

`.ai-overlay` stores AI context that belongs to this project root and is versioned with the root repository.

Use `.ai-overlay` for project-specific rules, skills, commands, agents, templates, MCP assets, prompts, notes, and overrides that should not become part of the reusable `.ai` canonical context.

Create folders only when needed. Supported structure mirrors `.ai`:

```text
.ai-overlay/
  agents/
  claude/overrides/
  codex/overrides/
  commands/
  mcp/
  prompts/registry/
  rules/
  skills/
  templates/
```

Default decision:

- Add new project-specific AI assets here.
- Update `.ai` only when the user explicitly asks to evolve the canonical shared context.
- Load `.ai` first, then `.ai-overlay` as the project-specific overlay.
