---
name: dotnet-project-structure
description: Guide AI agents in creating, organizing, reviewing, and evolving the physical structure of .NET repositories, solutions, projects, bounded contexts, modular monoliths, microservices, tests, documentation, Building Blocks, Shared Kernel, shared contracts, scripts, tools, and deploy assets. Use when creating a new .NET solution, service, module, bounded context, project layout, test layout, documentation layout, repository review, structural refactor, or architecture evolution.
---

# Dotnet Project Structure

Use this skill to make the physical structure of .NET systems predictable, scalable, navigable, and aligned with the architecture chosen by the project. The directory and project layout must express architecture and domain boundaries; it must not define them by accident.

## Related Skills

Coordinate with these skills when they exist:

- `dotnet-clean-architecture`: owns logical architecture, dependency direction, and layer rules.
- `dotnet-domain-modeling`: owns bounded contexts, aggregates, value objects, domain events, and invariants.
- `dotnet-microservices-patterns`: owns service autonomy, distributed boundaries, messaging, and service extraction decisions.
- `dotnet-coding-standards`: owns naming, namespaces, file organization, and idiomatic C#.
- `dotnet-reusability-patterns`: owns shared components, Building Blocks, contracts, and reuse decisions.
- `dotnet-unit-testing`: owns test style, test builders, fakes, fixtures, and test boundaries.

When responsibilities conflict, Clean Architecture defines the logical architecture, domain modeling defines domain boundaries, and this skill defines physical directories, projects, solution files, and repository organization. Physical structure must reflect the architecture, not override it.

## Required Principles

- **Structure Follows Architecture**: Make layers, modules, services, and boundaries visible in the file system.
- **Structure Follows Domain**: Make bounded contexts easy to find before technical details.
- **Explicit Boundaries**: Keep module, service, context, and shared-component ownership visible.
- **Consistency First**: Similar modules and services must follow the same physical pattern.
- **Scalability**: Choose structures that can grow without frequent reorganizations.
- **Discoverability**: A developer should predict where any artifact belongs before searching.
- **Low Physical Coupling**: Avoid shared directories and projects that hide dependencies or blur ownership.

## Operating Workflow

When creating or changing .NET structure:

1. Inspect existing repositories, solutions, projects, namespaces, references, tests, and docs.
2. Identify the target architecture: simple layered app, modular monolith, microservices, or hybrid.
3. Identify bounded contexts, modules, services, shared technical assets, contracts, and tests.
4. Preserve local conventions unless they weaken boundaries, discoverability, or consistency.
5. Create only folders and projects with clear responsibility and ownership.
6. Keep production code under `src/` and tests under `tests/`.
7. Ensure the .NET repository root has a .NET-aware `.gitignore`; run `dotnet new gitignore` when it is missing.
8. Verify namespaces match physical directories.
9. Run the validation checklist before finishing.

## Repository Root

Prefer this reusable root layout:

```text
/
  src/
  tests/
  docs/
  tools/
  scripts/
  deploy/
  build/
  .gitignore
  README.md
  CHANGELOG.md
  LICENSE
```

Use `src/` for production code, `tests/` for automated tests, `docs/` for durable documentation, `tools/` for auxiliary tools, `scripts/` for automation, `deploy/` for deployment assets, and `build/` for repository-level build configuration. Avoid production projects outside `src/`.

Create the repository `.gitignore` with:

```bash
dotnet new gitignore
```

Run it from the .NET repository root before generating, restoring, building, testing, or running projects when `.gitignore` is missing. This prevents generated `bin/`, `obj/`, IDE, test-result, and package artifacts from becoming routine AI cleanup work.

## Modular Monolith

Use this shape when the system is modular but deployed as one application:

```text
src/
  Modules/
    Companies/
    Orders/
    Sales/
    Identity/
  BuildingBlocks/
  Host/
```

Rules:

- Keep each module isolated by bounded context.
- Keep `Host` thin: composition root, startup, routing, configuration, and integration wiring.
- Prefer module-local Domain, Application, Infrastructure, and Api projects when the module is large enough.
- Avoid `SharedBusiness`, `BusinessCore`, `CommonDomain`, and cross-context business projects.

Correct:

```text
src/Modules/Orders/Orders.Domain/
src/Modules/Orders/Orders.Application/
src/Modules/Orders/Orders.Infrastructure/
src/Modules/Orders/Orders.Api/
```

Incorrect:

```text
src/SharedBusiness/
src/BusinessCore/
```

## Microservices

Use this shape when services are independently owned, deployed, or evolved:

```text
src/
  Services/
    Companies/
    Orders/
    Sales/
    Identity/
  BuildingBlocks/
```

