---
name: dotnet-exceptionless-domain-modeling
description: Guide AI agents in .NET Result-Oriented Domain Modeling as an extension and partial override of dotnet-domain-modeling. Use when creating, reviewing, or refactoring .NET domain entities, value objects, aggregates, domain services, domain events, invariants, validation rules, DomainException usage, Result or Result<T> flows, domain errors, notification patterns, and business failures that should be explicit instead of exception-driven.
---

# Dotnet Exceptionless Domain Modeling

## Overview

Use this skill to model rich .NET domains with explicit outcomes instead of exception-driven business flow. This skill extends `dotnet-domain-modeling`: apply every rule from that skill first, then apply the overrides in this skill whenever expected business failure, validation, or invariant refusal is involved.

If a rule conflicts with `dotnet-domain-modeling`, this skill takes precedence.

## Dependency

This skill depends on `dotnet-domain-modeling`.

When another AI coding agent uses this skill, it must treat the full `dotnet-domain-modeling` guidance as mandatory inherited context. This skill only changes how expected business failures are represented and propagated.

## Core Philosophy

Expected business failures are not exceptions.

Use exceptions for defects and truly exceptional conditions:

- Bugs.
- Impossible states.
- Internal contract violations.
- State corruption.
- Unexpected infrastructure failures.
- Unexpected external dependency failures.
- Programming errors.

Represent invalid business rules explicitly in the domain.

## Required Principles

Every model must respect:

- **Domain Integrity First**: Keep invariants protected by the domain model.
- **Explicit Outcomes**: Make relevant operations communicate success or failure.
- **No Exception Driven Flow**: Do not use exceptions as normal business flow.
- **Fail Fast Without Throwing**: Reject invalid operations early with explicit failures.
- **Predictable Behavior**: Make expected failures visible to callers by contract.
- **Rich Domain Model**: Keep behavior inside entities, value objects, aggregates, and domain services.
- **Framework Independence**: Keep domain failures independent from HTTP, EF Core, queues, UI, and infrastructure.

## Result Pattern

Prefer the result abstraction already adopted by the project. Valid names include:

```csharp
Result
Result<T>
ValidationResult
OperationResult
DomainValidationResult
```

The exact implementation is less important than the behavior:

- Success is explicit.
- Failure is explicit.
- Errors are structured enough for callers, tests, logs, and API mapping.
- Failure is not represented by `null`, ambiguous booleans, or swallowed exceptions.

Basic example:

```csharp
public Result Confirm()
{
    if (Status != OrderStatus.Draft)
        return Result.Failure(DomainErrors.Order.OnlyDraftOrdersCanBeConfirmed);

    if (!_items.Any())
        return Result.Failure(DomainErrors.Order.MustContainItems);

    Status = OrderStatus.Confirmed;
    AddDomainEvent(new OrderConfirmed(Id));

    return Result.Success();
}
```

Avoid:

```csharp
public void Confirm()
{
    if (Status != OrderStatus.Draft)
        throw new DomainException("Only draft orders can be confirmed.");

    if (!_items.Any())
        throw new DomainException("Order must contain items.");

    Status = OrderStatus.Confirmed;
}
```

## Domain Errors

Prefer centralized, stable domain errors when the project has no better established pattern.

```csharp
public static class DomainErrors
{
    public static class Order
    {
        public static readonly Error MustContainItems =
            Error.Validation(
                "order.must_contain_items",
                "Order must contain at least one item.");

        public static readonly Error InvalidQuantity =
            Error.Validation(
                "order.invalid_quantity",
                "Quantity must be greater than zero.");

        public static readonly Error OnlyDraftOrdersCanBeConfirmed =
            Error.Conflict(
                "order.only_draft_can_be_confirmed",
                "Only draft orders can be confirmed.");
    }
}
```

Keep error codes stable, domain-oriented, and useful for tests, logs, metrics, and API mapping.

## Entity And Factory Rules

Creation must prevent invalid state. Prefer controlled creation through factory methods, static `Create` methods, controlled builders, or aggregate factories.

