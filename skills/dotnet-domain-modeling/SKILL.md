---
name: dotnet-domain-modeling
description: Guide AI agents in modeling .NET domains with Domain-Driven Design, Object-Oriented Design, Clean Architecture, SOLID, YAGNI, rich domain models, aggregate boundaries, entities, value objects, domain services, domain events, invariants, and framework-independent business rules. Use when creating or reviewing domain entities, value objects, aggregates, bounded contexts, business rules, legacy domain refactors, aggregate relationships, or domain model quality in .NET applications.
---

# Dotnet Domain Modeling

Use this skill to create expressive, business-aligned .NET domain models that protect rules, invariants, and essential behavior. Keep the domain independent from frameworks, persistence, transport, and technical convenience.

## Operating Mode

When modeling a domain:

1. Identify the business concepts and ubiquitous language before naming code.
2. Decide whether each concept is an entity, value object, aggregate root, domain service, or domain event.
3. Place business behavior inside the responsible domain object.
4. Protect invariants at construction time and through business methods.
5. Keep aggregate boundaries small, explicit, and transactionally meaningful.
6. Avoid speculative abstractions, generic services, and persistence-driven modeling.
7. Before finishing, run the validation checklist in this skill.

Do not use this skill for API design, Entity Framework mapping, database schema design, infrastructure implementation, messaging configuration, authentication, or authorization. Use specialized skills for those topics.

## Required Principles

Every model must respect:

- **Domain First**: Represent the business, not the technology.
- **Encapsulation**: Keep rules inside the objects responsible for them.
- **High Cohesion**: Give each object related responsibilities only.
- **Low Coupling**: Let objects know only what they need.
- **Rich Domain Model**: Put relevant behavior in the domain, not only in services.
- **Ubiquitous Language**: Use names from the business language.
- **SOLID**: Apply SOLID when it improves clarity, substitutability, and coupling.
- **YAGNI**: Avoid abstractions and behavior for hypothetical future needs.

## Domain Object Decisions

Before creating a new domain object, answer:

```text
Does it have identity?
Does it have a lifecycle?
Is it compared by value?
Does it contain relevant behavior?
Does it own or protect a business rule?
Does it belong to the domain instead of a technical concern?
Does it protect an invariant?
```

Use the answers to choose:

- **Entity**: Identity and lifecycle matter.
- **Value Object**: Value and validity matter, identity does not.
- **Aggregate Root**: Consistency boundary and controlled access matter.
- **Domain Service**: A domain rule spans multiple domain objects and belongs to none of them naturally.
- **Domain Event**: A meaningful business fact already happened and other components may react.

## Entity Rules

Use an entity when identity is stable across state changes. Entities should:

- Own business behavior.
- Protect invariants.
- Avoid public setters.
- Expose business operations instead of technical mutation.
- Prevent invalid states.
- Keep identity explicit and stable.

Correct entity:

```csharp
namespace Sales.Domain.Orders;

public sealed class Order
{
    private readonly List<OrderItem> _items = [];

    public OrderId Id { get; }
    public OrderStatus Status { get; private set; }
    public IReadOnlyCollection<OrderItem> Items => _items.AsReadOnly();

    public Order(OrderId id)
    {
        Id = id;
        Status = OrderStatus.Draft;
    }

    public void AddItem(ProductId productId, int quantity, Money unitPrice)
    {
        if (Status != OrderStatus.Draft)
            throw new DomainException("Only draft orders can be changed.");

        if (quantity <= 0)
            throw new DomainException("Quantity must be greater than zero.");

        _items.Add(new OrderItem(productId, quantity, unitPrice));
    }
}
```

Incorrect entity:

```csharp
namespace Sales.Domain.Orders;

public class Order
{
    public List<OrderItem> Items { get; set; } = [];
    public string Status { get; set; } = "";
}
```

## Value Object Rules

Use a value object when the concept has no identity and is defined by its values. Value objects should:

- Be immutable.
- Validate their own data.
- Compare by value.
- Represent a real business concept.
- Avoid technical or persistence-only meaning.

Prefer `record` for value objects when appropriate:

```csharp
namespace Sales.Domain.Customers;

public sealed record Email
{
    public string Value { get; }

    public Email(string value)
    {
        if (string.IsNullOrWhiteSpace(value))
            throw new DomainException("Email is required.");

        if (!value.Contains('@'))
            throw new DomainException("Email is invalid.");

        Value = value.Trim();
    }

    public override string ToString() => Value;
}
```

Use primitive types only when the primitive itself is the clearest domain expression. Replace primitive obsession with value objects for concepts such as `Email`, `Money`, `Address`, `PhoneNumber`, `DocumentNumber`, `OrderId`, and `CustomerId`.

## Aggregate Rules

Use an aggregate root to protect a consistency boundary. Aggregates should:

- Have one public entry point for mutations.
- Keep internal entities protected.
- Enforce consistency inside the aggregate.
- Avoid becoming large object graphs.
- Reference other aggregates by identity when possible.
- Keep transaction boundaries explicit.

Example aggregate:

```csharp
namespace Sales.Domain.Orders;

public sealed class Order
{
    private readonly List<OrderItem> _items = [];
    private readonly List<IDomainEvent> _domainEvents = [];

    public OrderId Id { get; }
    public CustomerId CustomerId { get; }
    public OrderStatus Status { get; private set; }
    public IReadOnlyCollection<OrderItem> Items => _items.AsReadOnly();
    public IReadOnlyCollection<IDomainEvent> DomainEvents => _domainEvents.AsReadOnly();

    public Order(OrderId id, CustomerId customerId)
    {
        Id = id;
        CustomerId = customerId;
        Status = OrderStatus.Draft;

        _domainEvents.Add(new OrderCreated(Id, CustomerId));
    }

    public void ConfirmPayment(Money paidAmount)
    {
        if (Status != OrderStatus.Draft)
            throw new DomainException("Only draft orders can be paid.");

        if (!_items.Any())
            throw new DomainException("Order must contain at least one item.");

        if (paidAmount != Total())
            throw new DomainException("Paid amount must match order total.");

        Status = OrderStatus.Paid;
        _domainEvents.Add(new PaymentConfirmed(Id));
    }

    private Money Total() => _items.Aggregate(Money.Zero, (total, item) => total + item.Total);
}
```

Avoid a god aggregate that loads and mutates an entire business process when separate consistency boundaries would be clearer.

## Domain Service Rules

Use a domain service only when:

- The rule belongs to the domain.
- The rule does not naturally belong to one entity or value object.
- The rule needs multiple domain objects or domain concepts.

Do not use domain services as a generic destination for poorly modeled behavior.

Example:

```csharp
namespace Sales.Domain.Discounts;

public sealed class DiscountPolicy
{
    public Money Calculate(Customer customer, Order order)
    {
        if (customer.IsVip && order.TotalAmount.IsGreaterThan(Money.From(500, "USD")))
            return order.TotalAmount.Percentage(10);

        return Money.Zero;
    }
}
```

Incorrect service:

```csharp
public sealed class OrderService
{
    public void AddItem(Order order, ProductId productId, int quantity)
    {
        order.Items.Add(new OrderItem(productId, quantity));
    }
}
```

The incorrect service bypasses aggregate behavior and encourages an anemic model.

## Domain Event Rules

Use a domain event when a meaningful business fact has already occurred and other components may react. Domain events should:

- Represent completed facts, not commands or requests.
- Be immutable.
- Use business language.
- Carry the minimum useful data.
- Exist only when there is a real reaction, integration, audit, notification, or policy need.

Correct events:

```csharp
namespace Sales.Domain.Orders.Events;

public sealed record OrderCreated(OrderId OrderId, CustomerId CustomerId) : IDomainEvent;

public sealed record PaymentConfirmed(OrderId OrderId) : IDomainEvent;
```

