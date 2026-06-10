---
name: dotnet-clean-architecture
description: Guide AI agents in creating, evolving, reviewing, and maintaining .NET solutions with Clean Architecture, strategic Domain-Driven Design, SOLID, YAGNI, KISS, Separation of Concerns, Dependency Inversion, bounded context boundaries, testability, maintainability, and low coupling. Use when creating a new .NET solution, module, bounded context, feature, project structure, dependency map, architecture review, legacy refactor, pull request review, or architectural analysis.
---

# Dotnet Clean Architecture

Use this skill to keep .NET applications clean, sustainable, scalable, testable, and decoupled. Prefer simple designs that protect the domain and make dependency direction explicit.

## Operating Mode

When working with .NET architecture:

1. Inspect the existing solution before proposing structure or code.
2. Identify projects, namespaces, dependency references, and bounded contexts.
3. Preserve established conventions unless they violate the architecture.
4. Make the smallest architectural change that solves the real problem.
5. Avoid speculative layers, patterns, interfaces, shared kernels, or generic projects.
6. Report architectural violations with problem, impact, severity, and correction.
7. Before finishing, run the validation checklist in this skill.

Do not use this skill for business-specific decisions, cloud infrastructure design, detailed database implementation rules, persistence tuning, or CI/CD definitions. Use a specialized skill for those topics.

## Required Principles

Every architectural decision must respect:

- **SOLID**: Apply all SOLID principles when they reduce coupling and clarify responsibilities.
- **Clean Architecture**: Separate Domain, Application, Infrastructure, and Presentation.
- **YAGNI**: Do not create abstractions for hypothetical future needs.
- **KISS**: Prefer the simplest design that preserves the architecture.
- **Separation of Concerns**: Keep each layer focused on its own responsibility.
- **Dependency Inversion**: Inner layers must not depend on outer layers.
- **Context Boundaries**: Keep bounded contexts explicit and avoid leaking models across contexts.
- **Domain Independence**: Keep core business rules independent from frameworks, transport, persistence, and external services.

## Standard Solution Shape

Recommend this structure when creating or reorganizing a solution, adapting `Product` to the bounded context or product name:

```text
src/
  Product.Api
  Product.Application
  Product.Domain
  Product.Infrastructure

tests/
  Product.UnitTests
  Product.IntegrationTests

docs/
```

Use physical project separation when it adds real architectural protection. Avoid generic projects such as `Common`, `Shared`, or `Core` unless the need is concrete and the ownership boundary is clear.

## Layer Responsibilities

### Domain

Own:

- Entities
- Value objects
- Aggregates
- Domain events
- Domain interfaces
- Core business rules and invariants

Forbid:

- Framework dependencies
- Database dependencies
- ASP.NET dependencies
- Entity Framework dependencies
- Infrastructure library dependencies
- HTTP, serialization, cache, SMTP, queue, file system, or third-party API details

### Application

Own:

- Use cases
- Application orchestration
- Commands and queries
- DTOs and request/response contracts
- Application-flow validation
- Ports required by use cases

Forbid:

- Direct database access
- Infrastructure rules
- HTTP-specific code
- Controller, endpoint, or middleware logic
- Framework-driven domain decisions

### Infrastructure

Own:

- Database implementation
- Entity Framework implementation
- Messaging implementation
- External services
- Cache
- Files
- SMTP
- Third-party APIs
- Concrete adapters for Application or Domain contracts

Forbid:

- Business rules
- Domain decisions made for database convenience
- Application use-case orchestration
- Presentation concerns

### Presentation

Own:

- Controllers
- Minimal APIs
- Endpoints
- Middleware
- Serialization concerns
- Authentication
- Authorization
- HTTP request/response mapping

Forbid:

- Business rules
- Direct database access
- Infrastructure orchestration
- Domain mutation outside Application use cases

## Dependency Rules

Allowed dependency direction:

```text
Product.Api
  -> Product.Application
      -> Product.Domain

Product.Infrastructure
  -> Product.Application
      -> Product.Domain
```

Forbidden dependency direction:

```text
Product.Domain -> Product.Infrastructure
Product.Domain -> Product.Api
Product.Application -> Product.Api
Product.Infrastructure -> Product.Api
```

Report every violation. If a repository has an existing local convention that allows `Api -> Infrastructure` only for composition root registration, call it out explicitly and keep the dependency limited to dependency injection wiring, never business behavior.

## Creating New Projects

When creating a new solution, module, or bounded context:

1. Create physical projects only for needed layers.
2. Use namespaces compatible with the project structure.
3. Keep the domain independent from frameworks and external systems.
4. Avoid premature `Common`, `Shared`, or `SharedKernel` projects.
5. Avoid generic repositories unless a concrete use case justifies them.
6. Keep tactical DDD proportional to domain complexity.
7. Add tests where the architectural risk or business behavior justifies them.

Example project references:

```text
Product.Api references Product.Application
Product.Application references Product.Domain
Product.Infrastructure references Product.Application
Product.Infrastructure references Product.Domain only when needed for concrete domain types
```

Example namespaces:

```text
Product.Domain.Orders
Product.Domain.Orders.Events
Product.Application.Orders.CreateOrder
Product.Application.Orders.GetOrder
Product.Infrastructure.Persistence
Product.Infrastructure.Messaging
Product.Api.Endpoints.Orders
```

## Evolving Existing Architecture

When adding functionality:

1. Decide whether the feature belongs to the current bounded context.
2. Reuse existing components when they already match the responsibility.
3. Avoid new projects, layers, mediators, repositories, factories, or interfaces without demonstrated need.
4. Place domain invariants in Domain.
5. Place use-case flow in Application.
6. Place external implementation details in Infrastructure.
7. Place HTTP mapping and authentication/authorization concerns in Presentation.
8. Re-check dependency direction after the change.

Before suggesting an architectural alteration, answer:

```text
Does it reduce or increase coupling?
Does it improve or hurt maintainability?
Is there a real need, or is this anticipation?
Does the domain remain independent?
Does the solution remain simple?
Does it affect bounded context boundaries?
Does it respect YAGNI?
```

If any answer indicates architectural regression, avoid the change or propose a smaller correction.

## Reviewing Existing Code

Map first, then judge:

1. Map layers and project references.
2. Map namespaces and bounded contexts.
3. Identify dependency cycles.
4. Identify layer violations.
5. Identify framework or infrastructure leakage.
6. Classify severity.
7. Prioritize corrections with the highest architectural impact.
8. Avoid cosmetic refactors without technical value.

Review output format:

```text
Finding: <problem>
Impact: <why this matters>
Severity: <Critical | High | Medium | Low>
Recommendation: <specific correction>
```

Look for:

- Circular dependencies
- Excessive coupling
- Layer violations
- Anemic domain model
- God services
- Controllers with business rules
- Infrastructure leaking into Application
- Unnecessary dependencies
- Overengineering
- Dead code
- Poorly defined bounded contexts

## Prohibited Anti-Patterns

Identify and avoid:

- **Fat controllers**: Controllers containing business rules.
- **God services**: Services responsible for multiple domains or use cases.
- **Anemic domain model**: Entities with only properties while invariants live elsewhere.
- **Shared database model**: Multiple contexts sharing the same business model.
- **Utility hell**: Generic utility classes containing business logic.
- **Overengineering**: Abstractions without proven need.
- **Universal generic repository**: Generic repositories used indiscriminately.
- **Dependency leakage**: Inner layers knowing outer-layer details.
- **Framework-driven design**: Modeling the domain around framework convenience.

## Practical Examples

Correct domain entity:

```csharp
namespace Product.Domain.Orders;

public sealed class Order
{
    private readonly List<OrderLine> _lines = [];

    public OrderId Id { get; }
    public IReadOnlyCollection<OrderLine> Lines => _lines.AsReadOnly();
    public OrderStatus Status { get; private set; }

    public Order(OrderId id)
    {
        Id = id;
        Status = OrderStatus.Draft;
    }

    public void AddLine(ProductId productId, int quantity)
    {
        if (Status != OrderStatus.Draft)
            throw new InvalidOperationException("Only draft orders can be changed.");

        if (quantity <= 0)
            throw new ArgumentOutOfRangeException(nameof(quantity));

        _lines.Add(new OrderLine(productId, quantity));
    }
}
```

Incorrect domain entity:

```csharp
using Microsoft.EntityFrameworkCore;

namespace Product.Domain.Orders;

public class Order
{
    public DbSet<OrderLine> Lines { get; set; } = null!;
    public string Status { get; set; } = "";
}
```

Correct application use case:

```csharp
namespace Product.Application.Orders.CreateOrder;

public sealed class CreateOrderHandler
{
    private readonly IOrderRepository _orders;

    public CreateOrderHandler(IOrderRepository orders)
    {
        _orders = orders;
    }

    public async Task<OrderId> Handle(CreateOrderCommand command, CancellationToken cancellationToken)
    {
        var order = new Order(OrderId.New());

        foreach (var item in command.Items)
            order.AddLine(new ProductId(item.ProductId), item.Quantity);

        await _orders.AddAsync(order, cancellationToken);
        return order.Id;
    }
}
```

Incorrect controller:

```csharp
app.MapPost("/orders", async (CreateOrderRequest request, AppDbContext db) =>
{
    var order = new OrderEntity { Status = "Draft" };

    foreach (var item in request.Items)
        order.Lines.Add(new OrderLineEntity(item.ProductId, item.Quantity));

    db.Orders.Add(order);
    await db.SaveChangesAsync();

    return Results.Created($"/orders/{order.Id}", order.Id);
});
```

Correct controller or endpoint:

```csharp
app.MapPost("/orders", async (
    CreateOrderRequest request,
    CreateOrderHandler handler,
    CancellationToken cancellationToken) =>
{
    var command = new CreateOrderCommand(request.Items);
    var orderId = await handler.Handle(command, cancellationToken);
    return Results.Created($"/orders/{orderId}", new { id = orderId });
});
```

Valid dependency examples:

```csharp
// Product.Application
using Product.Domain.Orders;

// Product.Infrastructure
using Product.Application.Orders;
using Product.Domain.Orders;

// Product.Api
using Product.Application.Orders.CreateOrder;
```

Invalid dependency examples:

```csharp
// Product.Domain
using Product.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

// Product.Application
using Product.Api.Contracts;
using Microsoft.AspNetCore.Mvc;

// Product.Infrastructure
using Product.Api.Endpoints;
```

## Validation Checklist

Before completing any architectural task, verify:

- [ ] Domain does not depend on Infrastructure.
- [ ] Domain does not depend on Presentation.
- [ ] Application does not depend on Presentation.
- [ ] Controllers and endpoints do not contain business rules.
- [ ] Infrastructure does not contain business rules.
- [ ] No circular dependencies exist.
- [ ] No premature abstractions were introduced.
- [ ] The domain remains protected.
- [ ] Bounded context boundaries are respected.
- [ ] The solution remains simple.
- [ ] SOLID is respected where it improves clarity and decoupling.
- [ ] YAGNI is respected.
