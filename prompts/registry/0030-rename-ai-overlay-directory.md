# 0030 - Rename AI Overlay Directory

## Prompt

Rename the project-specific AI context directory from `.project-ai` to `.ai-overlay`.

## Decisions

- Use `.ai-overlay` as the root-versioned project-specific AI context overlay.
- Keep `.ai` as the reusable canonical context.
- Initialize only `.ai-overlay/README.md`.
- Create `.ai-overlay` subdirectories only when project-specific context is needed.
- Load `.ai` first and `.ai-overlay` second.
- Register project-specific rules, skills, commands, agents, templates, MCP assets, prompts, notes, and overrides in `.ai-overlay` by default.
- Update active setup, repository-structure, seed, and root guidance documents.

## Updated Assets

- `AGENTS.md`
- `.ai/README.md`
- `.ai/skills/setup-ai-environment/SKILL.md`
- `.ai/skills/setup-ai-environment/scripts/setup-ai-environment.ps1`
- `.ai/skills/setup-ai-environment/assets/seeds/AGENTS.md`
- `.ai/skills/setup-ai-environment/assets/seeds/AI_OVERLAY_README.md`
- `.ai/skills/dotnet-ai-repository-structure/SKILL.md`
- `.ai-overlay/README.md`
