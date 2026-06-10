# Create Dotnet Exceptionless Domain Modeling Skill

Created the shared `dotnet-exceptionless-domain-modeling` skill as an extension and partial override of `dotnet-domain-modeling`.

The skill guides AI agents in Result-Oriented Domain Modeling for .NET domains, preserving rich DDD models and invariant protection while avoiding exceptions for expected business failures.

The skill defines reusable guidance for:

- Applying all `dotnet-domain-modeling` rules unless explicitly overridden.
- Returning `Result`, `Result<T>`, `ValidationResult`, `OperationResult`, or equivalent explicit outcomes for expected business failures.
- Avoiding `DomainException` as normal validation or business flow.
- Using centralized domain errors and notification patterns where appropriate.
- Creating entities, value objects, aggregates, and domain services that prevent invalid state without exception-driven flow.
- Emitting domain events only after successful, consistent operations.
- Mapping results to APIs without `try`/`catch` for expected domain failures.
- Testing returned results, errors, error codes, and domain rules instead of expected business exceptions.
- Reviewing existing code for validation by exception, `try`/`catch` driven domain flow, hidden business errors, and gradual result-pattern refactors.

The skill was added at:

```text
.ai/skills/dotnet-exceptionless-domain-modeling/SKILL.md
```

This prompt registry entry records the AI-driven change to shared skill behavior.