Each service owns its internal structure and solution file:

```text
Orders/
  Orders.Api/
  Orders.Application/
  Orders.Domain/
  Orders.Infrastructure/
  Orders.Contracts/
  Orders.sln
```

Prefer one solution per service, such as `Orders.sln`, `Sales.sln`, and `Companies.sln`. In large monorepos, an additional `Platform.sln` is acceptable for navigation when it does not replace service-level ownership. Avoid a giant solution containing many services without logical grouping.

## Clean Architecture Project Shape

Use these projects as the default internal shape for non-trivial modules or services:

```text
Orders.Domain
Orders.Application
Orders.Infrastructure
Orders.Api
```

Keep dependency direction explicit:

```text
Api -> Application -> Domain
Infrastructure -> Application
Infrastructure -> Domain
```

Do not add extra projects such as `Domain.Common`, `Domain.Core`, `Domain.Shared`, or `Domain.Abstractions` unless they have concrete responsibility and simplify the architecture.

## Layer Layouts

Use these physical layouts as defaults, adapting names to the domain:

```text
Orders.Domain/
  Aggregates/
  Entities/
  ValueObjects/
  Events/
  Errors/
  Specifications/
  Services/

Orders.Application/
  Commands/
  Queries/
  Handlers/
  Validators/
  Contracts/
  Behaviors/
  Abstractions/

Orders.Infrastructure/
  Persistence/
  Messaging/
  Clients/
  Security/
  Caching/
  Observability/

Orders.Api/
  Controllers/
  Endpoints/
  Middlewares/
  Filters/
  Configurations/
  Extensions/
```

Layer rules:

- Keep Domain independent from frameworks, persistence, ASP.NET, messaging, and external systems.
- Keep Application focused on use cases, orchestration, validation, ports, and internal DTOs.
- Keep Infrastructure focused on external technical details and implementations behind Application abstractions.
- Keep Api focused on HTTP or presentation entry points.
- Use Controllers or Endpoints according to the project standard; avoid mixing patterns casually.

## Feature Organization

Prefer feature-oriented organization inside Application once technical buckets grow:

```text
Orders.Application/
  Commands/
    CreateOrder/
      CreateOrderCommand.cs
      CreateOrderHandler.cs
      CreateOrderValidator.cs
      CreateOrderResult.cs
```

Avoid giant context-free folders:

```text
Orders.Application/
  Commands/
  Handlers/
  Validators/
```

If these folders become large, split by feature, use case, or vertical slice while preserving Application-layer ownership.

## Contracts

Create a contracts project only when contracts must be consumed outside the module or service:

```text
Orders.Contracts/
  IntegrationEvents/
  PublicContracts/
  Requests/
  Responses/
```

Rules:

- Include only contracts.
- Do not include behavior or business rules.
- Do not depend on Domain.
- Keep compatibility and versioning concerns explicit.

## Building Blocks

Place reusable technical components under:

```text
src/
  BuildingBlocks/
    Results/
    Validation/
    Messaging/
    Observability/
    Security/
    Contracts/
```

Rules:

- Keep Building Blocks technical, generic, and context-free.
- Do not include domain entities, aggregates, use cases, or business rules.
- Do not depend on a specific bounded context.
- Follow `dotnet-reusability-patterns` before introducing shared components.

Correct examples include `src/BuildingBlocks/Results/Result.cs` and `src/BuildingBlocks/Observability/CorrelationIdMiddleware.cs`. Incorrect examples include `src/BuildingBlocks/Orders/OrderStatusRules.cs` and `src/Common/Customer.cs`.

## Shared Kernel

Use Shared Kernel only for explicit, stable, cross-context domain concepts:

```text
src/
  SharedKernel/
    Money/
    Currency/
    Country/
```

Keep ownership and change control clear, keep it small, and avoid turning it into a dumping ground. Prefer duplication or translation over sharing unstable domain models between bounded contexts.

## Tests

Place all tests under `tests/`:

```text
tests/
  Orders.UnitTests/
  Orders.IntegrationTests/
  Orders.ArchitectureTests/
  Orders.ContractTests/
  Orders.FunctionalTests/
  TestSupport/
    Builders/
    Fixtures/
    Fakes/
    Mocks/
```

Rules:

- Name test projects by bounded context or service plus test type.
- Keep shared test support technical and test-only.
- Follow `dotnet-unit-testing` for builders, fixtures, fakes, mocks, and test naming.
- Use architecture tests for forbidden dependencies, layer direction, and namespace rules when guardrails are useful.
- Avoid vague test projects such as `AllTests` and `CommonTests`.

## Documentation

Place durable documentation under:

