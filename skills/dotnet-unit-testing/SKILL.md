---
name: dotnet-unit-testing
description: Guide AI agents in creating, reviewing, and evolving unit tests in .NET applications, especially backend systems using Clean Architecture, DDD, APIs, domain models, value objects, aggregates, application services, validation rules, Result-oriented flows, fakes, mocks, and test builders. Use when adding unit tests, reviewing existing unit test quality, organizing test projects, choosing test naming patterns, testing domain behavior, testing application handlers or services, refactoring test setup, or deciding whether a scenario belongs in unit, integration, contract, functional, or persistence tests.
---

# Dotnet Unit Testing

Use this skill to keep .NET unit tests fast, deterministic, readable, behavior-oriented, and valuable as regression protection.

## Coordinate With Related Skills

Apply these skills when available:

- `dotnet-clean-architecture` for layer boundaries, project structure, and dependency direction.
- `dotnet-domain-modeling` for expected domain behavior, invariants, aggregates, entities, value objects, and domain events.
- `dotnet-exceptionless-domain-modeling` for Result-oriented business failures instead of expected domain exceptions.
- `dotnet-error-handling` for error taxonomy and application-level failure handling when available.
- `dotnet-efcore-persistence` for EF Core, database, provider, migration, and integration-test guidance.
- `dotnet-api-contracts` for API DTO and contract behavior when unit tests touch mapping or contract helpers.

When guidance conflicts:

1. Let `dotnet-domain-modeling` define the expected domain behavior.
2. Let `dotnet-exceptionless-domain-modeling` define expected business failures through `Result` or `Result<T>`.
3. Let `dotnet-efcore-persistence` define persistence and database-backed tests.
4. Let this skill define unit-test scope, organization, naming, determinism, builders, fakes, mocks, and test quality.

## Required Principles

- Test observable behavior, not private implementation details.
- Keep unit tests fast and isolated from infrastructure.
- Make tests deterministic: same input, same result, every run.
- Use explicit assertions that reveal the protected behavior.
- Prefer tests that fail for the right reason.
- Avoid fragile tests that break when internals change but behavior does not.
- Follow the existing project framework, naming, helpers, and assertion style.

## Frameworks

Follow the project's existing test framework and libraries. Common acceptable choices include:

- xUnit, NUnit, or MSTest.
- FluentAssertions or the project's assertion library.
- Moq, NSubstitute, FakeItEasy, or local fakes when interaction testing is justified.
- AutoFixture or Bogus when already used or clearly justified.

Do not introduce a new test library without a concrete reason.

## Test Project Organization

Prefer the project structure already in the repository. If no pattern exists, use a structure like:

```text
tests/
  Product.UnitTests/
    Domain/
      Orders/
      Customers/
      ValueObjects/
    Application/
      Commands/
      Queries/
      Services/
    TestSupport/
      Builders/
      Fakes/
      Fixtures/
```

Keep unit tests separate from integration, contract, functional, API, or persistence tests.

## Naming

Use descriptive names and preserve the local convention. Acceptable patterns include:

```csharp
[Fact]
public void Create_ShouldReturnFailure_WhenCustomerIdIsInvalid()
```

```csharp
[Fact]
public void Should_return_failure_when_customer_id_is_invalid()
```

```csharp
[Fact]
public void Given_invalid_customer_id_When_create_order_Then_return_failure()
```

Choose clarity over rigid naming formulas.

## Arrange Act Assert

Prefer a single visible action and explicit assertions:

```csharp
[Fact]
public void Create_ShouldReturnFailure_WhenItemsAreEmpty()
{
    // Arrange
    var customerId = CustomerId.New();
    var items = Array.Empty<OrderItem>();

    // Act
    var result = Order.Create(customerId, items);

    // Assert
    result.IsFailure.Should().BeTrue();
    result.Errors.Should().Contain(DomainErrors.Order.MustContainItems);
}
```

Keep setup readable. Use builders or fakes only when they reduce duplication without hiding the scenario.

## Domain Unit Tests

Prioritize domain tests for:

- Entities and aggregate roots.
- Value objects.
- Domain services.
- Invariants and validation rules.
- State transitions.
- Domain events when event emission is observable behavior.
- Business failure paths and boundary cases.

Example:

```csharp
[Fact]
public void AddItem_ShouldIncreaseItemsCount_WhenQuantityIsValid()
{
    // Arrange
    var order = new OrderTestBuilder().Build();
    var product = new ProductTestBuilder().Build();

    // Act
    var result = order.AddItem(product, 2);

    // Assert
    result.IsSuccess.Should().BeTrue();
    order.Items.Should().HaveCount(1);
}
```

Do not mock domain entities, value objects, or aggregates. Build real domain objects in valid states.

## Result Pattern Tests

