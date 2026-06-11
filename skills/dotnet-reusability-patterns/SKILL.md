---
name: dotnet-reusability-patterns
description: Guide AI agents in creating, reviewing, refactoring, and evolving reusable components in .NET applications, including Building Blocks, shared libraries, internal SDKs, shared contracts, value objects, technical behaviors, DRY/YAGNI decisions, coupling analysis, and sustainable package evolution. Use when creating shared libraries, Building Blocks, reusable components, internal SDKs, common abstractions, consolidating duplication, evolving internal platforms, creating shared contracts, or reviewing dependencies between modules, bounded contexts, services, and projects.
---

# Dotnet Reusability Patterns

Use this skill to make reuse explicit, evidence-based, and sustainable in .NET systems. Prefer the project's existing architecture, package strategy, naming conventions, and dependency rules before introducing new shared components.

Do not create reusable components merely because something could be reused. Reuse only when there is real repetition, proven need, measurable benefit, and a stable pattern.

## Related Skills

Coordinate with these skills when they exist:

- `dotnet-clean-architecture`: owns architectural boundaries, dependency direction, and layer rules.
- `dotnet-domain-modeling`: owns domain model quality, bounded context boundaries, aggregates, value objects, and invariants.
- `dotnet-coding-standards`: owns idiomatic C#, naming, readability, and local code style.
- `dotnet-error-handling`: owns Result, error, validation, and exception policies.
- `dotnet-api-contracts`: owns DTOs, JSON contracts, ProblemDetails shape, and API compatibility.
- `dotnet-microservices-patterns`: owns service autonomy, integration patterns, messaging, and distributed boundaries.

When responsibilities conflict:

- Domain modeling wins over reuse.
- Clean Architecture defines the allowed dependency boundaries.
- This skill decides what may be shared between modules, services, projects, or bounded contexts.

## Required Principles

- **Reuse Proven Concepts**: Reuse must emerge from proven patterns, not speculation.
- **Duplication Before Abstraction**: Small duplication is preferable to premature abstraction.
- **Domain Before Reuse**: Preserve domain isolation even when sharing appears convenient.
- **Technical Reuse First**: Reuse technical capabilities before sharing business concepts.
- **Explicit Dependencies**: Shared dependencies must be visible, intentional, and justified.
- **Stable Shared Components**: The more widely shared a component is, the more stable, tested, documented, and versioned it must be.

## Fundamental Rule

Before suggesting or creating a shared abstraction, verify that reuse is justified by evidence:

```text
1st use -> implement
2nd use -> observe
3rd use -> consider abstraction
```

Exceptions are allowed only for mandatory contracts, architectural Building Blocks, cross-cutting infrastructure, or explicit organizational standards.

When DRY and YAGNI conflict, prefer YAGNI. Removing every duplicate line is not the goal; reducing total system complexity is.

## Decision Criteria

Before creating reusable code, answer:

1. Is there real repetition?
2. Is there a third use or an explicit exception?
3. Is the pattern stable?
4. Does the domain remain isolated?
5. Does sharing reduce complexity?
6. Does sharing increase coupling?
7. Is the component technical or business-specific?
8. Will versioning be simple enough?
9. Is ownership clear?
10. Does the benefit exceed the operational cost?

If these answers are weak, keep the implementation local.

## Usually Reusable

Prefer reuse for technical, cross-cutting, or integration-facing capabilities:

- Result primitives: `Result`, `Result<T>`, `Error`, `ErrorType`.
- Validation infrastructure: `ValidationError`, `ValidationResult`.
- Correlation: `ICorrelationIdAccessor`, correlation middleware, propagation helpers.
- Observability: logging, telemetry, tracing, metrics, and health check extensions.
- Messaging abstractions: `IEventBus`, `IMessagePublisher`, `IIntegrationEvent`.
- Security infrastructure: `ITokenProvider`, policy helpers, safe claims utilities.
- Technical extension methods: `services.AddMessaging()`, `app.UseCorrelationId()`.
- Integration contracts that must be consumed by multiple applications.
- Internal SDKs for external platform access when the protocol is stable.

Keep reusable technical components free from domain rules and context-specific dependencies.

## Usually Not Reusable

Avoid sharing business implementation across bounded contexts or independent services:

