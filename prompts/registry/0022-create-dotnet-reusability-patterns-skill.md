# 0022 - Create dotnet-reusability-patterns skill

## Request

Create a reusable AI skill named `dotnet-reusability-patterns` in the canonical AI configuration repository.

The skill should guide AI agents when creating, reviewing, refactoring, and evolving reusable components in .NET applications.

## Scope

- Define evidence-based reuse guidance for .NET systems.
- Cover legitimate reuse opportunities, premature abstraction risks, DRY/YAGNI tradeoffs, Building Blocks, shared libraries, shared contracts, Shared Kernel, shared value objects, technical behaviors, and package evolution.
- Clarify that domain modeling and Clean Architecture boundaries take precedence over reuse.
- Define what is usually reusable and what should not be shared.
- Provide guidance for microservices, internal SDKs, extension methods, shared packages, versioning, ownership, and coupling analysis.
- Include practical correct and incorrect examples.
- Include analysis and creation workflows.
- Include prohibited anti-patterns and a validation checklist.

## Artifacts

- `.ai/skills/dotnet-reusability-patterns/SKILL.md`
- `.ai/skills/dotnet-reusability-patterns/agents/openai.yaml`

## Notes

The skill is intentionally self-contained and does not require scripts, references, or assets.
