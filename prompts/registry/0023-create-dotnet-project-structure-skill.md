# 0023 - Create dotnet-project-structure skill

## Request

Create a reusable AI skill named `dotnet-project-structure` in the canonical AI configuration repository.

The skill should guide AI agents when creating, organizing, reviewing, and evolving the physical structure of .NET solutions.

## Scope

- Define physical structure guidance for .NET repositories, solutions, projects, modules, bounded contexts, and microservices.
- Clarify that Clean Architecture and domain modeling define logical architecture while this skill defines physical organization.
- Cover root repository layout, `src/`, `tests/`, `docs/`, `tools/`, `scripts/`, `deploy/`, and `build/`.
- Include recommended structures for modular monoliths, microservices, Clean Architecture layers, contracts, Building Blocks, and Shared Kernel.
- Include guidance for feature organization, namespaces, solution files, documentation, ADRs, test projects, architecture tests, and test support.
- Define decision criteria, prohibited anti-patterns, existing-structure analysis workflow, new-structure creation workflow, and validation checklist.
- Include practical correct and incorrect examples.

## Artifacts

- `.ai/skills/dotnet-project-structure/SKILL.md`
- `.ai/skills/dotnet-project-structure/agents/openai.yaml`

## Notes

The skill is intentionally self-contained and does not require scripts, references, or assets.
