---
name: dotnet-error-handling
description: Guide AI agents in creating, reviewing, and standardizing error handling in .NET applications, including expected failures, Result/Result<T>/ValidationResult patterns, domain errors, DomainException usage, external exception capture, global exception handling, safe HTTP error responses, ProblemDetails mapping, secure logging, correlation ids, and observable failures. Use when implementing or reviewing validations, business failures, exception policies, middleware, external API/SDK integration failures, API error contracts, or inconsistent error responses.
---

# Dotnet Error Handling

Use this skill to make .NET failures explicit, predictable, safe, observable, and aligned with the project's architecture. Prefer the project's existing abstractions and naming; introduce new error primitives only when the codebase has no clear standard.

## Related Skills

Apply these skills when they exist in the project:

- `dotnet-clean-architecture`: owns layer separation and dependency direction.
- `dotnet-domain-modeling`: owns detailed domain model design.
- `dotnet-exceptionless-domain-modeling`: owns expected business failures inside domain models and takes precedence for exceptionless domain behavior.
- `dotnet-rest-api-design`: owns HTTP semantics and status code choices.
- `dotnet-api-contracts`: owns JSON contract shape, naming, null omission, and payload compatibility.
- `dotnet-security-baseline`: owns sensitive data exposure rules.
- `dotnet-observability`: owns detailed logging, tracing, metrics, and correlation implementation when available.

When responsibilities overlap, use this skill as the general policy for classifying failures, choosing Result versus exception, capturing external exceptions, and mapping failures safely across layers.

Do not use this skill as the primary guide for detailed domain modeling, route design, full security configuration, detailed observability architecture, or EF Core persistence. Use the specialized skill for those concerns.

## Core Principles

- **Exceptionless First**: Represent expected failures with explicit structures such as `Result`, `Result<T>`, `ValidationResult`, `OperationResult`, `Notification`, or `Error`.
- **Exceptions Are Exceptional**: Reserve exceptions for unexpected situations, technical failures, bugs, impossible states, and unmapped infrastructure faults.
- **Explicit Business Failures**: Model business errors with stable codes, safe messages, and predictable types.
- **Fail Close To Source**: Capture known external failures near the external boundary and convert them to safe project errors.
- **Safe Error Exposure**: Never expose stack traces, SDK details, connection strings, SQL, secrets, tokens, credentials, or unnecessary personal data.
- **Observable Failures**: Preserve enough safe context for logs, metrics, traces, and correlation ids.

## Failure Classification

Classify the failure before coding:

| Failure kind | Examples | Preferred representation |
| --- | --- | --- |
| Expected business failure | inactive customer, empty order, insufficient stock, forbidden state transition | `Result.Failure(DomainErrors.Order.MustContainItems)` |
| Validation failure | missing required field, invalid format, invalid enum, malformed date, max length exceeded | `ValidationResult.Invalid(errors)` or project equivalent |
| Expected technical failure | external 404/409, timeout, rate limit, unavailable external resource | Capture near the source and convert to `Result`/`Error` |
| Unexpected failure | bug, `NullReferenceException`, corrupt state, unmapped infrastructure exception | Let the global exception pipeline handle it |

Avoid using exceptions, `null`, or ambiguous booleans to communicate failures that consumers can reasonably handle.

## Decision Checklist

Before creating or changing error handling, answer:

1. Is this failure expected?
2. Does it belong to the domain?
3. Can the caller react to it?
4. Does this project use exceptionless flows?
5. Does the failure come from an external source?
6. Can the exception be captured close to that source?
7. Must the error be exposed to a client?
8. Could the error contain sensitive data?
9. Should it be logged as warning or error?
10. Which HTTP status best represents the failure?

## Result Pattern

Prefer the project-standard result abstraction. Keep it simple; do not add a complex error framework unless the project already has one.

```csharp
public sealed record Error(
    string Code,
    string Message,
    ErrorType Type,
    string? Target = null);

public enum ErrorType
{
    Validation,
    BusinessRule,
    NotFound,
    Conflict,
    Unauthorized,
    Forbidden,
    ExternalFailure,
    Unexpected
}

public class Result
{
    public bool IsSuccess { get; }
    public bool IsFailure => !IsSuccess;
    public IReadOnlyList<Error> Errors { get; }
}
```

Prefer:

```csharp
return Result.Failure<Order>(DomainErrors.Order.NotFound);
```

Avoid:

```csharp
return null;
return false;
throw new InvalidOperationException("Order not found.");
```

## Domain Errors

Centralize domain errors with stable codes and safe messages. Keep them independent from HTTP, persistence, SDKs, and UI concerns.

```csharp
public static class DomainErrors
{
    public static class Order
    {
        public static readonly Error MustContainItems =
            new(
                "order.must_contain_items",
                "Order must contain at least one item.",
                ErrorType.BusinessRule,
                "items");
    }
}
```

Rules:

- Use stable codes suitable for clients, logs, and tests.
- Include an error type.
- Include a target when it helps the caller locate the problem.
- Keep messages clear and safe.
- Do not include internal identifiers, SQL, secrets, tokens, stack traces, or SDK payloads.