- Domain entities such as `Shared.Customer`, `Shared.Order`, or `Shared.Company`.
- Aggregates.
- Business rules under names such as `BusinessRules.Common`.
- Application services and use cases.
- Repositories.
- `DbContext` types.
- Persistence entities and database models.
- Domain events that are internal implementation details.
- Service implementations between microservices.

Prefer duplication or translation over leaking one context's model into another.

## Building Blocks

Use Building Blocks for reusable technical capabilities.

Example structure:

```text
BuildingBlocks
├── Results
├── Validation
├── Messaging
├── Observability
├── Security
└── Contracts
```

Rules:

- Keep business rules out.
- Keep domain dependencies out.
- Keep context-specific dependencies out.
- Keep responsibilities narrow.
- Keep public APIs small and intentional.
- Prefer composition over base classes.
- Provide tests for public behavior.
- Document intended consumers and compatibility expectations.

Correct:

```csharp
public sealed record Error(string Code, string Message, ErrorType Type);

public readonly record struct Result<T>
{
    public bool IsSuccess { get; init; }
    public T? Value { get; init; }
    public Error? Error { get; init; }
}
```

Incorrect:

```csharp
public abstract class EntityBase
{
    public Guid Id { get; protected set; }
    public List<IDomainEvent> Events { get; } = [];
    public void ValidateCustomerCreditLimit() { }
}
```

The incorrect example mixes generic entity infrastructure with a context-specific business rule.

## Shared Kernel

Treat Shared Kernel as an architectural exception, not a default reuse mechanism.

Use Shared Kernel only when:

- The concept is truly shared across contexts.
- The meaning is stable and governed.
- Ownership is clear.
- Change coordination is acceptable.
- Consumers can tolerate synchronized evolution.

Usually acceptable:

```text
Money
Currency
Country
CountryCode
Language
LanguageCode
```

Usually dangerous:

```text
Customer
Order
Sale
Subscription
CustomerType
SubscriptionPlan
OrderStatus
```

If a value object has different rules, lifecycle, language, or invariants per bounded context, keep separate implementations even when names match.

## Shared Contracts

Share contracts only when consumers need a stable integration surface.

Prefer:

```csharp
public sealed record OrderCreatedIntegrationEvent(
    Guid EventId,
    int Version,
    DateTimeOffset OccurredAt,
    Guid OrderId,
    Guid CustomerId,
    string Currency,
    decimal TotalAmount);
```

Avoid:

```csharp
public sealed record OrderCreatedIntegrationEvent(Order Order);
```

Rules:

- Make contracts versionable.
- Make contracts immutable.
- Keep contracts behavior-free.
- Keep contracts independent from internal domain types.
- Use primitive or stable shared value types only.
- Preserve backward compatibility when possible.
- Add explicit versioning or new event types for breaking changes.

In microservices, prefer sharing contracts over sharing implementation.

Prefer:

```text
OrderCreatedIntegrationEvent
```

Avoid sharing:

```text
OrderService
OrderRepository
OrderAggregate
```

## Value Objects

Be conservative when sharing value objects.

Share only stable, context-neutral concepts:

```csharp
public readonly record struct Currency(string Code);

public sealed record Money(decimal Amount, Currency Currency);
```

Keep local when the concept belongs to a specific domain:

```csharp
public enum SubscriptionPlan
{
    Trial,
    Standard,
    Enterprise
}
```

Even simple enums can become coupling hazards when meanings evolve differently across contexts.

## Extension Methods

Use extension methods when they improve readability and expose clear technical setup.

Prefer:

```csharp
public static IServiceCollection AddMessaging(
    this IServiceCollection services,
    IConfiguration configuration)
{
    services.Configure<MessageBusOptions>(configuration.GetSection("Messaging"));
    services.AddSingleton<IMessagePublisher, MessagePublisher>();
    return services;
}
```

Avoid:

```csharp
public static void DoMagicStuff(this Entity entity)
{
    entity.ChangeStatus();
    entity.RecalculateTotals();
    entity.PublishEvents();
}
```

Rules:

- Keep the responsibility obvious.
- Avoid hiding important business behavior.
- Avoid broad `Utils` or `Helpers` classes.
- Prefer local extension methods until reuse is proven.

## Shared Packages

Before creating a shared package, answer:

1. How many consumers exist now?
2. Is the component stable?
3. Is versioning simple?
4. Is coupling acceptable?
5. Does the operational cost pay for itself?
6. Who owns the package?
7. How will breaking changes be communicated?
8. Are tests and documentation sufficient for external consumers?

Package rules:

- Use explicit package names that communicate responsibility.
- Avoid generic packages named `Common`, `Utils`, `Shared`, or `Core`.
- Keep package dependencies minimal.
- Avoid referencing application or domain projects from shared technical packages.
- Publish clear release notes for breaking changes.
- Use semantic versioning when packages are consumed independently.

## Analysis Workflow

When analyzing existing reuse:

1. Map shared libraries and packages.
2. Map Shared Kernels.
3. Map Building Blocks.
4. Identify legitimate duplication.
5. Identify premature abstractions.
6. Identify improper domain sharing.
7. Identify dangerous coupling.
8. Evaluate versioning strategy.
9. Evaluate ownership.
10. Suggest prioritized improvements.

Report risks first when reviewing code. Distinguish harmful duplication from healthy local duplication.

## Creation Workflow

When generating new code:

1. Implement the simplest local solution first.
2. Observe repetition.
3. Apply the rule of three uses.
4. Share only when benefit is proven.
5. Prefer Building Blocks for technical concerns.
6. Avoid sharing domain models.
7. Keep coupling low and explicit.
8. Add versioning when independent consumers exist.
9. Add concise documentation for public APIs.
10. Add tests appropriate to the blast radius.

Do not move code into shared packages during initial implementation unless an exception is explicit and justified.

## Correct Cases

Use a shared Result pattern when multiple layers or services need a consistent non-exceptional failure model:

```text
BuildingBlocks.Results
├── Result
├── Result<T>
├── Error
└── ErrorType
```

Use a shared integration contract when multiple services publish or consume the same external event:

```text
Contracts.Orders.V1.OrderCreatedIntegrationEvent
```

Use a Building Block for messaging when applications need consistent publishing, retry metadata, correlation, and telemetry:

```text
BuildingBlocks.Messaging
├── IIntegrationEvent
├── IMessagePublisher
├── IMessageConsumer
└── MessagingServiceCollectionExtensions
```

Use a Shared Kernel value object only when the concept is stable and truly shared:

```text
SharedKernel.Money
SharedKernel.Currency
```

## Incorrect Cases

Do not create a shared domain package:

```text
Shared.Domain
├── Customer
├── Order
└── Subscription
```

Do not create a growing catch-all project:

```text
Common
├── Extensions
├── Helpers
├── Entities
├── Repositories
├── Services
└── BusinessRules
```

Do not share database access across contexts:

```text
Shared.Persistence.AppDbContext
Shared.Repositories.CustomerRepository
```

Do not create a framework before real usage proves it is needed:

```text
Company.Framework.DomainDrivenWorkflowOrchestrator
```

## Prohibited Anti-Patterns

- **Shared Domain**: Sharing domain entities between bounded contexts.
- **Common Project Hell**: Letting `Common`, `Utils`, `Shared`, or `Core` grow indefinitely.
- **Premature Abstraction**: Creating abstraction on first use.
- **Generic Internal Framework**: Building a broad framework without proven demand.
- **Cross Context Domain**: Sharing domain concepts across bounded contexts.
- **Reuse Driven Architecture**: Designing architecture primarily to maximize reuse.
- **Shared Database Models**: Sharing persistence entities.
- **Shared Repositories**: Sharing data access across contexts.
- **God Building Block**: Combining multiple responsibilities into one shared package.

## Validation Checklist

Before finishing any reusable component, verify:

- [ ] Proven need exists.
- [ ] Real repetition exists.
- [ ] A third use exists, or an explicit exception applies.
- [ ] Domain isolation is preserved.
- [ ] The component is stable enough to share.
- [ ] Sharing reduces total complexity.
- [ ] The component has a single responsibility.
- [ ] Versioning has been considered.
- [ ] Ownership is clear.
- [ ] Domain sharing is not improper.
- [ ] The abstraction is not premature.
- [ ] DRY is not violating YAGNI.
- [ ] Tests cover public behavior.
- [ ] Documentation explains intended use and limits.

Always prioritize domain isolation, simplicity, stability, and evidence-based reuse.
