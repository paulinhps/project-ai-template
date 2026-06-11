---
name: dotnet-efcore-persistence
description: Guide AI agents in implementing, reviewing, and evolving Entity Framework Core persistence in .NET applications using Clean Architecture, DDD, secure data access, performance-aware queries, migrations, transactions, repositories, Unit of Work, and integration-testable infrastructure. Use when working with DbContext, Fluent API mappings, EF Core migrations, repositories, query optimization, tracking, Include usage, raw SQL, concurrency, indexes, persistence reviews, or database access in .NET solutions.
---

# Dotnet EF Core Persistence

Use this skill to keep EF Core persistence isolated in Infrastructure, mapped explicitly, safe by default, efficient under real data volume, and testable without leaking persistence concerns into Domain, Application, or Presentation.

## Coordinate With Related Skills

Apply these skills when available:

- `dotnet-clean-architecture` for layer boundaries and dependency direction.
- `dotnet-domain-modeling` for aggregate, entity, and value object design.
- `dotnet-exceptionless-domain-modeling` for Result-oriented domain failures.
- `dotnet-security-baseline` for input, secrets, logging, and secure data access.
- `dotnet-unit-testing` for test design when available.
- `dotnet-observability` for logging, metrics, tracing, and alerts when available.

When guidance conflicts:

1. Let `dotnet-clean-architecture` define dependencies between layers.
2. Let `dotnet-domain-modeling` define the domain model and invariants.
3. Let this skill define EF Core persistence, mapping, DbContext, migrations, transactions, and query behavior.

## Required Principles

- Treat persistence as Infrastructure. Domain must not depend on EF Core.
- Prefer Fluent API with `IEntityTypeConfiguration<T>` over attributes.
- Keep queries explicit and shaped for the use case.
- Keep business rules out of `DbContext`, configurations, migrations, and repositories.
- Design for performance: volume, tracking, includes, indexes, paging, and projection.
- Use safe data access. Never concatenate external input into SQL.
- Keep EF Core details out of Presentation and avoid direct `DbContext` access from controllers or endpoints.

## Architectural Placement

Place EF Core in Infrastructure:

```text
src/
  Product.Domain
  Product.Application
  Product.Infrastructure
    Persistence/
      ProductDbContext.cs
      Configurations/
      Migrations/
      Repositories/
  Product.Api
```

Allowed dependencies:

```text
Infrastructure -> Application
Infrastructure -> Domain
Application -> Domain
Api -> Application
Api -> Infrastructure
```

Forbidden dependencies:

```text
Domain -> EntityFrameworkCore
Application -> EntityFrameworkCore
Presentation -> DbContext
```

Application may define persistence ports when they protect use cases from EF Core:

```csharp
public interface IOrderRepository
{
    Task<Order?> GetByIdAsync(OrderId id, CancellationToken cancellationToken);
    Task AddAsync(Order order, CancellationToken cancellationToken);
}
```

Implement ports in Infrastructure.

## DbContext Rules

Create `DbContext` in Infrastructure. Use it as the unit of data access and EF Core Unit of Work.

```csharp
public sealed class AppDbContext : DbContext
{
    public DbSet<Order> Orders => Set<Order>();

    public AppDbContext(DbContextOptions<AppDbContext> options)
        : base(options)
    {
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);
    }
}
```

Require:

- Apply configurations from assembly.
- Expose `DbSet<T>` only when useful.
- Keep business logic out of `DbContext`.
- Keep controllers and endpoints from injecting `DbContext` directly.
- Register `DbContext` in Infrastructure composition code or API composition root according to the project pattern.
- Keep connection strings in configuration or secret stores, never hardcoded.

## Entity Configurations

Use one configuration file per entity. Prefer explicit table names, keys, conversions, relationships, indexes, access modes, and constraints.

```csharp
public sealed class OrderConfiguration : IEntityTypeConfiguration<Order>
{
    public void Configure(EntityTypeBuilder<Order> builder)
    {
        builder.ToTable("orders");

        builder.HasKey(order => order.Id);

        builder.Property(order => order.Id)
            .HasConversion(
                id => id.Value,
                value => new OrderId(value));

        builder.Property(order => order.CreatedAt)
            .IsRequired();

        builder.Navigation(order => order.Items)
            .UsePropertyAccessMode(PropertyAccessMode.Field);
    }
}
```

Preserve the domain model. Do not weaken aggregate invariants for EF convenience. Use backing fields, private constructors, conversions, owned types, and explicit relationship mappings when needed.

## Value Objects

Map value objects explicitly. Choose the pattern that matches project conventions and query needs:

- `HasConversion` for scalar value objects such as IDs and simple wrappers.
- `OwnsOne` for embedded value objects.
- EF Core complex types when the project uses a compatible EF Core version and convention.
- Separate tables only when the value object has lifecycle or query needs that justify it.

```csharp
builder.OwnsOne(customer => customer.Address, address =>
{
    address.Property(x => x.Street).HasColumnName("street");
    address.Property(x => x.City).HasColumnName("city");
});
```

## Enums

