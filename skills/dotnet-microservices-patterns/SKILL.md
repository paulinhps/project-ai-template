---
name: dotnet-microservices-patterns
description: Guide AI agents in creating, evolving, reviewing, and maintaining .NET microservice architectures with Domain-Driven Design, Clean Architecture, autonomous services, independent data ownership, event-driven integration, resilience, observability, versioned contracts, scalability, and sustainable distributed-system boundaries. Use when creating a new microservice, evaluating whether to extract a service, defining bounded contexts, reviewing distributed architecture, designing service-to-service integration, implementing messaging, creating integration events, planning resilience and observability, or assessing scalable .NET solutions.
---

# Dotnet Microservices Patterns

## Overview

Use this skill to design .NET distributed systems that are business-aligned, resilient, observable, horizontally scalable, independently deployable, and capable of independent evolution.

Use microservices only when the business and operational benefits outweigh the distributed-system complexity. Prefer a modular monolith or a single deployable service when the boundaries, autonomy, or scaling needs are not yet clear.

## Related Skills

Coordinate with these skills when they are available:

- `dotnet-clean-architecture`: internal architecture of each service.
- `dotnet-domain-modeling`: domain model, aggregates, value objects, and bounded contexts.
- `dotnet-exceptionless-domain-modeling`: explicit Result-oriented business failures inside services.
- `dotnet-rest-api-design`: HTTP resource design and status-code semantics.
- `dotnet-api-contracts`: JSON API DTOs, serialization, and contract compatibility.
- `dotnet-security-baseline`: authentication, authorization, input validation, secret handling, and safe errors.
- `dotnet-observability`: detailed logging, metrics, tracing, and telemetry guidance when present.
- `dotnet-error-handling`: detailed exception and failure-handling guidance when present.

When guidance conflicts, use `dotnet-clean-architecture` for the internal structure of each service, `dotnet-domain-modeling` for the domain model, and this skill for distributed architecture and interactions between services.

## Operating Mode

Before creating, extracting, or reviewing a microservice, answer:

1. Is there a clear bounded context?
2. Is there business autonomy?
3. Is independent scaling needed?
4. Is independent deployment needed?
5. Does the capability have a different lifecycle?
6. Can ownership reasonably be assigned to an independent team or owner?
7. Is real isolation required?

If most answers are negative, question the microservice approach and recommend a simpler architecture.

For any distributed architecture task:

1. Map bounded contexts and business capabilities first.
2. Define service boundaries from business language, not tables or frameworks.
3. Identify data ownership for each service.
4. Choose synchronous or asynchronous communication per use case.
5. Define versioned contracts for APIs, events, messages, and webhooks.
6. Design resilience, idempotency, observability, security, and failure behavior.
7. Preserve independent deployment and independent data ownership.
8. Prefer the smallest distributed design that solves the real problem.

## Required Principles

- **Business first**: Derive services from business capabilities and bounded contexts, never from database tables, technologies, or team convenience alone.
- **Autonomous services**: Each service must own a coherent business capability and evolve independently.
- **Independent deployment**: Each service must be deployable without coordinated deployment of unrelated services.
- **Independent data**: Each service owns its data. Other services must not read or write its tables directly.
- **Loose coupling**: Depend on stable contracts and business events, not internal implementation details.
- **High cohesion**: Keep each service focused on one clear responsibility.
- **Event driven when appropriate**: Prefer events for decoupled integration and eventual consistency.
- **Fail independently**: A dependency failure must not collapse the whole system.
- **Observable by default**: Every distributed call, event, and background flow must be traceable.
- **Simplicity first**: Avoid premature decomposition and distributed complexity without clear benefit.

## Identifying Microservices

Use strategic DDD to identify bounded contexts and capabilities.

Prefer service names that express business capabilities:

```text
Orders
Billing
Inventory
Catalog
Identity
Notification
```

Avoid technical or CRUD-shaped services:

```text
CustomerCrudService
DatabaseService
EmailTableService
```

