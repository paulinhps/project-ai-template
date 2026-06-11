# 0020 - Create dotnet-error-handling skill

## Request

Create a reusable AI skill named `dotnet-error-handling` in the canonical AI configuration repository.

The skill should guide AI agents such as Codex, Claude Code, Gemini CLI, Cursor, Windsurf, and similar tools when creating, reviewing, and standardizing error handling, expected failures, exceptions, validations, and error responses in .NET applications.

## Scope

- Differentiate expected business failures, validation failures, expected technical failures, and unexpected failures.
- Prefer exceptionless structures such as `Result`, `Result<T>`, `ValidationResult`, `OperationResult`, `Notification`, and `Error`.
- Standardize domain errors, stable error codes, optional `DomainException` usage for exception-based projects, and safe API error exposure.
- Capture known external exceptions near their source and convert them into explicit project errors.
- Define global exception handling responsibilities for unexpected failures.
- Map result errors to HTTP responses and `ProblemDetails` while preserving API contract and security boundaries.
- Include guidance for safe logs, correlation ids, observability, decision questions, prohibited anti-patterns, and completion review.
- Include practical correct and incorrect examples for Result Pattern, validation, domain errors, DomainException, external exception capture, global exception handling, HTTP mapping, ProblemDetails, and logging.

## Artifacts

- `.ai/skills/dotnet-error-handling/SKILL.md`
- `.ai/skills/dotnet-error-handling/agents/openai.yaml`

## Notes

The skill is intentionally self-contained and does not require scripts, references, or assets.