```text
docs/
  architecture/
  business/
  integrations/
  decisions/
  glossary/
  runbooks/
```

Rules:

- Keep Architecture Decision Records in `docs/decisions/`.
- Use ADR names such as `ADR-001`, `ADR-002`, and `ADR-003`.
- Keep the domain glossary in `docs/glossary/` or `docs/domain-glossary.md`.
- Keep runbooks operational and task-oriented.
- Keep integration documentation close to public contracts and external dependencies.

## Scripts, Tools, Deploy, And Build

Use these layouts when the directories are needed:

```text
scripts/
  database/
  build/
  deploy/
  maintenance/

tools/
  generators/
  migrations/
  diagnostics/

deploy/
  docker/
  kubernetes/
  terraform/
  pipelines/

build/
  Directory.Build.props
  Directory.Packages.props
  packaging/
```

Do not hide deployment or operational scripts inside application projects unless they are project-local and intentionally owned there.

## Files And Namespaces

Follow these physical organization rules:

- Use one primary public type per file.
- Match the file name to the primary public type.
- Use English directory names.
- Keep namespaces aligned with physical directories.
- Keep project names aligned with bounded context and layer.

Example:

```csharp
namespace Company.Product.Orders.Application.Commands.CreateOrder;
```

Should correspond to:

```text
Orders.Application/
  Commands/
    CreateOrder/
      CreateOrderCommand.cs
```

Namespace mismatch is a structural smell. Fix it unless there is an established, documented exception.

## Decision Criteria

Before creating a folder or project, answer:

1. Does this artifact have its own responsibility?
2. Does this module have a clear boundary?
3. Does this separation reduce coupling?
4. Does this folder improve discoverability?
5. Will this structure scale?
6. Does it follow the pattern used by similar modules?
7. Does this project need to exist?
8. Is feature organization sufficient before adding another project?
9. Could this become a generic dumping ground?
10. Does the domain remain visible?

If the answers are weak, keep the structure simpler.

## Prohibited Anti-Patterns

Avoid:

- **Common Project Hell**: `Common`, `Utils`, `Helpers`, `Shared`, or `Core` growing without clear ownership.
- **Layer Explosion**: unnecessary projects such as `Domain.Abstractions`, `Domain.Shared`, `Domain.Core`, and `Domain.Common`.
- **Business Hidden In Shared**: business rules placed in shared technical components.
- **Flat Structure**: unrelated projects and files at the same level.
- **Generic Folders**: `Misc`, `Temp`, `General`, `Stuff`.
- **Shared Domain**: domain models shared between bounded contexts.
- **Namespace Mismatch**: namespaces that do not reflect directories.
- **Giant Solution**: one solution containing many services without logical separation.
- **Artificial Separation**: projects created only because a pattern exists, not because a boundary exists.

## Existing Structure Analysis

When reviewing an existing .NET structure:

1. Map repository root directories.
2. Map solutions and projects.
3. Map bounded contexts, modules, and services.
4. Map project references and dependency direction.
5. Identify generic projects and shared folders.
6. Identify hidden business rules in shared components.
7. Identify architecture or layer violations.
8. Identify namespace and directory mismatches.
9. Review test project organization.
10. Review documentation, scripts, tools, deploy, and build structure.
11. Classify risks by severity and impact.
12. Suggest prioritized improvements with minimal churn.

For reviews, report findings first with concrete paths and the architectural risk.

## New Structure Creation

When generating a new .NET structure:

1. Identify the target architecture.
2. Identify bounded contexts, modules, services, and ownership.
3. Choose modular monolith, microservice, or simpler layered layout.
4. Run `dotnet new gitignore` at the .NET repository root when `.gitignore` is missing.
5. Create only required layers and projects.
6. Create tests aligned to the context and risk.
7. Create documentation directories that the project will actually use.
8. Add Building Blocks only for concrete technical reuse.
9. Add Contracts only for external or cross-boundary contracts.
10. Avoid generic shared projects and vague folders.
11. Verify namespaces, solution files, and project references.

## Validation Checklist

Before finishing any structure change, verify:

- [ ] Structure reflects the architecture.
- [ ] A .NET-aware `.gitignore` exists at the repository root.
- [ ] Bounded contexts are visible.
- [ ] Domain code is isolated.
- [ ] Projects have clear responsibility.
- [ ] No generic shared project was introduced.
- [ ] Building Blocks are separate and technical.
- [ ] Public contracts are separate when needed.
- [ ] Tests are organized under `tests/`.
- [ ] Documentation is organized under `docs/`.
- [ ] Namespaces reflect directories.
- [ ] The structure can scale without frequent reorganization.
- [ ] Discoverability was preserved.