## Validation

Return validation failures explicitly. Do not throw one exception per invalid field in exceptionless projects.

```csharp
public sealed record ValidationError(
    string Code,
    string Message,
    string PropertyName);

public sealed class ValidationResult
{
    public bool IsValid => Errors.Count == 0;
    public IReadOnlyList<ValidationError> Errors { get; }
}
```

Prefer:

```csharp
return ValidationResult.Invalid([
    new("order.customer_id.required", "Customer id is required.", "customerId")
]);
```

Avoid:

```csharp
throw new Exception("Invalid payload.");
```

## DomainException

Prefer exceptionless domain failures. Use `DomainException` only in projects or modules whose architecture explicitly accepts domain exceptions for expected business failures.

Acceptable for exception-based legacy projects:

```csharp
public sealed class DomainException : Exception
{
    public string Code { get; }
    public string? Target { get; }

    public DomainException(string code, string message, string? target = null)
        : base(message)
    {
        Code = code;
        Target = target;
    }
}
```

Alternative for multiple errors:

```csharp
public sealed class DomainException : Exception
{
    public IReadOnlyList<Error> Errors { get; }

    public DomainException(IReadOnlyList<Error> errors)
        : base("A domain error occurred.")
    {
        Errors = errors;
    }
}
```

Use:

```csharp
throw new DomainException(
    "order.must_contain_items",
    "Order must contain at least one item.",
    "items");
```

Do not use `DomainException` for exceptionless business flow, technical failures, infrastructure errors, timeouts, external HTTP errors, bugs, validations that can return `ValidationResult`, or scenarios where the caller needs to react without `try`/`catch`.

Never create `DomainException` in a module where `dotnet-exceptionless-domain-modeling` is the active standard.

## External Exceptions

When an external dependency throws predictable exceptions, catch specific exceptions at the closest infrastructure boundary and convert them to safe errors.

```csharp
public sealed class PaymentGatewayClient : IPaymentGatewayClient
{
    public async Task<Result<PaymentResponse>> AuthorizeAsync(
        PaymentRequest request,
        CancellationToken cancellationToken)
    {
        try
        {
            var response = await _client.AuthorizeAsync(request, cancellationToken);
            return Result.Success(response);
        }
        catch (TimeoutException ex)
        {
            _logger.LogWarning(
                ex,
                "Payment gateway timeout for correlation {CorrelationId}",
                _correlationIdAccessor.CorrelationId);

            return Result.Failure<PaymentResponse>(
                ExternalErrors.PaymentGateway.Timeout);
        }
        catch (ExternalPaymentException ex)
        {
            _logger.LogWarning(
                ex,
                "Payment gateway unavailable for correlation {CorrelationId}",
                _correlationIdAccessor.CorrelationId);

            return Result.Failure<PaymentResponse>(
                ExternalErrors.PaymentGateway.Unavailable);
        }
    }
}
```

Prefer this layer flow:

```text
Infrastructure client -> captures external exception -> returns Result/Error
Application -> handles Result/Error
Presentation -> maps Result/Error to HTTP
```

Avoid this layer flow:

```text
Infrastructure client -> leaks SDK exception
Application -> depends on SDK exception type
Presentation -> performs dependency-specific try/catch
```

Rules:

- Catch specific exceptions when the failure is known and actionable.
- Convert known external failures to explicit project errors.
- Log with safe context and correlation id.
- Do not force Application or Presentation to know SDK exception types.
- Let unexpected exceptions bubble to the global exception handler unless this boundary can add useful context or cleanup.
- Do not use silent generic catches.

## Global Exception Handling

Every API must have one global path for unexpected failures, such as ASP.NET Core middleware, `IExceptionHandler`, or the project-standard equivalent.

The global handler must:

- Capture unhandled exceptions.
- Log unexpected failures as errors.
- Include correlation id when available.
- Return a safe response.
- Avoid stack traces and internal details in production.
- Map known domain exceptions only when the project uses exception-based domain failures.

Example:

```csharp
public sealed class GlobalExceptionHandler : IExceptionHandler
{
    public async ValueTask<bool> TryHandleAsync(
        HttpContext httpContext,
        Exception exception,
        CancellationToken cancellationToken)
    {
        var correlationId = httpContext.TraceIdentifier;

        _logger.LogError(
            exception,
            "Unhandled exception for correlation {CorrelationId}",
            correlationId);

        var problem = new ProblemDetails
        {
            Title = "An unexpected error occurred.",
            Status = StatusCodes.Status500InternalServerError,
            Detail = "The request could not be completed.",
            Instance = httpContext.Request.Path
        };

        problem.Extensions["correlationId"] = correlationId;

        httpContext.Response.StatusCode = problem.Status.Value;
        await httpContext.Response.WriteAsJsonAsync(problem, cancellationToken);
        return true;
    }
}
```

## HTTP Mapping

Map errors to HTTP in the Presentation layer. Follow the project's REST skill if it defines more specific status code rules.