Before suggesting a service, verify:

```text
Does it own a business capability?
Does it have a distinct ubiquitous language?
Can it own its data?
Can it be deployed independently?
Can it scale independently?
Can other services interact through explicit contracts?
Does the benefit exceed the operational cost?
```

## Data Ownership

Every microservice must own its own data store or schema boundary.

Prefer:

```text
Orders Service -> Orders Database
Billing Service -> Billing Database
Inventory Service -> Inventory Database
```

Forbid:

```text
Orders Service -> SharedDatabase.Orders
Billing Service -> SharedDatabase.Orders
```

Never integrate services by direct table reads, shared EF Core entities, shared migrations, or cross-service joins. If another service needs data, use an API, event, materialized read model, or explicitly owned replicated projection.

## Communication

Choose communication style per business need.

Use synchronous communication when an immediate answer is required, the operation cannot proceed without the response, and latency is expected to be low:

```text
REST
gRPC
```

Use asynchronous communication when decoupling, eventual processing, retries, or eventual consistency are acceptable:

```text
Azure Service Bus
RabbitMQ
Kafka
Amazon SQS
```

Avoid chatty services. Many synchronous calls across services often indicate a wrong boundary, missing read model, or distributed monolith.

## Contracts

All public contracts must be explicit, versioned, and backward compatible by default.

Version:

- REST APIs.
- gRPC contracts.
- Integration events.
- Commands and messages.
- Webhooks.

Avoid breaking changes without a migration strategy. Prefer additive changes, consumer-driven compatibility checks, deprecation windows, and clear ownership of contract evolution.

Example REST contract:

```http
POST /api/v1/orders
Content-Type: application/json
Idempotency-Key: 4cbf2e19-25b0-47fd-87c6-40af7af03c5f
X-Correlation-Id: 2f44c36d6d9d4d2cbb9c3fefca43780a

{
  "customerId": "3d4f6337-2f03-43ce-84c0-83a44e3d5871",
  "items": [
    { "productId": "8c235c87-92f2-4a6a-b41f-c9c2e2a66db7", "quantity": 2 }
  ]
}
```

Example gRPC contract:

```proto
syntax = "proto3";

package billing.v1;

service BillingService {
  rpc AuthorizePayment(AuthorizePaymentRequest) returns (AuthorizePaymentReply);
}

message AuthorizePaymentRequest {
  string order_id = 1;
  string customer_id = 2;
  string idempotency_key = 3;
  string correlation_id = 4;
  int64 amount_minor_units = 5;
  string currency = 6;
}

message AuthorizePaymentReply {
  string payment_id = 1;
  string status = 2;
}
```

## Integration Events

Integration events represent facts that already happened. They must be immutable, versionable, implementation-independent, and business-oriented.

Prefer:

```text
OrderCreated
PaymentApproved
InvoiceIssued
CustomerActivated
```

Avoid intention-shaped events:

```text
CreateOrderCommand
ProcessPaymentRequest
```

Example event contract:

```csharp
public sealed record OrderCreatedIntegrationEvent(
    Guid EventId,
    DateTimeOffset OccurredAt,
    string CorrelationId,
    Guid OrderId,
    Guid CustomerId,
    decimal TotalAmount,
    string Currency);
```

Event ownership must be clear: the service that owns the fact publishes the event. Consumers must not depend on producer database models or private domain events.

## Outbox Pattern

Recommend the Outbox Pattern whenever a service persists state and publishes messages from the same business operation.

Goal:

```text
Database transaction
+ durable outbox message
+ asynchronous publisher
```

Example shape:

```csharp
public sealed class OutboxMessage
{
    public Guid Id { get; init; }
    public DateTimeOffset OccurredAt { get; init; }
    public string Type { get; init; } = "";
    public string Payload { get; init; } = "";
    public string CorrelationId { get; init; } = "";
    public DateTimeOffset? ProcessedAt { get; set; }
    public string? Error { get; set; }
}
```

