# 0019 - Create dotnet-coding-standards skill

## Request

Create a reusable AI skill named `dotnet-coding-standards` in the canonical AI configuration repository.

The skill should guide AI agents such as Codex, Claude Code, Gemini CLI, Cursor, Windsurf, and similar tools when creating, reviewing, refactoring, and standardizing C#/.NET code for backend applications, APIs, workers, libraries, and microservices.

## Scope

- Standardize C#/.NET naming, language, namespaces, type selection, file organization, comments, nullability, async code, exceptions, Result Pattern usage, DTOs, and tests.
- Prefer English-first code while preserving ubiquitous language through a technical domain glossary.
- Coordinate with existing .NET skills for clean architecture, domain modeling, exceptionless domain modeling, REST API design, API contracts, and unit testing.
- Include practical examples for correct and incorrect naming, interfaces, records, structs, enums, namespaces, glossary usage, and translation decisions.
- Include workflows, decision questions, prohibited anti-patterns, and a validation checklist.

## Artifacts

- `.ai/skills/dotnet-coding-standards/SKILL.md`
- `.ai/skills/dotnet-coding-standards/agents/openai.yaml`

## Notes

The skill is intentionally self-contained and does not require scripts, references, or assets.
