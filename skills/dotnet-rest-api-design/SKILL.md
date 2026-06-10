---
name: dotnet-rest-api-design
description: Guide AI agents in creating, evolving, reviewing, and maintaining REST APIs in .NET applications with correct HTTP semantics, resource-oriented routes, explicit request/response DTOs, status codes, ProblemDetails errors, pagination, filtering, sorting, versioning, OpenAPI documentation, basic API security, backward compatibility, and Clean Architecture presentation-layer boundaries. Use when creating or reviewing ASP.NET Core controllers, Minimal APIs, REST endpoints, HTTP contracts, API DTOs, route consistency, response standards, Swagger/OpenAPI metadata, or API evolution plans.
---

# Dotnet REST API Design

Use this skill to design .NET REST APIs that are predictable, secure, versionable, well documented, and aligned with the application's architecture. Keep the Presentation layer thin: adapt HTTP to Application use cases and map Application results back to HTTP.

## Related Skills

Apply these skills when they exist in the project:

- `dotnet-clean-architecture`: owns layer separation and dependency direction.
- `dotnet-domain-modeling`: owns domain rules, aggregates, entities, and invariants.
- `dotnet-exceptionless-domain-modeling`: owns explicit business failure results instead of exception-driven domain flow.
- `dotnet-error-handling`: owns project-wide error format and error taxonomy.
- `dotnet-security-baseline`: owns detailed security requirements.

When responsibilities conflict, this skill owns REST design, HTTP contracts, route behavior, status code mapping, and Presentation-layer behavior.

Do not use this skill to define business rules, model domain entities, implement persistence, design complex database queries, define internal messaging, or design microservice architecture. Use the specialized skill for those concerns.

## Operating Mode

Before creating or changing an endpoint:

1. Identify the resource being exposed.
2. Choose the HTTP method that matches the operation.
3. Define the route using resource names, not action names.
4. Define stable request and response DTOs.
5. Define success and error status codes.
6. Check whether the contract leaks domain, EF, infrastructure, or internal details.
7. Check backward compatibility and versioning risk.
8. Decide whether pagination, filtering, sorting, or idempotency are required.
9. Delegate behavior to Application; do not put business rules in Presentation.
10. Update OpenAPI/Swagger metadata and error documentation.

When reviewing existing APIs, map endpoints first, then report prioritized findings for route design, methods, status codes, contracts, domain leakage, fat controllers, inconsistent errors, missing pagination, security gaps, and breaking-change risk.

## Required Principles

- **Resource-oriented design**: routes represent resources, not actions.
- **HTTP semantics**: methods and status codes match the actual behavior.
- **Explicit contracts**: requests and responses are clear, stable, and API-owned.
- **No domain leakage**: never return domain entities, EF entities, or infrastructure models directly.
- **Predictable errors**: use `ProblemDetails` or the project-standard equivalent.
- **Backward compatibility**: avoid public contract breaks unless versioned deliberately.
- **Thin controllers**: controllers and endpoints only validate HTTP shape, map, call Application, and return HTTP responses.

Prefer:

```text
GET /api/v1/customers/{customerId}/orders
POST /api/v1/orders
PATCH /api/v1/orders/{orderId}/status
```

Avoid:

```text
GET /api/v1/getOrders
POST /api/v1/createOrder
POST /api/v1/updateOrderStatus
```

## HTTP Methods

Use `GET` for reads. It must be safe, idempotent, and must not alter state.

Use `POST` for creation or non-idempotent commands.

Use `PUT` for complete replacement of a resource.

Use `PATCH` for partial updates, including focused changes such as status transitions.

Use `DELETE` for deletion or deactivation according to product rules. Make the observable behavior explicit.

## Status Codes

Use success codes consistently:

```text
200 OK              successful query or command with response body
201 Created         resource created; include Location when possible
202 Accepted        asynchronous work accepted
204 No Content      successful command with no response body
```

Use client error codes consistently:

```text
400 Bad Request             malformed request or syntactic validation failure
401 Unauthorized            missing or invalid authentication
403 Forbidden               authenticated caller lacks permission
404 Not Found               resource does not exist or is not visible to caller
409 Conflict                state conflict, concurrency conflict, duplicate identity
422 Unprocessable Entity    semantic/business rule violation
429 Too Many Requests       rate limit exceeded
```

Use server error codes consistently:

```text
500 Internal Server Error
502 Bad Gateway
503 Service Unavailable
504 Gateway Timeout
```

Never return `200 OK` for errors.

## Result Pattern Mapping

When the project uses explicit results, especially with `dotnet-exceptionless-domain-modeling`, map expected outcomes without relying on exceptions:

```text
Result.Success<T>       -> 200 OK
Result.Created<T>       -> 201 Created
Result.NoContent        -> 204 No Content
Validation Error        -> 400 Bad Request
Business Rule Violation -> 422 Unprocessable Entity
Conflict                -> 409 Conflict
Not Found               -> 404 Not Found
Unauthorized            -> 401 Unauthorized
Forbidden               -> 403 Forbidden
Unexpected Exception    -> 500 Internal Server Error
```