| Error type | HTTP status |
| --- | --- |
| `Validation` | `400 Bad Request` |
| `BusinessRule` | `422 Unprocessable Entity` |
| `NotFound` | `404 Not Found` |
| `Conflict` | `409 Conflict` |
| `Unauthorized` | `401 Unauthorized` |
| `Forbidden` | `403 Forbidden` |
| `ExternalFailure` | `502 Bad Gateway`, `503 Service Unavailable`, or `504 Gateway Timeout` |
| `Unexpected` | `500 Internal Server Error` |

Do not return HTTP 200 for real errors. Do not map every failure to 500.

Example mapper:

```csharp
public static IResult ToHttpResult(this Result result)
{
    if (result.IsSuccess)
        return Results.NoContent();

    var status = result.Errors.First().Type switch
    {
        ErrorType.Validation => StatusCodes.Status400BadRequest,
        ErrorType.BusinessRule => StatusCodes.Status422UnprocessableEntity,
        ErrorType.NotFound => StatusCodes.Status404NotFound,
        ErrorType.Conflict => StatusCodes.Status409Conflict,
        ErrorType.Unauthorized => StatusCodes.Status401Unauthorized,
        ErrorType.Forbidden => StatusCodes.Status403Forbidden,
        ErrorType.ExternalFailure => StatusCodes.Status503ServiceUnavailable,
        _ => StatusCodes.Status500InternalServerError
    };

    return Results.Problem(result.Errors.ToProblemDetails(status));
}
```

## ProblemDetails

Prefer `ProblemDetails` or the project-standard equivalent for HTTP errors. Keep JSON shape aligned with `dotnet-api-contracts`.

```json
{
  "type": "https://httpstatuses.com/422",
  "title": "Business rule violation",
  "status": 422,
  "detail": "Order must contain at least one item.",
  "errors": [
    {
      "code": "order.must_contain_items",
      "message": "Order must contain at least one item.",
      "target": "items"
    }
  ],
  "correlationId": "00-7f6c..."
}
```

Expose only client-safe error data. Internal exception messages are not client contracts.

## Logging

Log failures according to severity and usefulness:

- Expected business failure: usually no `LogError`; often no log or a low-cardinality informational event.
- Known external failure: usually `LogWarning` with safe context.
- Unexpected failure: `LogError` with exception and correlation id.

Logs should include:

- Correlation id or trace id.
- Error type and stable code when available.
- Safe technical context needed for diagnostics.
- No secrets, tokens, passwords, credentials, connection strings, unnecessary payloads, or sensitive personal data.

Prefer:

```csharp
_logger.LogWarning(
    ex,
    "External inventory service timeout for order {OrderId} and correlation {CorrelationId}",
    orderId,
    correlationId);
```

Avoid:

```csharp
_logger.LogError(ex, "Payment failed with request {Request}", paymentRequest);
```

## Analysis Workflow

When reviewing existing code:

1. Map thrown exceptions and where they cross layer boundaries.
2. Identify `DomainException` usage and whether it fits the project policy.
3. Identify existing `Result`, `Result<T>`, `ValidationResult`, or equivalent.
4. Find expected failures implemented as `throw`.
5. Find `null` used as failure.
6. Find ambiguous `bool` failure returns.
7. Find generic or silent `try`/`catch`.
8. Find external SDK exceptions leaking from Infrastructure.
9. Check for global exception handling.
10. Check for inconsistent HTTP error responses.
11. Check logs for sensitive data exposure.
12. Propose prioritized corrections by risk and blast radius.

When creating new code:

1. Classify the failure.
2. Use Result Pattern for expected failures.
3. Use Domain Errors for business rules.
4. Avoid exceptions for expected flow.
5. Capture known external exceptions near the source.
6. Convert known external failures into explicit safe errors.
7. Propagate only safe errors across layers.
8. Map errors to HTTP in Presentation.
9. Log with safe context and correlation id.
10. Leave unexpected failures to the global handler.

## Prohibited Anti-Patterns

- Exception-driven business flow in exceptionless projects.
- Catching and ignoring exceptions.
- Throwing generic `Exception`.
- Leaking infrastructure or SDK exceptions into Application or Presentation.
- Using `null` to represent failure.
- Using `false` to represent rich failure.
- Logging sensitive data.
- Mapping every failure to 500.
- Returning HTTP 200 with an error payload for a real error.
- Exposing stack traces or internal exception details to clients.

## Completion Checklist

- [ ] Expected failures use `Result` or equivalent when possible.
- [ ] Exceptions are reserved for exceptional scenarios.
- [ ] `DomainException` is used only if the project accepts domain exceptions.
- [ ] Domain errors are explicit and centralized.
- [ ] Error codes are stable.
- [ ] `null` does not represent failure.
- [ ] `bool` does not represent rich failure.
- [ ] Known external exceptions are captured near the source.
- [ ] SDK exceptions do not leak into Application.
- [ ] Unexpected exceptions have global handling.
- [ ] HTTP errors are standardized.
- [ ] Stack traces do not leak in production.
- [ ] Logs avoid sensitive data.
- [ ] Correlation id is considered.
