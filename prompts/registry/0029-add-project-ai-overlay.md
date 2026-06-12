# 0029 - Add Project AI Overlay

## Prompt

The project structure must recognize a `.project-ai` directory for AI context that belongs to the root project and is versioned together with the root repository.

`.project-ai` must have the same conceptual structure as `.ai`, but it must not initialize with the complete tree. It starts with `README.md` and grows as project-specific context is needed.

`setup-ai-environment` must manage `.project-ai/README.md`.

Any rule, skill, command, agent, template, MCP asset, prompt, note, or override that is specific to the current project should be registered in `.project-ai` by default, unless the user explicitly asks to change the canonical `.ai` context.

Update `AGENTS.md` and related documentation to apply these rules.

## Decisions

- Keep `.ai` as the reusable canonical AI context.
- Add `.project-ai` as the project-specific overlay, versioned by the root repository.
- Initialize only `.project-ai/README.md` during setup.
- Create `.project-ai` subdirectories only when needed.
- Load `.ai` first and `.project-ai` second when both are present.
- Route project-specific AI assets to `.project-ai` by default.

## Updated Assets

- `.ai/skills/setup-ai-environment/SKILL.md`
- `.ai/skills/setup-ai-environment/scripts/setup-ai-environment.ps1`
- `.ai/skills/setup-ai-environment/assets/seeds/AGENTS.md`
- `.ai/skills/setup-ai-environment/assets/seeds/PROJECT_AI_README.md`
- `.ai/skills/dotnet-ai-repository-structure/SKILL.md`
- `.ai/README.md`
- `AGENTS.md`
- `.project-ai/README.md`
