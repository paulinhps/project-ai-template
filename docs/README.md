# Canonical Documentation

This folder stores documentation that belongs to the reusable `.ai` context itself.

Use `.ai/docs` for decisions, architecture notes, and operating explanations that define how the canonical AI context should be reused across projects, AI tools, and operating systems.

Do not use this folder for project-root business decisions, product notes, requirements, or source-module documentation. That material belongs in the root `docs/` folder and applies to the projects coordinated by that root, especially repositories under `sources/`.

## Documentation Boundaries

- `.ai/docs`: reusable canonical AI-context documentation.
- `.ai/prompts/registry`: immutable audit trail of AI-driven canonical evolution.
- Root `docs`: project-wide business, product, engineering, architecture, and decision documentation for the current root workspace.
- `.ai-overlay`: project-specific AI rules, skills, commands, agents, templates, MCP assets, prompts, notes, and overrides.
- `sources`: real source repositories evolved or referenced by the root workspace.

## ADRs

Canonical architectural decision records live under:

```text
.ai/docs/adr/
```

Root architectural decision records live under:

```text
docs/adr/
```

Choose the location by ownership. If the decision defines the reusable `.ai` model, store it in `.ai/docs/adr`. If the decision governs the root workspace or the projects under `sources`, store it in root `docs/adr`.