Map enums explicitly and follow the project standard. Use string conversion when readability and compatibility matter; use numeric storage only when explicitly chosen.

```csharp
builder.Property(order => order.Status)
    .HasConversion<string>();
```

For API payload enum behavior, follow `dotnet-api-contracts` when available.

## Repositories

Use repositories only when they add architectural value:

- Preserve Application abstraction.
- Work with aggregate roots.
- Encapsulate meaningful persistence behavior.
- Improve use-case testability.
- Prevent EF Core leakage into Application.

Avoid repositories that only mirror `DbSet<T>` or universal generic CRUD abstractions unless the project has an explicit standard and a concrete need.

Acceptable:

```csharp
public interface IOrderRepository
{
    Task<Order?> GetByIdAsync(OrderId id, CancellationToken cancellationToken);
    Task AddAsync(Order order, CancellationToken cancellationToken);
}
```

Avoid by default:

```csharp
public interface IRepository<T>
{
    Task<T?> GetByIdAsync(Guid id);
    Task<List<T>> GetAllAsync();
    Task AddAsync(T entity);
    Task UpdateAsync(T entity);
    Task DeleteAsync(T entity);
}
```

Do not expose `IQueryable` outside Infrastructure unless the project has a clear query policy that controls filtering, authorization, paging, and execution.

## Unit Of Work

Remember that `DbContext` is already a Unit of Work. Create an explicit abstraction only when:

- Application must coordinate multiple repositories without knowing EF Core.
- The project uses strict Clean Architecture boundaries.
- A use case needs a single commit boundary across multiple persistence operations.
- Testing benefits from a narrow commit contract.

```csharp
public interface IUnitOfWork
{
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
```

## Migrations

Version migrations and review them before commit.

Require:

- Descriptive names such as `AddOrdersTable`, `AddCustomerDocumentIndex`, or `RenameInvoiceStatusColumn`.
- Small, cohesive migrations.
- Review generated operations for accidental table, column, index, or constraint changes.
- Evaluate production impact, locks, data volume, rollback strategy, and downtime risk.
- Avoid data deletion without explicit migration strategy.
- Avoid giant migrations that mix unrelated schema changes.

Do not commit a migration until its generated operations match the intended model change.

## Query Design

Shape queries for the use case:

- Project read models to DTOs when appropriate.
- Use `AsNoTracking()` for read-only queries.
- Use tracking when entities will be modified and saved.
- Filter in the database, not in memory.
- Add explicit ordering, especially before paging.
- Use pagination for large lists.
- Avoid loading whole aggregates when a projection is enough.
- Keep `Include` usage minimal and justified.
- Pass `CancellationToken` to async EF operations.

Example read model:

```csharp
var orders = await dbContext.Orders
    .AsNoTracking()
    .Where(order => order.CustomerId == customerId)
    .OrderByDescending(order => order.CreatedAt)
    .Skip((page - 1) * pageSize)
    .Take(pageSize)
    .Select(order => new OrderSummaryResponse(
        order.Id.Value,
        order.Status,
        order.CreatedAt))
    .ToListAsync(cancellationToken);
```

## Tracking

Choose tracking based on intent:

- Use `AsNoTracking()` for list screens, reports, lookups, read models, and other read-only operations.
- Use tracking when the loaded entity will be changed and persisted.
- Consider `AsNoTrackingWithIdentityResolution()` only when read-only materialization needs identity resolution.
- Avoid unnecessary tracking in hot paths and large result sets.

## Includes And N+1

Use `Include` only when the navigation data is required by the use case.

Avoid broad graph loading:

```csharp
.Include(x => x.Items)
.Include(x => x.Customer)
.Include(x => x.Payments)
.Include(x => x.History)
```

Prefer:

- Projection with `Select`.
- A query designed for the screen or use case.
- Explicit loading when it is intentional and bounded.
- Split queries when they reduce cartesian explosion and the project accepts the tradeoff.

Disable lazy loading by default. It creates invisible queries, N+1 risk, unpredictable performance, and harder review.

## Transactions

Use explicit transactions when:

- Multiple changes must be atomic.
- A use case updates multiple aggregates.
- Persistence coordinates with an outbox.
- Partial persistence would create an invalid system state.

Keep transactions short. Do not hold transactions open while doing network calls, user interaction, or long-running work.

## Concurrency

Consider concurrency control when simultaneous updates can overwrite data or violate a workflow.

Common strategies:

- Row version or timestamp columns.
- Optimistic concurrency tokens.
- Version value objects or explicit version properties.
- Conflict handling in Application with clear user-facing outcomes.

```csharp
builder.Property<byte[]>("RowVersion")
    .IsRowVersion();
```

## Indexes

Create indexes for:

- Frequently filtered columns.
- Frequently ordered columns.
- Foreign keys.
- Unique fields.
- Critical read paths.

```csharp
builder.HasIndex(order => order.CustomerId);
builder.HasIndex(order => order.ExternalId).IsUnique();
```

Match indexes to actual query shapes. Consider composite indexes when filters and ordering commonly appear together.

## Soft Delete And Audit