Expected business failures should flow through explicit result values. Reserve exceptions for exceptional or unexpected failures.

Example mapping helper:

```csharp
static IResult ToHttpResult<T>(Result<T> result)
{
    return result.Status switch
    {
        ResultStatus.Success => Results.Ok(result.Value),
        ResultStatus.Created => Results.Created(result.Location!, result.Value),
        ResultStatus.NoContent => Results.NoContent(),
        ResultStatus.Invalid => Results.ValidationProblem(result.ToModelState()),
        ResultStatus.NotFound => Results.NotFound(result.ToProblemDetails()),
        ResultStatus.Conflict => Results.Conflict(result.ToProblemDetails()),
        ResultStatus.Forbidden => Results.Forbid(),
        ResultStatus.Unauthorized => Results.Unauthorized(),
        _ => Results.Problem(statusCode: StatusCodes.Status500InternalServerError)
    };
}
```

Adapt names and result types to the project.

## Routes

Routes must use nouns, plural collection names, predictable hierarchy, and only meaningful nesting. Avoid excessive depth.

Use versioned routes when the project adopts URL versioning:

```text
/api/v1/customers
/api/v1/customers/{customerId}
/api/v1/customers/{customerId}/orders
/api/v1/orders/{orderId}
```

Avoid:

```text
/api/v1/customer/getAll
/api/v1/order/create
/api/v1/customer/{customerId}/orders/{orderId}/items/{itemId}/details
```

Prefer shallow routes plus filters over deep nesting unless the child resource has no meaningful identity outside the parent.

## Controllers and Minimal APIs

Accept both Controllers and Minimal APIs. Follow the existing project style. If no explicit style exists, prefer Minimal APIs for new small endpoints.

Prefer Controllers when the API has many endpoints, resource-based organization, MVC conventions, filters, attributes, or a current controller pattern.

Prefer Minimal APIs when the API is small, endpoints are simple, the project is functional in style, or lower boilerplate improves clarity.

In both styles:

- Do not include business rules.
- Do not access Infrastructure directly.
- Do not inject `DbContext` or repositories into Presentation for use-case behavior.
- Do not expose domain or EF entities.
- Delegate to Application commands, queries, handlers, or use cases.

## DTOs

Create API-specific request and response contracts. Do not reuse domain entities or persistence entities as API DTOs.

Common names:

```text
CreateOrderRequest
UpdateOrderRequest
OrderResponse
OrderSummaryResponse
PagedResponse<T>
ErrorResponse
```

DTO rules:

- Requests and responses must be explicit and stable.
- `record` is acceptable when it matches project style.
- DTOs must not contain business behavior.
- DTOs must not depend on EF Core.
- Responses should expose public API language, not internal domain implementation.
- Add fields compatibly; do not rename, remove, or change types in public contracts without versioning.

Example:

```csharp
public sealed record CreateOrderRequest(
    Guid CustomerId,
    IReadOnlyList<CreateOrderItemRequest> Items);

public sealed record CreateOrderItemRequest(
    Guid ProductId,
    int Quantity);

public sealed record OrderResponse(
    Guid Id,
    Guid CustomerId,
    string Status,
    decimal Total,
    DateTimeOffset CreatedAt);
```

## Input Validation

Validate HTTP-facing shape in Presentation:

- required fields, formats, lengths, types, ranges, and payload structure
- syntactic validation in Presentation
- use-case validation in Application
- invariants in Domain
- standardized errors for every validation failure

Use the project's validation library and error pipeline when present. Do not duplicate domain rules in request validators.

## ProblemDetails

Prefer ASP.NET Core `ProblemDetails` or the project's equivalent standardized format.

Recommended shape:

```json
{
  "type": "https://httpstatuses.com/422",
  "title": "Business rule violation",
  "status": 422,
  "detail": "Order must contain at least one item.",
  "instance": "/api/v1/orders",
  "errors": [
    {
      "code": "order.must_contain_items",
      "message": "Order must contain at least one item.",
      "target": "items"
    }
  ]
}
```

Do not expose stack traces, exception types, SQL, infrastructure details, secrets, or sensitive values in API errors.

## Pagination, Filtering, and Sorting

Consider pagination for every query that returns a list.

Use the project standard. If no standard exists, prefer:

```text
GET /api/v1/orders?page=1&pageSize=20
```

Alternative when already established:

```text
GET /api/v1/orders?limit=20&offset=0
```

Paged response shape:

```json
{
  "items": [],
  "page": 1,
  "pageSize": 20,
  "totalItems": 100,
  "totalPages": 5
}
```

Include `totalItems` and `totalPages` when the project standard or user experience requires them. Avoid expensive totals when the product does not need them.

Make filters explicit:

```text
GET /api/v1/orders?status=paid&createdFrom=2026-01-01&createdTo=2026-01-31
```

Use predictable sorting:

```text
GET /api/v1/orders?sort=createdAt:desc
```

Avoid ambiguous filters and complex GET request bodies.

## Idempotency

Consider idempotency for operations that may be retried or cause financial/external side effects:

