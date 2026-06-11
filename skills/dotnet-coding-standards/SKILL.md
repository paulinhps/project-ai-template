---
name: dotnet-coding-standards
description: Guide AI agents in creating, reviewing, refactoring, and standardizing C#/.NET code for backend applications, APIs, workers, libraries, and microservices. Use when writing new C# code, reviewing existing code, refactoring classes, standardizing naming, choosing namespaces, creating classes, records, structs, interfaces, enums, DTOs, extension methods, tests, or evaluating readability, maintainability, idiomatic C#, English-first code, ubiquitous language preservation, and consistency with existing .NET project conventions.
---

# Dotnet Coding Standards

Use this skill to keep .NET code consistent, readable, predictable, idiomatic, and aligned with modern C# practices.

## Coordinate With Related Skills

Apply these skills when available:

- `dotnet-clean-architecture` for layer boundaries, dependency direction, project structure, and architectural decisions.
- `dotnet-domain-modeling` for domain concepts, aggregates, entities, value objects, invariants, and ubiquitous language meaning.
- `dotnet-exceptionless-domain-modeling` for Result-oriented business failures and domain error modeling.
- `dotnet-rest-api-design` for HTTP resources, routes, status codes, REST semantics, and endpoint design.
- `dotnet-api-contracts` for public API JSON contracts, DTO shape, serialization, and enum exposure.
- `dotnet-unit-testing` for test scope, naming, builders, fakes, mocks, and unit-test quality.

When guidance conflicts:

1. Let `dotnet-domain-modeling` define domain meaning and business concepts.
2. Let specialized API, persistence, security, and testing skills define their own surfaces.
3. Let this skill define code writing standards, naming, language, namespaces, file organization, readability, and idiomatic C# style.
4. Preserve ubiquitous language through a glossary when code is written in English.

Do not use this skill as the primary authority for architecture, business rules, persistence, REST contracts, or security.

## Required Principles

- Write code in English whenever possible.
- Preserve business meaning through a technical domain glossary.
- Prefer consistency over personal preference.
- Prefer clarity over cleverness.
- Apply YAGNI: avoid speculative abstractions, helpers, inheritance, and interfaces.
- Use idiomatic C# features supported by the project version.
- Follow the existing project convention when it is clear and consistent.
- Keep code small, cohesive, and easy to change.
- Preserve native .NET naming and style conventions unless the project has a deliberate standard.

## English First

Use English for:

- Namespaces, directories, filenames, types, members, variables, DTOs, commands, queries, events, tests, and extension methods.

Prefer:

```csharp
public sealed class OrderService
{
    public Task ProcessOrderAsync(Order order)
    {
        // ...
    }
}
```

Avoid:

```csharp
public sealed class PedidoService
{
    public Task ProcessarPedidoAsync(Pedido pedido)
    {
        // ...
    }
}
```

Do not mix languages for the same concept:

```csharp
public sealed class PedidoService
{
    public void CreateOrder() { }
}
```

## Domain Glossary

When business language uses Portuguese or project-specific terms, preserve the ubiquitous language with a glossary before translating freely.

Recommended location:

```text
docs/domain-glossary.md
```

Use the project standard location when one already exists.

Recommended format:

```md
# Domain Glossary

| Business Term | Code Term | Description |
|---|---|---|
| Pedido | Order | Represents a customer order. |
| Venda | Sale | Represents a completed sale process. |
| Empresa | Company | Represents a tenant or company in the system. |
| Cliente | Customer | Represents a customer. |
| Assinatura | Subscription | Represents a recurring commercial agreement. |
| Nota Fiscal | Invoice / FiscalDocument | Represents a fiscal document issued for a transaction. |
```

Glossary rules:

- Update the glossary whenever a relevant business term is introduced.
- Document ambiguous terms before using them in code.
- Do not let technical terms replace business meaning.
- Use one translation consistently across code, tests, docs, and contracts.
- Do not translate the same term differently without recording the decision.
- Avoid mixing Portuguese and English inside the same concept.

Examples of translation drift to prevent:

```text
Pedido -> Order
Pedido -> Request
Pedido -> Purchase
```

## Naming

Use standard .NET casing:

| Code Element | Convention | Example |
|---|---|---|
| Classes | PascalCase | `OrderProcessor` |
| Interfaces | `I` + PascalCase | `IOrderRepository` |
| Methods | PascalCase | `ConfirmPayment` |
| Async methods | PascalCase + `Async` | `GetByIdAsync` |
| Properties | PascalCase | `CreatedAt` |
| Private fields | `_camelCase` | `_items` |
| Parameters | camelCase | `customerId` |
| Local variables | camelCase | `orderItems` |
| Constants | PascalCase | `MaxRetryAttempts` |