Use an outbox to avoid a state change being committed while the corresponding event is lost.

## Idempotency

Distributed operations must tolerate duplicate delivery, retries, and replay.

Apply idempotency especially to:

- Payments.
- Financial integrations.
- Event consumers.
- Webhook receivers.
- Message reprocessing.
- Retryable commands.

Use idempotency keys, processed-message tables, natural unique constraints, or deterministic operation identifiers. The same message must not create duplicate side effects.

## Resilience

Every external call must define timeout, retry behavior, cancellation, observability, and failure handling.

Use retries only when the operation is safe and the failure is likely transient:

```csharp
var retryPolicy = Policy
    .Handle<HttpRequestException>()
    .OrResult<HttpResponseMessage>(r => (int)r.StatusCode >= 500)
    .WaitAndRetryAsync(
        retryCount: 3,
        sleepDurationProvider: attempt => TimeSpan.FromMilliseconds(100 * Math.Pow(2, attempt)));
```

Always bound retries. Avoid infinite retries and retry storms. Use dead-letter queues for messages that repeatedly fail.

Use circuit breakers for unstable or external dependencies:

```csharp
var circuitBreaker = Policy
    .Handle<HttpRequestException>()
    .CircuitBreakerAsync(
        exceptionsAllowedBeforeBreaking: 5,
        durationOfBreak: TimeSpan.FromSeconds(30));
```

Always set explicit timeouts:

```csharp
builder.Services
    .AddHttpClient<IBillingClient, BillingClient>(client =>
    {
        client.BaseAddress = new Uri("https://billing");
        client.Timeout = TimeSpan.FromSeconds(3);
    });
```

Use bulkheads when one dependency, queue, tenant, or workload must not exhaust resources used by others. Examples include separate connection pools, independent queues, isolated consumers, and bounded concurrency.

## Consistency and Workflows

Prefer eventual consistency across services. Use strong consistency only when the business truly requires it and the affected data belongs within one service boundary.

Use a Saga when one business process spans multiple services and needs compensation:

```text
Order placed
-> Payment authorized
-> Inventory reserved
-> Invoice issued
```

Choose orchestration when the workflow is complex, long-running, centrally governed, or requires explicit compensation decisions.

Choose choreography when services can react independently to facts and the flow is simple enough to remain understandable.

Example orchestrated saga state:

```csharp
public enum OrderFulfillmentState
{
    Started,
    PaymentAuthorized,
    InventoryReserved,
    InvoiceIssued,
    Compensating,
    Completed,
    Failed
}
```

## Anti-Corruption Layer

Recommend an Anti-Corruption Layer when integrating with legacy systems, external providers, or another bounded context with a different ubiquitous language.

The ACL must translate external models into local domain concepts and prevent foreign terminology, status codes, database models, or transport DTOs from leaking into the domain.

## Observability

Every microservice must include:

- Structured logs.
- CorrelationId propagation.
- TraceId and span context propagation.
- Metrics.
- Health checks.
- Distributed tracing.
- Message and consumer telemetry.

No distributed call or message flow should be invisible.

Example CorrelationId middleware shape:

```csharp
app.Use(async (context, next) =>
{
    var correlationId = context.Request.Headers.TryGetValue("X-Correlation-Id", out var value)
        ? value.ToString()
        : Guid.NewGuid().ToString("N");

    context.Response.Headers["X-Correlation-Id"] = correlationId;
    using (logger.BeginScope(new Dictionary<string, object>
    {
        ["CorrelationId"] = correlationId
    }))
    {
        await next();
    }
});
```

Example distributed tracing setup:

```csharp
builder.Services.AddOpenTelemetry()
    .WithTracing(tracing =>
    {
        tracing
            .AddAspNetCoreInstrumentation()
            .AddHttpClientInstrumentation()
            .AddSource("Orders")
            .AddOtlpExporter();
    });
```

Health checks must distinguish:

- **Liveness**: the process is alive.
- **Readiness**: the service is ready to receive traffic and required dependencies are usable enough.