- payments
- order creation
- financial workflows
- external integrations
- retryable commands

Use an `Idempotency-Key` header when the operation needs client-provided deduplication:

```text
Idempotency-Key: 3bbcc13f-3b37-42cb-8e80-71f50d76c3f2
```

Document the header and behavior in OpenAPI.

## Versioning and Compatibility

Use an explicit versioning strategy when APIs have external consumers or contract-break risk.

Accepted strategies:

```text
/api/v1/orders
Header: api-version: 1.0
Media type: application/vnd.company.orders.v1+json
```

Prefer URL versioning when simplicity and clarity are the priority.

Treat these as breaking changes:

- Removing a response field.
- Renaming a field.
- Changing a field type.
- Changing expected status code semantics.
- Changing endpoint behavior.
- Removing an endpoint.
- Making an optional request field required.

Prefer adding optional fields, creating a new version, and keeping old behavior during transition.

## OpenAPI and Swagger

Document every endpoint with summary, useful description, request body, response types, success and error status codes, authentication and authorization requirements, and examples when useful.

Do not expose internal domain, persistence, or infrastructure details in documentation.

Minimal API example:

```csharp
app.MapPost("/api/v1/orders", CreateOrder)
    .WithName("CreateOrder")
    .WithSummary("Create an order")
    .Produces<OrderResponse>(StatusCodes.Status201Created)
    .Produces<ProblemDetails>(StatusCodes.Status400BadRequest)
    .Produces<ProblemDetails>(StatusCodes.Status422UnprocessableEntity)
    .RequireAuthorization();
```

Controller example:

```csharp
[HttpPost]
[ProducesResponseType(typeof(OrderResponse), StatusCodes.Status201Created)]
[ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status400BadRequest)]
[ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status422UnprocessableEntity)]
public async Task<ActionResult<OrderResponse>> Create(
    CreateOrderRequest request,
    CancellationToken cancellationToken)
{
    var command = new CreateOrderCommand(request.CustomerId, request.Items);
    var result = await createOrder.Handle(command, cancellationToken);

    return result.Match<ActionResult<OrderResponse>>(
        created => CreatedAtAction(nameof(GetById), new { orderId = created.Id }, created),
        error => error.ToActionResult());
}
```

## Basic API Security

Always consider authentication, authorization, CORS, HTTPS, rate limiting, input validation, safe logs, sensitive data exposure, and stack-trace suppression. Follow `dotnet-security-baseline` for detailed rules when available.

## Response Standards

Follow the project standard. If none exists, recommend:

- commands: `201 Created` with `Location`, `204 No Content`, or `202 Accepted`
- queries: `200 OK` with a response body
- errors: `ProblemDetails`

Avoid mandatory generic success envelopes for every response unless the project already uses one consistently.

## Presentation Layer Rules

Presentation must:

- receive HTTP requests
- validate initial request structure
- call Application
- map Application results to HTTP
- return API responses
- apply authentication and authorization
- document contracts

Presentation must not:

- execute business rules
- access the database directly
- know EF Core for use-case behavior
- know infrastructure details
- return domain entities directly

Correct Minimal API:

```csharp
app.MapPost("/api/v1/orders", async (
    CreateOrderRequest request,
    ICreateOrderUseCase useCase,
    CancellationToken cancellationToken) =>
{
    var command = new CreateOrderCommand(
        request.CustomerId,
        request.Items.Select(x => new CreateOrderItem(x.ProductId, x.Quantity)).ToList());

    var result = await useCase.Execute(command, cancellationToken);

    return result.Match<IResult>(
        order => Results.Created($"/api/v1/orders/{order.Id}", order),
        errors => errors.ToProblemHttpResult());
});
```

Incorrect Minimal API:

```csharp
app.MapPost("/api/v1/createOrder", async (CreateOrderRequest request, AppDbContext db) =>
{
    var order = new OrderEntity { CustomerId = request.CustomerId, Status = "Draft" };
    db.Orders.Add(order);
    await db.SaveChangesAsync();
    return Results.Ok(order);
});
```

## Review Checklist

Before completing any API change, verify:

- [ ] Route represents a resource.
- [ ] HTTP method is correct.
- [ ] Status codes are correct.
- [ ] Requests and responses use DTOs.
- [ ] Domain and EF entities are not exposed.
- [ ] Controller or endpoint contains no business rules.
- [ ] Presentation does not access the database for use-case behavior.
- [ ] Errors are standardized.
- [ ] OpenAPI is updated.
- [ ] Pagination was considered for lists.
- [ ] Filtering and sorting are explicit.
- [ ] Idempotency was considered for critical operations.
- [ ] Basic security was considered.
- [ ] No public contract is broken without versioning.

## Prohibited Anti-Patterns

Reject or refactor:

- action-based routes such as `/getCustomer`, `/createOrder`, `/updateStatus`
- always returning `200 OK`
- returning domain entities or EF entities
- fat controllers with business rules
- controller database access
- exception-driven expected API flow
- inconsistent error shapes per endpoint
- breaking public contracts without versioning
- excessively deep route nesting
- generic DTOs that obscure the public contract
