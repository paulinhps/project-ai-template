# Create Dotnet Microservices Patterns Skill

Created the shared `dotnet-microservices-patterns` skill for reusable guidance on creating, reviewing, evolving, and maintaining .NET microservice architectures.

The skill complements the existing .NET guidance by owning distributed-system architecture and service interactions while deferring internal service structure to `dotnet-clean-architecture` and domain modeling decisions to `dotnet-domain-modeling`.

The skill defines reusable guidance for:

- Validating whether a microservice is justified before introducing distributed complexity.
- Identifying bounded contexts and service boundaries from business capabilities.
- Preserving autonomous services, independent deployment, and independent data ownership.
- Avoiding shared databases, integration by database, chatty services, distributed monoliths, and premature microservices.
- Choosing synchronous REST or gRPC communication only when immediate responses are required.
- Choosing asynchronous messaging for decoupled workflows and eventual consistency.
- Designing versioned REST, gRPC, event, message, and webhook contracts.
- Creating integration events as completed business facts rather than intentions.
- Applying Outbox Pattern, idempotency, bounded retries, dead-letter queues, timeouts, circuit breakers, and bulkheads.
- Designing consistency boundaries, Saga workflows, orchestration, choreography, and anti-corruption layers.
- Requiring structured logs, CorrelationId propagation, distributed tracing, metrics, health checks, and message telemetry.
- Enforcing per-service security, input validation, message validation, and secret protection.
- Designing for horizontal scalability, stateless instances where possible, and independent resource ownership.
- Reviewing existing distributed architectures with prioritized findings.
- Creating new microservices with explicit contracts, observability, resilience, security, versioning, and deployment independence.

The skill was added at:

```text
.ai/skills/dotnet-microservices-patterns/SKILL.md
```

This prompt registry entry records the AI-driven change to shared skill behavior.
