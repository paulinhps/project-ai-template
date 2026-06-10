# Create Dotnet REST API Design Skill

Created the shared `dotnet-rest-api-design` skill for reusable guidance on designing REST APIs in .NET applications.

The skill guides AI agents in creating, evolving, reviewing, and maintaining HTTP API presentation layers while preserving Clean Architecture boundaries.

The skill defines reusable guidance for:

- Designing resource-oriented REST routes.
- Applying HTTP method semantics and status codes.
- Creating explicit request and response DTOs.
- Avoiding domain and EF entity leakage in API contracts.
- Mapping explicit Result Pattern outcomes to HTTP responses.
- Standardizing API errors with `ProblemDetails` or the project equivalent.
- Applying pagination, filtering, sorting, idempotency, and versioning.
- Documenting endpoints with OpenAPI/Swagger metadata.
- Considering basic API security concerns.
- Keeping controllers and Minimal APIs thin.
- Reviewing existing APIs for route, contract, error, compatibility, and Presentation-layer issues.

The skill was added at:

```text
.ai/skills/dotnet-rest-api-design/SKILL.md
```

This prompt registry entry records the AI-driven change to shared skill behavior.