When the project uses Result-oriented domain modeling, test business failures explicitly:

```csharp
result.IsFailure.Should().BeTrue();
result.Errors.Should().Contain(DomainErrors.Order.InvalidQuantity);
```

Avoid exception assertions for expected business failures:

```csharp
Assert.Throws<DomainException>(() => order.AddItem(product, 0));
```

Reserve exception tests for impossible states, bugs, violated internal contracts, unexpected failures, or dependencies that genuinely throw.

## Value Object Tests

Validate:

- Successful creation from valid input.
- Failure from invalid input.
- Equality by value.
- Normalization when the value object promises it.
- Immutability when relevant.

Example:

```csharp
[Fact]
public void Create_ShouldNormalizeEmail_WhenEmailIsValid()
{
    // Arrange
    var email = " PAULO@EXAMPLE.COM ";

    // Act
    var result = Email.Create(email);

    // Assert
    result.IsSuccess.Should().BeTrue();
    result.Value.Value.Should().Be("paulo@example.com");
}
```

Use parameterized tests for repeated validation cases:

```csharp
[Theory]
[InlineData("")]
[InlineData(" ")]
[InlineData(null)]
public void Create_ShouldReturnFailure_WhenEmailIsInvalid(string? value)
{
    // Act
    var result = Email.Create(value);

    // Assert
    result.IsFailure.Should().BeTrue();
}
```

## Application Unit Tests

For application services, handlers, commands, and queries, test use-case behavior:

- Valid input.
- Invalid input.
- Domain failure propagation.
- Repository calls when persistence is part of the use case behavior.
- Unit of Work or commit calls when commit is part of the behavior.
- Event publication when observable and required.
- External dependency failures when the service is responsible for handling them.

Example:

```csharp
[Fact]
public async Task Handle_ShouldCreateOrder_WhenCommandIsValid()
{
    // Arrange
    var repository = new FakeOrderRepository();
    var unitOfWork = new FakeUnitOfWork();
    var handler = new CreateOrderHandler(repository, unitOfWork);
    var command = new CreateOrderCommandTestBuilder().Build();

    // Act
    var result = await handler.Handle(command, CancellationToken.None);

    // Assert
    result.IsSuccess.Should().BeTrue();
    repository.SavedOrders.Should().HaveCount(1);
    unitOfWork.SaveChangesCalled.Should().BeTrue();
}
```

Include `CancellationToken` in tests when cancellation behavior is relevant. Do not add cancellation assertions to every test by habit.

## Fakes, Stubs, And Mocks

Prefer simple fakes when they make behavior clearer. Use mocks when:

- Interaction is the behavior being tested.
- A dependency failure must be simulated.
- The dependency is external, slow, nondeterministic, or expensive.
- The test needs a narrow substitute for an application boundary.

Avoid mocking everything. Avoid mocks for domain objects:

```csharp
var order = new Mock<Order>();
```

Favor real domain objects plus narrow fake infrastructure ports.

## Test Builders

Use test builders to reduce repeated setup and improve readability, but only after there is evidence of a valid object state.

Valid evidence includes:

- Existing tests.
- Explicit domain rules.
- Implemented use cases.
- Official examples or documentation.
- Factories, `Create` methods, or existing builders.
- Production code that demonstrates a valid scenario.

Do not invent valid values from generic domain assumptions.

Prefer creating explicit tests first:

```csharp
var result = Product.Create("Notebook", 1000m);
```

After a valid scenario is proven and setup repeats, extract a builder:

```csharp
public sealed record ProductTestBuilder(
    string Name = "Notebook",
    decimal Price = 1000m)
{
    public ProductTestBuilder WithName(string name)
        => this with { Name = name };

    public ProductTestBuilder WithPrice(decimal price)
        => this with { Price = price };

    public Product Build()
        => Product.Create(Name, Price).Value;
}
```

Builder rules:

- Generate a fully valid object by default.
- Prefer immutable `record` builders.
- Make each `With...` method return a new builder instance.
- Represent invalid states explicitly with `With...`, `Without...`, or clearly named methods.
- Keep builders near the test initially.
- Move builders to `TestSupport` only after real reuse appears.
- Keep builders simple and aligned with the real object rules.
- Update builders immediately when required object rules change.
- Avoid hiding behavior that matters to the test.

For composed objects, compose builders and avoid exposing mutable collections directly:

```csharp
public sealed record OrderTestBuilder(
    IReadOnlyList<OrderItemTestBuilder>? ItemBuilders = null)
{
    private IReadOnlyList<OrderItemTestBuilder> EffectiveItemBuilders =>
        ItemBuilders ?? [new OrderItemTestBuilder()];

    public OrderTestBuilder WithItems(IEnumerable<OrderItemTestBuilder> itemBuilders)
        => this with { ItemBuilders = itemBuilders.ToList() };

    public OrderTestBuilder WithoutItems()
        => this with { ItemBuilders = [] };

    public Order Build()
        => Order.Create(
            CustomerId.New(),
            EffectiveItemBuilders.Select(builder => builder.Build()).ToList()).Value;
}
```

