---
name: dotnet-canonical-review
description: Guide AI agents in executing complete read-first canonical reviews of .NET projects hosted under an `.ai`-based repository structure. Use when auditing .NET architecture, technical debt, operational readiness, canonical skill compliance, local overlays, documentation, ADRs, OpenSpec, source structure, code quality, tests, APIs, persistence, security, observability, microservice boundaries, and reusable component governance, with persistent review artifacts and a scored remediation roadmap.
---

# Dotnet Canonical Review

Use this skill to run a complete architectural, technical, operational, and organizational audit of a .NET project in a canonical `.ai` repository. Treat `.ai` as the shared source of AI standards and local overlays as the project-specific source of truth.

## Operating Mode

Start in **READ ONLY** mode:

1. Do not modify product source files.
2. Do not execute fixes.
3. Do not create commits.
4. Do not start by proposing code changes.
5. First produce a complete diagnosis.

Persist audit artifacts only after the diagnosis is complete, or when the current user request explicitly asks for a persisted audit. Persistence is limited to review documentation and machine-readable audit state; it must not include source-code fixes.

## Project Discovery

Before any audit, identify the project to review.

If the user provides a project path or name, normalize it to:

```text
sources/<project-name>
```

Examples:

```text
sources/agua-em-casa-backend
agua-em-casa-backend
```

If the project is not provided, stop and ask only:

```text
Qual projeto deseja analisar?

Exemplos:

sources/agua-em-casa-backend
sources/platform-backend
sources/backend
```

Do not continue the audit until the project is defined.

## Mandatory Canonical Skills

Load and apply these skills before issuing findings:

```text
dotnet-clean-architecture
dotnet-domain-modeling
dotnet-exceptionless-domain-modeling
dotnet-rest-api-design
dotnet-api-contracts
dotnet-security-baseline
dotnet-efcore-persistence
dotnet-unit-testing
dotnet-microservices-patterns
dotnet-coding-standards
dotnet-error-handling
dotnet-observability
dotnet-reusability-patterns
dotnet-project-structure
dotnet-ai-repository-structure
```

If a skill is unavailable, report it in `Documentation Gaps` and continue with the best available local rule or documented convention.

## Context Sources

Review the project source tree and all relevant AI, documentation, and governance context:

```text
sources/<project-name>/**
docs/**
sources/<project-name>/docs/**
README.md
CHANGELOG.md
.ai/rules/**
.ai/skills/**
.ai/commands/**
.ai/agents/**
.ai/workflows/**
.ai/templates/**
.ai/docs/**
.ai-overlay/**
.ai-overlays/**
ADRs
OpenSpec
```

Support both `.ai-overlay` and `.ai-overlays` because repositories may use either naming convention. Prefer the overlay path that exists in the current repository.

## Rule Precedence

Resolve conflicts by applying the most specific and nearest documented rule:

```text
1. Project overlay rules and assets: .ai-overlay/** or .ai-overlays/**
2. Explicit project rules
3. ADRs
4. OpenSpec
5. Canonical skills
6. Implicit repository conventions
```

Before starting technical judgment, produce an `Effective Ruleset` that names the rules, skills, overlays, ADRs, OpenSpec entries, and conventions actually applied. Do not assume the canonical skills are the final state of the ecosystem when newer overlays or documented project decisions exist.

Internal discovery-control instructions must guide the audit, but must not be copied into generated review artifacts as standalone policy text.

## Audit Phases

Execute the phases in order. Map evidence before judging.

### Phase 1 - Context Discovery

Identify:

- System objective.
- Business context.
- Bounded contexts.
- Stakeholders.
- Use cases.
- Declared architecture.
- Effective architecture observed in code.

Primary sources:

```text
docs/**
sources/<project-name>/docs/**
README.md
ADRs
OpenSpec
```

### Phase 2 - Effective Rules Discovery

Identify:

- Applicable skills.
- Project overlays.
- Specific rules.
- Architectural exceptions.
- More recent local decisions.