Use clear, noun-based class names:

```csharp
public sealed class OrderProcessor
{
}
```

Avoid vague names without specific context:

```csharp
public sealed class Manager
{
}

public sealed class Helper
{
}
```

Use action-oriented method names:

```csharp
public Result ConfirmPayment()
{
}

public Task<Order?> GetByIdAsync(
    OrderId id,
    CancellationToken cancellationToken)
{
}
```

Avoid obscure abbreviations. Use `customer` instead of `cust`, `quantity` instead of `qty`, unless the abbreviation is universal in the project.

## Namespaces

Namespaces must reflect the project's logical structure, bounded context, and layer.

Prefer:

```csharp
Company.Product.Orders.Domain.Entities
Company.Product.Orders.Application.Commands
Company.Product.Orders.Infrastructure.Persistence
```

Rules:

- Use English.
- Keep namespaces consistent with directories when that is the project convention.
- Include context and layer when the project architecture uses them.
- Avoid generic namespaces such as `Common`, `Helpers`, `Misc`, or `Utils`.
- Do not invent a new namespace pattern in an established codebase.

## Types

### Classes

Classes should have one clear responsibility, high cohesion, and a small public surface.

Prefer `sealed` unless the class is designed for inheritance:

```csharp
public sealed class Order
{
}
```

Avoid god classes, vague service objects, and classes with multiple unrelated reasons to change.

### Records

Use `record` for immutable data-oriented types:

- DTOs.
- Simple value objects.
- Commands.
- Queries.
- Events.
- Immutable test builders.

Example:

```csharp
public sealed record CreateOrderRequest(
    Guid CustomerId,
    IReadOnlyList<CreateOrderItemRequest> Items);
```

Do not use records for entities with identity, lifecycle, and behavior-heavy state transitions.

### Structs

Use structs only when the type is small, immutable, value-like, and has a clear benefit.

Prefer `readonly record struct` when appropriate:

```csharp
public readonly record struct Money(decimal Amount, string Currency);
```

Avoid mutable structs.

### Enums

Use enums for small, closed, stable sets:

```csharp
public enum EOrderStatus
{
    Pending = 1,
    Paid = 2,
    Cancelled = 3
}
```

Rules:

- Follow the existing project convention for enum prefixes. `E` is acceptable when already adopted.
- Use explicit values when persistence, contracts, or compatibility matter.
- Use `PascalCase` values unless the project consistently uses another style.
- For public API enum representation, follow `dotnet-api-contracts`.
- Avoid enums for unstable concepts or concepts with complex behavior.

### Interfaces

Create interfaces only when there is a real abstraction need:

- Dependency inversion across layers.
- Multiple implementations.
- Contract between modules or layers.
- External dependency abstraction.
- Meaningful fake or mock seam for tests.

Valid:

```csharp
public interface IOrderRepository
{
    Task<Order?> GetByIdAsync(
        OrderId id,
        CancellationToken cancellationToken);
}
```

Avoid interface-for-everything:

```csharp
public interface IOrderService
{
}

public sealed class OrderService : IOrderService
{
}
```

Do not create an interface solely because a class exists.

### Abstract Classes

Use abstract classes only when shared base behavior and a real specialization relationship exist. Prefer composition when the relationship is not essential and avoid deep hierarchies.

### Extension Methods

Use extension methods to improve readability, encapsulate configuration, reduce clear repetition, or integrate with fluent APIs:

```csharp
public static IServiceCollection AddOrdersModule(
    this IServiceCollection services,
    IConfiguration configuration)
{
    return services;
}
```

Do not hide business rules in extension methods.

## File Organization

Rules:

- Keep one primary public type per file.
- Match the filename to the primary type name.
- Organize by context and responsibility.
- Avoid catch-all folders unless the project gives them a clear, constrained meaning.

Prefer:

```text
Orders/
  Domain/
    Entities/
    ValueObjects/
    Events/
  Application/
    Commands/
    Queries/
```

Avoid:

```text
Common/
Helpers/
Misc/
Utils/
```

## Comments And Documentation

Prefer clear code over comments.

Use comments to explain intent, context, tradeoffs, or non-obvious decisions. Do not add comments that merely restate the code.

Use XML documentation for public APIs, shared libraries, external contracts, complex methods, and non-obvious decisions. Do not require XML documentation on every internal method by default.

