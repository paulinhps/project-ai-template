# Create Dotnet EF Core Persistence Skill

Created the shared `dotnet-efcore-persistence` skill for reusable guidance on implementing, reviewing, and evolving Entity Framework Core persistence in .NET applications.

The skill complements the existing .NET guidance by owning persistence concerns while deferring layer boundaries, domain modeling, exceptionless domain behavior, security, testing, and observability to their specialized skills when available.

The skill defines reusable guidance for:

- Keeping EF Core isolated in Infrastructure.
- Creating `DbContext` implementations without business logic.
- Configuring entities with Fluent API and one mapping file per entity.
- Mapping domain entities, value objects, enums, relationships, backing fields, and indexes.
- Creating and reviewing descriptive, versioned migrations.
- Using repositories and Unit of Work abstractions only when they add architectural value.
- Designing explicit queries with projection, pagination, tracking control, and cancellation.
- Avoiding N+1 behavior, excessive includes, and lazy loading by default.
- Configuring transactions and optimistic concurrency when required.
- Applying safe raw SQL, secure configuration, and sensitive-data-safe logging.
- Choosing integration-test strategies that validate real relational behavior.
- Reviewing existing persistence code for architecture, correctness, performance, security, and testability risks.

The skill was added at:

```text
.ai/skills/dotnet-efcore-persistence/SKILL.md
```

This prompt registry entry records the AI-driven change to shared skill behavior.