Use soft delete only when required. If adopted:

- Add explicit properties such as `IsDeleted`, `DeletedAt`, or `DeletedBy`.
- Apply query filters carefully.
- Account for administrative queries and recovery flows.
- Include audit requirements in migration and query review.

```csharp
builder.HasQueryFilter(entity => !entity.IsDeleted);
```

For audit fields, consider `CreatedAt`, `CreatedBy`, `UpdatedAt`, `UpdatedBy`, `DeletedAt`, and `DeletedBy`. Do not couple domain entities directly to the authenticated user or HTTP context.

## Raw SQL

Use raw SQL only when EF Core cannot express the query well, a provider feature is required, or measured performance justifies it.

Require:

- Parameterized SQL.
- No external input concatenation.
- Validation or allowlisting for dynamic identifiers and sort fields.
- A short comment explaining why EF Core query APIs are not enough when the reason is not obvious.
- No sensitive data in logs.

## Security

Before finishing persistence code, verify:

- No SQL injection paths.
- No hardcoded connection strings, passwords, tokens, or secrets.
- Dynamic filters, sorting, and search fields are validated or allowlisted.
- Logs do not include sensitive data.
- Authorization filters are enforced in Application or query design where required.
- Database errors returned through APIs do not expose infrastructure details.

## Testing

Prefer integration tests with a real database in a container for relational behavior, transactions, constraints, provider-specific SQL, migrations, and concurrency.

Use SQLite only when its behavior is compatible with the target provider for the tested behavior.

Use EF Core InMemory only for simple non-relational tests. Do not rely on InMemory for relational constraints, transactions, SQL translation, provider behavior, concurrency, or migration validation.

## Observability

For critical persistence operations, consider:

- Structured logs with operation name and relevant safe identifiers.
- Execution time and slow-query visibility.
- Correlation ID or trace context.
- Metrics for failure counts, latency, retries, and timeouts.
- Alerts for critical persistence failures.

Never log secrets, credentials, full connection strings, or sensitive payload fields.

## Existing Code Review Workflow

When reviewing persistence:

1. Map DbContext classes and their registration.
2. Map entity configurations and migrations.
3. Map repositories, Unit of Work abstractions, and query services.
4. Check layer dependencies for EF Core leakage.
5. Identify `DbContext` outside Infrastructure or direct Presentation usage.
6. Identify problematic queries, excessive includes, N+1 risks, and unnecessary tracking.
7. Identify suspicious migrations or accidental schema changes.
8. Identify raw SQL and dynamic query security risks.
9. Identify test gaps or improper InMemory usage.
10. Prioritize corrections by security, correctness, performance, and architecture impact.

## New Code Workflow

When creating persistence code:

1. Place EF Core artifacts in Infrastructure.
2. Add Fluent API configuration per entity.
3. Preserve domain independence and aggregate invariants.
4. Add repositories only when they protect Application or encapsulate meaningful persistence.
5. Add a descriptive migration when schema changes are required.
6. Use `AsNoTracking()` and projections for read-only queries when appropriate.
7. Add pagination for large collections.
8. Consider indexes, transactions, concurrency, and observability.
9. Keep EF Core details out of Domain, Application, and Presentation.

## Decision Questions

Before implementing or approving persistence, answer:

1. Does this logic belong to persistence or the domain?
2. Does Application need to know EF Core?
3. Does this query need tracking?
4. Does this list need pagination?
5. Is there N+1 risk?
6. Is the needed index present or planned?
7. Is concurrency control needed?
8. Is an explicit transaction needed?
9. Does the mapping preserve the domain model?
10. Is the code integration-testable?

## Prohibited Anti-Patterns

- `DbContext` injected into controllers, endpoints, or presentation handlers.
- EF Core referenced by Domain.
- EF Core referenced by Application without a deliberate project standard.
- Generic repository that only mirrors `DbSet<T>`.
- Loading complete graphs with `Include` without need.
- Lazy loading enabled by default.
- InMemory provider used as proof of relational behavior.
- Accidental migrations.
- External input concatenated into SQL.
- Uncontrolled `IQueryable` leakage.
- Business rules in `DbContext`, configurations, or migrations.

## Validation Checklist

Before concluding a persistence change, verify:

- [ ] EF Core is restricted to Infrastructure.
- [ ] Domain does not depend on EF Core.
- [ ] Application does not depend on EF Core unless an explicit project standard allows it.
- [ ] `DbContext` contains no business logic.
- [ ] Controllers and endpoints do not access `DbContext` directly.
- [ ] Entity mappings use Fluent API.
- [ ] Read-only queries use `AsNoTracking()` when applicable.
- [ ] Large lists use pagination.
- [ ] No obvious N+1 query path exists.
- [ ] Includes are necessary and bounded.
- [ ] Indexes were considered for critical queries.
- [ ] Transactions were considered for atomic operations.
- [ ] Concurrency was considered for contested updates.
- [ ] Migrations were reviewed for unintended changes.
- [ ] Raw SQL is parameterized.
- [ ] Integration tests were considered for relational behavior.