```csharp
public sealed class Order
{
    private readonly List<OrderItem> _items = [];

    public CustomerId CustomerId { get; }
    public IReadOnlyCollection<OrderItem> Items => _items.AsReadOnly();

    private Order(CustomerId customerId, IReadOnlyCollection<OrderItem> items)
    {
        CustomerId = customerId;
        _items.AddRange(items);
    }

    public static Result<Order> Create(
        CustomerId customerId,
        IReadOnlyCollection<OrderItem> items)
    {
        if (items.Count == 0)
            return Result.Failure<Order>(DomainErrors.Order.MustContainItems);

        return Result.Success(new Order(customerId, items));
    }
}
```

Avoid public constructors that can create invalid states or constructors that throw for expected business validation.

## State Change Rules

Business mutations that can be refused must return explicit results.

```csharp
public Result AddItem(Product product, int quantity)
{
    if (quantity <= 0)
        return Result.Failure(DomainErrors.Order.InvalidQuantity);

    _items.Add(new OrderItem(product.Id, quantity, product.Price));

    return Result.Success();
}
```

Avoid:

```csharp
public void AddItem(Product product, int quantity)
{
    if (quantity <= 0)
        throw new DomainException("Invalid quantity.");

    _items.Add(new OrderItem(product.Id, quantity, product.Price));
}
```

## Value Object Rules

Value objects still own their validity. Prefer static creation that returns `Result<T>`.

```csharp
public sealed record Email
{
    public string Value { get; }

    private Email(string value)
    {
        Value = value;
    }

    public static Result<Email> Create(string value)
    {
        if (string.IsNullOrWhiteSpace(value))
            return Result.Failure<Email>(DomainErrors.Email.Invalid);

        var normalized = value.Trim();

        if (!normalized.Contains('@'))
            return Result.Failure<Email>(DomainErrors.Email.Invalid);

        return Result.Success(new Email(normalized));
    }

    public override string ToString() => Value;
}
```

Avoid:

```csharp
public Email(string value)
{
    if (string.IsNullOrWhiteSpace(value))
        throw new DomainException("Email is required.");

    Value = value.Trim();
}
```

## Aggregate Rules

Aggregates still protect consistency boundaries. Operations that can fail for expected business reasons must return `Result`, `Result<T>`, or `ValidationResult`.

```csharp
public Result ConfirmPayment(Money paidAmount)
{
    if (Status != OrderStatus.Draft)
        return Result.Failure(DomainErrors.Order.OnlyDraftOrdersCanBePaid);

    if (!_items.Any())
        return Result.Failure(DomainErrors.Order.MustContainItems);

    if (paidAmount != Total())
        return Result.Failure(DomainErrors.Order.PaidAmountMustMatchTotal);

    Status = OrderStatus.Paid;
    AddDomainEvent(new PaymentConfirmed(Id));

    return Result.Success();
}
```

Emit domain events only after:

- The operation is valid.
- The aggregate is consistent.
- The result is successful.

Never emit domain events for failed operations.

## Domain Service Rules

Domain services must communicate expected failures by contract.

```csharp
public sealed class DiscountPolicy
{
    public Result<Money> Calculate(Customer customer, Order order)
    {
        if (!order.HasItems)
            return Result.Failure<Money>(DomainErrors.Order.MustContainItems);

        if (customer.IsVip && order.TotalAmount.IsGreaterThan(Money.From(500, "USD")))
            return Result.Success(order.TotalAmount.Percentage(10));

        return Result.Success(Money.Zero);
    }
}
```

Do not move domain behavior into services just to make result handling easier. Keep the rich model from `dotnet-domain-modeling`.

## Notification Pattern

Use a notification or validation result when multiple validation errors should be returned together.

```csharp
public static Result<CustomerProfile> Create(string name, int age)
{
    var notification = new Notification();

    if (string.IsNullOrWhiteSpace(name))
        notification.Add(DomainErrors.Customer.NameRequired);

    if (age < 18)
        notification.Add(DomainErrors.Customer.MustBeAdult);

    if (notification.HasErrors)
        return Result.Failure<CustomerProfile>(notification.Errors);

    return Result.Success(new CustomerProfile(name.Trim(), age));
}
```

Prefer notification for input completeness and independent validations. Prefer fail-fast result returns when the first failure makes later checks meaningless.

## API Integration

Keep HTTP mapping outside the domain. Application/API layers can map results directly:

```text
Result.Success           -> 200 OK or 201 Created
Validation error         -> 400 Bad Request
Business rule violation  -> 422 Unprocessable Entity
Conflict                 -> 409 Conflict
Unexpected exception     -> 500 Internal Server Error
```

Do not require `try`/`catch` around expected domain failures to produce HTTP responses.

```csharp
var result = order.AddItem(product, request.Quantity);

return result.Match(
    onSuccess: () => Results.Ok(),
    onFailure: errors => errors.ToProblemDetails());
```

## Testing Rules

Tests for expected business failures should assert results and error codes.

```csharp
var result = order.AddItem(product, 0);

result.IsFailure.Should().BeTrue();
result.Errors.Should().Contain(DomainErrors.Order.InvalidQuantity);
```

Avoid exception assertions for expected business failures:

```csharp
Action act = () => order.AddItem(product, 0);

act.Should().Throw<DomainException>();
```

Use exception assertions only for truly exceptional cases such as impossible states, corruption, or internal contract violations.

## When To Throw

Exceptions are acceptable for:

- Impossible state.
- Internal contract violation.
- State corruption.
- Unexpected external dependency failure.
- Infrastructure failure.
- Bugs and programming errors.

Examples:

```csharp
throw new InvalidOperationException("Paid orders cannot have a missing paid date.");
throw new HttpRequestException("Payment provider returned an unexpected response.");
```

## When Not To Throw

Do not throw for:

- Required field validation.
- Invalid business rule.
- Expected invalid domain state attempt.
- Known invariant refusal.
- Validation error.
- Predictable user failure.
- Operation refused by the domain.

Before throwing, answer:

1. Is this an expected failure?
2. Can the caller reasonably react to it?
3. Is this part of the domain?
4. Can this happen normally in production?

If any answer is "yes", prefer a result pattern.

## Existing Code Analysis

When reviewing existing code:

1. Identify `DomainException` usage.
2. Identify validation implemented by `throw`.
3. Identify domain flows controlled by `try`/`catch`.
4. Identify expected failures hidden in generic exceptions.
5. Identify opportunities for `Result`, `Result<T>`, and notification patterns.
6. Preserve existing invariants while suggesting gradual refactors.
7. Prioritize changes by business risk, API impact, and test impact.

Review output format:

```text
Finding: <problem>
Impact: <why this matters>
Severity: <Critical | High | Medium | Low>
Recommendation: <specific result-oriented correction>
```

## New Code Workflow

When generating new domain code:

1. Apply `dotnet-domain-modeling` first.
2. Use result patterns for expected business failures.
3. Avoid `DomainException` for expected validation and business rules.
4. Use notification patterns when multiple independent errors matter.
5. Centralize domain errors when the project has no equivalent convention.
6. Preserve invariants and prevent invalid state.
7. Keep the domain rich and independent.
8. Emit domain events only after successful operations.
9. Make tests assert results, returned errors, and error codes.

## Prohibited Anti-Patterns

Identify and avoid:

- **DomainException Everywhere**: Exceptions used as the default validation mechanism.
- **Try/Catch Driven Domain**: Normal business flow controlled by exceptions.
- **Hidden Business Errors**: Expected failures hidden in generic exceptions.
- **Validation By Exception**: Validation represented only by `throw`.
- **Silent Invalid State**: Invalid state allowed without explicit failure.
- **Boolean Failure**: `false` returned without explaining why.
- **Null Failure**: `null` returned to represent a domain error.
- **Overbuilt Result Abstraction**: Result types made so complex they obscure the domain.

## Validation Checklist

Before completing domain modeling work, verify:

- [ ] The domain still represents the business.
- [ ] The domain still protects invariants.
- [ ] Invalid state cannot exist.
- [ ] Expected business failures do not use exceptions.
- [ ] Result pattern or equivalent explicit outcome is used.
- [ ] Business errors are explicit and stable enough for callers.
- [ ] The domain remains rich and behavior-focused.
- [ ] The domain remains independent from frameworks and transport.
- [ ] Domain events are emitted only after successful operations.
- [ ] Tests assert results, errors, and domain rules instead of expected business exceptions.
- [ ] Flow remains predictable.
- [ ] SOLID is respected where it improves the model.
- [ ] YAGNI is respected.