Output:

```text
Effective Ruleset
```

### Phase 3 - Physical Structure

Apply `dotnet-project-structure` and `dotnet-ai-repository-structure`.

Evaluate organization, modularization, test structure, documentation structure, microservice structure, building blocks, repository references, `.ai` layout, and overlay usage.

### Phase 4 - Architecture

Apply `dotnet-clean-architecture`.

Evaluate dependency direction, dependency inversion, layer boundaries, cohesion, coupling, feature folders, application use cases, composition roots, and cross-project references.

### Phase 5 - Domain

Apply `dotnet-domain-modeling` and `dotnet-exceptionless-domain-modeling`.

Evaluate entities, aggregates, value objects, domain events, invariants, Result Pattern, domain errors, domain exceptions, aggregate boundaries, and framework independence.

### Phase 6 - APIs

Apply `dotnet-rest-api-design` and `dotnet-api-contracts`.

Evaluate endpoints, routes, contracts, versioning, response consistency, serialization, payload shape, enum serialization, status codes, pagination, filtering, sorting, and ProblemDetails shape.

### Phase 7 - Persistence

Apply `dotnet-efcore-persistence`.

Evaluate DbContexts, migrations, persistence entities, EF configurations, indexes, query performance, transaction boundaries, tracking, repositories, Unit of Work, and persistence coupling.

### Phase 8 - Tests

Apply `dotnet-unit-testing`.

Evaluate coverage, unit-test focus, test builders, organization, test quality, determinism, naming, maintainability, and testability of application and domain code.

### Phase 9 - Code

Apply `dotnet-coding-standards`.

Evaluate language consistency, glossary usage, naming, namespaces, classes, records, structs, enums, immutability, file organization, and idiomatic C#.

### Phase 10 - Security

Apply `dotnet-security-baseline`.

Evaluate authentication, authorization, input validation, secrets handling, secure logging, data exposure, CORS, rate limiting, file uploads, webhook validation, and error disclosure.

### Phase 11 - Error Handling

Apply `dotnet-error-handling`.

Evaluate Result Pattern usage, domain errors, exceptionless flows, DomainException usage, external exception capture, global middleware, ProblemDetails mapping, correlation IDs, and safe responses.

### Phase 12 - Observability

Apply `dotnet-observability`.

Evaluate structured logs, correlation IDs, trace IDs, health checks, metrics, distributed tracing, external-call instrumentation, messaging telemetry, safe logging, and production diagnostics.

### Phase 13 - Microservices

Apply `dotnet-microservices-patterns`.

Evaluate bounded contexts, service autonomy, integrations, integration events, outbox, sagas, resilience, idempotency, observability, versioned contracts, and data ownership.

If the reviewed project is not a microservice, mark unsupported microservice concerns as `Not Applicable` and still evaluate whether the architecture accidentally creates distributed-system risks.

### Phase 14 - Reuse

Apply `dotnet-reusability-patterns`.

Evaluate shared kernels, building blocks, shared contracts, internal SDKs, duplication, inappropriate reuse, coupling, ownership, and sustainable package boundaries.

## Missing Information

If documentation is insufficient to conclude the audit, stop before final approval and produce:

```text
Missing Information Report
```

Ask only questions required to continue. Examples:

```text
1. O projeto utiliza microserviços?
2. Existe decisão sobre Result Pattern?
3. Existe decisão sobre banco compartilhado?
4. Existe ADR para eventos?
```

After receiving answers, resume the audit and include the answers in traceability.

## Severity And Scoring

Use these severities:

```text
Critical
High
Medium
Low
Info
```

Start from:

```text
100
```

Subtract:

```text
Critical = 15
High = 8
Medium = 3
Low = 1
Info = 0
```

Clamp the final score to:

```text
0..100
```

The project is approved only when:

```text
Score >= 90
Critical = 0
High = 0
```

## Finding IDs

Every finding must have a stable unique ID.

Use category prefixes such as:

```text
ARCH-001
DDD-001
API-001
EF-001
TEST-001
CODE-001
SEC-001
ERR-001
OBS-001
MICRO-001
REUSE-001
STRUCT-001
DOC-001
OPS-001
```

Do not emit findings without IDs.

## Required Output

Produce this report shape:

```text
Canonical Compliance Score: XX/100
```

### Executive Summary

Summarize approval status, score drivers, most urgent risks, and recommended next move.

### Architecture Overview

Describe the declared architecture and the effective architecture observed in source code.

### Effective Ruleset

List applied skills, overlays, explicit project rules, ADRs, OpenSpec entries, and conventions. Identify conflicts and which rule won by precedence.

### Findings By Severity

| Severity | Id | Skill | File | Issue | Impact | Recommendation |
|-----------|----|--------|------|--------|----------|----------------|

### Skill Compliance Matrix

| Skill | Compliance |
|---------|-------------|

Use only:

```text
Pass
Partial
Fail
Not Applicable
```

### Architecture Risks

Separate:

```text
Immediate Risks
Future Risks
Technical Debt
```

### Documentation Gaps

List missing ADRs, missing OpenSpec, missing glossary, missing decisions, and unclear ownership.

### Refactoring Opportunities

Separate:

```text
Quick Wins
Medium Effort
Large Refactors
```

### Recommended Execution Plan

Generate a phased roadmap ordered by risk reduction, dependency order, and expected blast radius.

### Pull Request Plan

Generate suggested PRs or commits using Conventional Commit style:

```text
PR-01
feat(architecture): isolate infrastructure dependencies

PR-02
feat(testing): introduce immutable test builders

PR-03
feat(observability): add correlation id propagation
```

## Persistence

The audit must not exist only in chat.

Write human-readable artifacts to:

```text
docs/reviews/<project-name>/
```

Required files:

```text
review-yyyy-mm-dd.md
roadmap.md
history.md
```

Write machine-readable agent artifacts to:

```text
.ai/reviews/<project-name>/
```

Required files:

```text
latest.json
review-yyyy-mm-dd.json
roadmap.json
```

Use the current local date for `yyyy-mm-dd`. Do not overwrite immutable dated snapshots. Update `latest.json`, `roadmap.md`, `roadmap.json`, and append or refresh `history.md` as the living audit state.

Minimum JSON shape:

```json
{
  "project": "agua-em-casa-backend",
  "score": 82,
  "critical": 0,
  "high": 2,
  "medium": 5,
  "low": 8,
  "findings": [
    {
      "id": "ARCH-001",
      "severity": "High",
      "skill": "dotnet-clean-architecture",
      "description": "Application references Infrastructure."
    }
  ]
}
```

Include enough structured data for future automation: project, date, score, approval status, counts, findings, compliance matrix, documentation gaps, risks, roadmap items, suggested PRs, evidence, and unresolved questions.

## Decision Checklist

Before concluding, answer yes or no:

1. Were all applicable skills evaluated?
2. Were overlays loaded?
3. Is documentation sufficient?
4. Was the score calculated?
5. Does every finding have an ID?
6. Does a roadmap exist?
7. Does an execution plan exist?
8. Does persistent history exist?
9. Does a structured backlog exist?
10. Is audit traceability present?

If any answer is no, do not mark the project approved.

## Prohibited Anti-Patterns

Reject these outcomes:

- **Chat Only Review**: Audit exists only in chat.
- **Ignore Overlays**: Local overlays were not considered.
- **Architecture Without Context**: Architecture judged before reading documentation.
- **Missing Findings IDs**: Findings lack stable IDs.
- **No Roadmap**: Audit has no execution plan.
- **No Persistence**: Audit has no persisted artifacts.
- **Fix While Reviewing**: Agent changes source code without explicit request.
- **Skill Isolation**: Agent evaluates one skill while ignoring the canonical ecosystem.

Always prioritize traceability, architectural governance, consistency, and continuous evolution.
