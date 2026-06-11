# 0021 - Create dotnet-observability skill

## Request

Create a reusable AI skill named `dotnet-observability` in the canonical AI configuration repository.

The skill should guide AI agents when creating, reviewing, and standardizing observability in .NET applications, APIs, workers, microservices, jobs, queue consumers, and distributed integrations.

## Scope

- Define observable-by-default guidance for production-ready .NET systems.
- Standardize structured logging, log levels, safe logging, technical logs, business logs, exception logs, and exceptionless failure logging.
- Define correlation id generation, acceptance, propagation, and logging using `X-Correlation-Id`.
- Explain coexistence between correlation id and trace ids such as `TraceId`, `SpanId`, and `ParentId`.
- Guide distributed tracing for HTTP, database, cache, messaging, jobs, and external integrations, with OpenTelemetry examples.
- Guide actionable metrics with low-cardinality labels.
- Guide liveness, readiness, and dependency health checks.
- Cover observability for APIs, workers, messaging, external integrations, and database access.
- Include guidance for alerts, dashboards, troubleshooting, review workflows, creation workflows, decision criteria, prohibited anti-patterns, and validation checklist.
- Include practical correct and incorrect examples.

## Artifacts

- `.ai/skills/dotnet-observability/SKILL.md`
- `.ai/skills/dotnet-observability/agents/openai.yaml`

## Notes

The skill is intentionally self-contained and does not require scripts, references, or assets.