## Nullability

Respect nullable reference types.

Rules:

- Mark optional values explicitly with `?`.
- Avoid `!` unless there is a local, justified reason.
- Prefer `Result<T>`, an option type, or explicit absence semantics over `null` for expected failures when the project uses those patterns.
- Validate external input at boundaries.
- Do not hide possible nulls with broad suppression.

## Async

Rules:

- Suffix asynchronous methods with `Async`.
- Propagate `CancellationToken` when the operation can be cancelled or crosses I/O/application boundaries.
- Avoid `.Result`, `.Wait()`, and `async void` except for event handlers.
- Use `ConfigureAwait(false)` only when the project convention or library context requires it.

## Exceptions And Result Pattern

Follow `dotnet-exceptionless-domain-modeling` when business failures are expected and modeled explicitly.

Rules:

- Do not use exceptions for expected business flow.
- Use exceptions for unexpected failures, impossible states, and infrastructure faults when appropriate.
- Do not catch exceptions without useful action or swallow them silently.
- Return `Result` for expected failures when the project uses Result Pattern.
- Return `Result<T>` when an operation can fail and produce a value.
- Avoid boolean failure indicators without context and `null` as a failure signal when a Result or option pattern is available.

## DTOs

DTOs should be explicit, English-first, behavior-free, and separate from domain entities.

Prefer immutable records when appropriate:

```csharp
public sealed record OrderResponse(
    Guid Id,
    string Status,
    DateTime CreatedAt);
```

Do not expose domain entities directly through API contracts.

## Tests

Follow `dotnet-unit-testing` for test design and quality.

Use English test names unless the project deliberately uses another standard:

```csharp
public void Create_ShouldReturnFailure_WhenNameIsEmpty() { }
```

Preserve the same naming, glossary, and domain terms in test code.

## Existing Code Review Workflow

When analyzing existing code:

1. Map the language currently used in code, tests, namespaces, and folders.
2. Identify mixed Portuguese and English names.
3. Identify domain terms missing from the glossary.
4. Identify inconsistent translations.
5. Review class, method, property, field, parameter, enum, record, and struct names.
6. Review namespaces and directory alignment.
7. Review interface usage and abstraction justification.
8. Find generic helpers, utils, common folders, and god classes.
9. Review record, struct, and enum fit.
10. Classify issues by correctness, maintainability, consistency, and migration cost.
11. Suggest prioritized corrections.

## New Code Workflow

When generating new code:

1. Use English by default.
2. Consult the domain glossary when one exists.
3. Update the glossary when introducing relevant business terms.
4. Preserve business meaning before choosing a translation.
5. Follow idiomatic C# naming and casing.
6. Use namespaces consistent with the project.
7. Create small, cohesive types.
8. Avoid abstractions without evidence.
9. Avoid language mixing.
10. Keep the solution simple and readable.

## Decision Questions

Before creating or approving code, answer:

1. Is the name in English whenever possible?
2. Does the name preserve the domain concept?
3. Is the term documented in the glossary when necessary?
4. Does the type have one clear responsibility?
5. Is the abstraction really necessary?
6. Is the code idiomatic for the project's C# version?
7. Is there unnecessary Portuguese/English mixing?
8. Does the namespace reflect context and layer?
9. Does the code follow the existing project pattern?
10. Is the solution still simple?

## Prohibited Anti-Patterns

- Mixed-language code for the same concept.
- Translation drift for the same business term.
- Interface for every class.
- Generic `Helper`, `Utils`, `Common`, or `Misc` buckets without a clear bounded purpose.
- Clever code that is hard to understand.
- Primitive obsession for important domain concepts.
- Mutable structs.
- God classes.
- Excessive or obscure abbreviations.
- Speculative abstractions for possible future use.
- Enums for unstable or behavior-heavy concepts.

## Validation Checklist

Before concluding .NET coding-standard work, verify:

- [ ] Code is in English whenever possible.
- [ ] Domain terms are preserved through the glossary.
- [ ] There is no unjustified language mixing.
- [ ] Classes have clear responsibilities.
- [ ] Namespaces are consistent.
- [ ] Interfaces have a real justification.
- [ ] Records are used where appropriate.
- [ ] Structs are small and immutable.
- [ ] Enums represent closed, stable sets.
- [ ] Async methods end with `Async`.
- [ ] Nullability is respected.
- [ ] Generic helpers without clear purpose are avoided.
- [ ] SOLID was considered.
- [ ] YAGNI was respected.