Mutable class builders are acceptable only when the project already uses them, immutability would significantly hurt readability, or complexity requires it.

## Deterministic Data

Avoid uncontrolled randomness, wall-clock time, global state, and order-dependent tests.

Prefer:

- Fixed values.
- Deterministic builders.
- Bogus with a seed.
- Injected clocks such as `IClock` or `TimeProvider`.
- Explicit timestamps or IDs when those values affect behavior.

Avoid when it makes tests nondeterministic:

```csharp
Guid.NewGuid();
DateTime.UtcNow;
Random.Shared;
```

Never depend directly on `DateTime.Now` or `DateTime.UtcNow` in unit tests when behavior depends on time.

## What To Test

Prioritize:

- Business rules.
- Invariants.
- Validations.
- State transitions.
- Relevant branches.
- Expected failures.
- Boundary cases.
- Application contracts and use-case behavior.

Avoid spending effort on:

- Trivial getters and setters.
- Framework behavior.
- Private methods.
- Automatic mapping with no business rule.
- Cosmetic coverage tests.

Coverage is an indicator, not the goal. Prefer fewer high-value tests over many low-value tests.

## Unit Vs Other Test Types

Classify tests honestly:

- API endpoint behavior usually belongs to integration, functional, or contract tests.
- EF Core provider behavior, database constraints, migrations, SQL translation, and repository persistence usually belong to integration tests.
- Tests that depend on a real database, provider, queue, filesystem, network, or container are not unit tests.

Follow `dotnet-efcore-persistence` for EF Core and persistence test strategy.

## Existing Test Review Workflow

When reviewing unit tests:

1. Map test project structure and naming conventions.
2. Identify the framework, assertion library, and mocking style.
3. Find fragile tests coupled to implementation details.
4. Find excessive mocks and mocked domain objects.
5. Find tests without meaningful assertions.
6. Find nondeterministic data, time, random values, or ordering.
7. Find infrastructure tests placed in unit-test projects.
8. Find duplicated setup that could become builders or fakes.
9. Find missing coverage for critical business rules and failure paths.
10. Prioritize improvements by correctness, maintainability, and regression risk.

## New Unit Test Workflow

When creating tests:

1. Identify the behavior being protected.
2. Confirm the scenario belongs in unit tests.
3. Follow the existing framework and naming style.
4. Arrange the smallest readable valid state.
5. Execute one primary action.
6. Assert observable behavior explicitly.
7. Use Result assertions for expected business failures.
8. Add builders or fakes only when they improve readability.
9. Avoid unnecessary mocks and private implementation assertions.
10. Keep data deterministic.

## Decision Questions

Before adding or approving a unit test, answer:

1. What behavior is being validated?
2. Does this test depend on infrastructure?
3. Is the test deterministic?
4. Is the test readable?
5. Does the test fail for the right reason?
6. Is there excessive mocking?
7. Is the test coupled to private implementation?
8. Is the scenario relevant?
9. Does the test preserve the project's conventions?
10. Would a future maintainer understand the protected behavior quickly?

## Prohibited Anti-Patterns

- Testing private methods directly.
- Mocking every dependency by default.
- Mocking domain entities, value objects, or aggregates.
- Writing tests without meaningful assertions.
- Writing tests only to raise coverage.
- Using uncontrolled random values.
- Depending on `DateTime.Now` or `DateTime.UtcNow` directly.
- Depending on test execution order.
- Treating database/provider/EF Core behavior as unit tests.
- Using `Assert.Throws` for expected business failures when the project uses Result Pattern.
- Creating global test builders before real reuse exists.
- Creating builders that generate invalid objects by default.
- Introducing new test libraries without justification.

## Validation Checklist

Before concluding unit-test work, verify:

- [ ] Tests validate observable behavior.
- [ ] Tests follow Arrange/Act/Assert or the local equivalent.
- [ ] Test names are descriptive and consistent with the project.
- [ ] Tests are deterministic.
- [ ] Unit tests do not depend on infrastructure.
- [ ] Mocks are limited and justified.
- [ ] Domain objects are not mocked.
- [ ] Business failures use Result assertions when the project uses Result Pattern.
- [ ] Exception assertions are used only for appropriate exceptional cases.
- [ ] Builders and fakes improve readability without hiding the scenario.
- [ ] Builders generate valid objects by default.
- [ ] Test data avoids uncontrolled randomness and real clock dependence.
- [ ] The project style is preserved.