Incorrect event:

```csharp
public sealed record SaveOrderRequested(OrderId OrderId);
```

## Collections, Identity, Enums, Records, And Structs

Never expose mutable collections directly:

```csharp
private readonly List<OrderItem> _items = [];

public IReadOnlyCollection<OrderItem> Items => _items.AsReadOnly();
```

Avoid:

```csharp
public List<OrderItem> Items { get; set; } = [];
```

Use explicit identities such as:

```csharp
public sealed record OrderId(Guid Value)
{
    public static OrderId New() => new(Guid.NewGuid());
}
```

Use enums only when the values are small, stable, and have no behavior:

```csharp
public enum OrderStatus
{
    Draft,
    Paid,
    Cancelled
}
```

When values need behavior, transitions, metadata, or extensibility, evaluate a smart enum pattern or a value object.

Use records for value objects, immutable DTOs, and transport objects. Avoid records for complex entities with identity and lifecycle. Use structs only for small, immutable types with a real performance reason.

## Existing Domain Analysis

When reviewing existing code, map first and judge second:

1. Identify business concepts.
2. Map entities.
3. Map value objects.
4. Map aggregate roots and aggregate boundaries.
5. Identify domain services and whether they are justified.
6. Identify domain events and whether they represent useful facts.
7. Detect invariant leaks, framework dependencies, and technical language.
8. Prioritize improvements by business risk and coupling impact.

Look for:

- Anemic domain model.
- Excessive services.
- Entities without behavior.
- Missing value objects.
- Poor aggregate boundaries.
- Broken invariants.
- Public setters and exposed mutable state.
- Technical or persistence language in the domain.
- Framework, ORM, infrastructure, API, cache, queue, or serialization dependencies.

Review output format:

```text
Finding: <problem>
Impact: <why this matters>
Severity: <Critical | High | Medium | Low>
Recommendation: <specific correction>
```

## New Code Workflow

When generating new domain code:

1. Start from the business rule and ubiquitous language.
2. Create behavioral entities.
3. Use value objects when they make rules clearer.
4. Protect invariants in constructors and methods.
5. Keep setters private or absent.
6. Keep collections private and expose read-only views.
7. Add domain services only for rules that do not belong to one object.
8. Add domain events only when downstream reaction is real.
9. Keep code testable without frameworks.
10. Keep the domain independent from persistence and transport.

## Prohibited Anti-Patterns

Identify and avoid:

- **Anemic Domain Model**: Entities contain only properties while rules live elsewhere.
- **God Aggregate**: One aggregate owns too much of the business process.
- **Setter Everywhere**: Public setters allow invalid state.
- **Primitive Obsession**: Strings, integers, and decimals replace meaningful domain concepts.
- **Utility Domain Service**: Generic services collect unrelated business rules.
- **Disguised Transaction Script**: Application services contain all business behavior.
- **Entity Framework Driven Domain**: Domain shape exists mainly to satisfy EF Core.
- **Leaky Abstractions**: Domain depends on infrastructure or technical details.
- **DTO As Entity**: Transport objects are treated as domain models.
- **Future-Proof Abstraction**: Interfaces, factories, base classes, or events exist only for imagined future needs.

## Validation Checklist

Before completing domain modeling work, verify:

- [ ] The domain represents the business.
- [ ] Entities contain meaningful behavior.
- [ ] Value objects are immutable and meaningful.
- [ ] Invariants are protected.
- [ ] Public setters are absent unless clearly justified.
- [ ] Mutable collections are not exposed.
- [ ] Aggregate boundaries are clear and not oversized.
- [ ] Domain services are justified by real domain rules.
- [ ] Domain events represent completed business facts and have real value.
- [ ] The domain does not depend on frameworks, ORM, infrastructure, API, or transport.
- [ ] Names use ubiquitous language.
- [ ] SOLID is respected where it improves the model.
- [ ] YAGNI is respected.
- [ ] No anemic domain model remains.