## Security

Each service must authenticate, authorize, validate input, protect secrets, validate received messages, and enforce its own security rules. Do not trust callers just because they are internal services.

For event consumers and webhooks, validate message schema, source, signature or broker authorization where applicable, replay risk, and authorization to perform the requested side effect.

## Scalability

Design services for horizontal scalability:

- Keep instances stateless when possible.
- Store state in owned durable stores.
- Avoid local memory as the source of truth.
- Partition queues and consumers intentionally.
- Use idempotent consumers for parallel processing.
- Keep resource pools bounded and observable.

## Reviewing Existing Architecture

When reviewing a distributed system:

1. Map bounded contexts.
2. Map dependencies between services.
3. Map data stores and ownership.
4. Identify coupling and synchronous call chains.
5. Identify distributed monolith symptoms.
6. Identify integration events and event ownership.
7. Identify public contracts and versioning.
8. Identify consistency risks.
9. Evaluate observability.
10. Evaluate resilience.
11. Classify risks.
12. Suggest prioritized improvements.

Review output format:

```text
Finding: <problem>
Impact: <why this matters>
Severity: <Critical | High | Medium | Low>
Recommendation: <specific correction>
```

## Creating New Microservices

When creating a new microservice:

1. Validate the real need for distribution.
2. Identify the bounded context and ubiquitous language.
3. Define the responsibility and owner.
4. Define the owned data store.
5. Define REST, gRPC, event, message, or webhook contracts.
6. Define integration events as facts.
7. Define observability from the first implementation.
8. Define authentication, authorization, and input validation.
9. Define timeout, retry, circuit breaker, bulkhead, idempotency, and DLQ behavior.
10. Define versioning and migration strategy.
11. Ensure independent deployment.

## Correct and Incorrect Cases

Correct:

```text
Orders owns order lifecycle and publishes OrderCreated.
Billing owns payment authorization and publishes PaymentApproved.
Inventory owns stock reservation and publishes InventoryReserved.
Each service has its own database.
Each integration uses explicit contracts and correlation IDs.
```

Incorrect:

```text
Orders reads Billing tables to check payment.
Billing updates Orders tables after payment.
Inventory calls Orders, Billing, Catalog, and Notification synchronously for every reservation.
All services share one database and one deployment pipeline.
Events are named ProcessPaymentRequest and require producer entity JSON.
```

## Prohibited Anti-Patterns

Identify and avoid:

- **Distributed monolith**: services are separately deployed but tightly coupled.
- **Shared database**: multiple services share tables or migrations.
- **Chatty services**: excessive synchronous calls across service boundaries.
- **Synchronous everything**: every workflow depends on HTTP availability.
- **Integration by database**: services read or write another service's data store.
- **God service**: one service centralizes unrelated domain behavior.
- **Event without ownership**: events are published without clear responsibility.
- **Missing observability**: distributed flows cannot be traced.
- **Retry storm**: retries are infinite, aggressive, or uncoordinated.
- **Premature microservices**: services are split without a real business or operational need.

## Validation Checklist

Before completing any distributed architecture task, verify:

- [ ] There is a clear bounded context.
- [ ] The service has one clear responsibility.
- [ ] The service owns its data.
- [ ] No service directly accesses another service's database.
- [ ] Public contracts are versioned.
- [ ] Events represent completed business facts.
- [ ] Idempotency is defined for commands, consumers, and retries.
- [ ] Retry behavior is bounded and observable.
- [ ] Timeouts are explicit for external calls.
- [ ] Circuit breaker or bulkhead behavior is considered where dependency failure can cascade.
- [ ] Observability is defined.
- [ ] CorrelationId and distributed tracing are propagated.
- [ ] Health checks include liveness and readiness.
- [ ] Security is enforced per service.
- [ ] The service can be deployed independently.
- [ ] The service can scale independently when needed.
- [ ] The benefit of distribution exceeds the complexity.
