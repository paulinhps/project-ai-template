# 0024 - Create dotnet-ai-repository-structure skill

## Request

Create a reusable AI skill named `dotnet-ai-repository-structure` in the canonical AI configuration repository.

The skill should guide AI agents when creating, reviewing, or repairing repositories that use canonical AI context at the root and .NET projects under `sources/`.

## Scope

- Define deterministic orchestration between `configurar-ambiente-ai` and `dotnet-project-structure`.
- Clarify that `.ai`, `.codex`, `.claude`, `.agents`, OpenSpec, root `docs/`, `sources/`, `.gitignore`, `.gitmodules`, and root Git setup belong to the repository root.
- Clarify that .NET source code, tests, solutions, projects, project documentation, scripts, tools, deploy, and build assets belong under `sources/<dotnet-project>/`.
- Prohibit creating `.ai`, `.codex`, `.claude`, or `.agents` inside .NET project roots during the standard flow.
- Preserve Git submodule boundaries and distinguish root commits from project repository commits.
- Define creation, existing-structure analysis, decision, validation, documentation separation, and anti-pattern guidance.
- Include correct examples for single-project, multi-project, and microservice backend workspaces.

## Artifacts

- `.ai/skills/dotnet-ai-repository-structure/SKILL.md`
- `.ai/skills/dotnet-ai-repository-structure/agents/openai.yaml`

## Notes

The skill is intentionally self-contained and does not require scripts, references, or assets.
