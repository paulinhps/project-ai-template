---
name: dotnet-observability
description: Guide AI agents in creating, reviewing, and standardizing observability for .NET applications, APIs, workers, microservices, jobs, queue consumers, and distributed integrations, including structured logs, correlation ids, trace ids, metrics, health checks, distributed tracing, external-call instrumentation, messaging telemetry, safe logging, production diagnostics, and troubleshooting. Use when creating APIs, workers, microservices, integrations, consumers, jobs, logs, health checks, production reviews, failure diagnostics, or traceability improvements.
---

# Dotnet Observability

Use this skill to make .NET systems diagnosable, traceable, and operable in production. Prefer the project's existing logging, telemetry, and hosting conventions; introduce new observability libraries only when the codebase has no clear standard.

## Related Skills

Coordinate with these skills when they exist:

- `dotnet-clean-architecture`: owns layer boundaries and dependency direction.
- `dotnet-rest-api-design`: owns HTTP semantics, endpoint design, and API behavior.
- `dotnet-api-contracts`: owns JSON contracts and safe response shape.
- `dotnet-security-baseline`: owns sensitive-data protection and safe logging constraints.
- `dotnet-error-handling`: owns failure classification, exception policy, and error responses.
- `dotnet-microservices-patterns`: owns distributed-system boundaries, messaging, resilience, and integration patterns.

When responsibilities overlap, use this skill for logs, metrics, traces, correlation, health checks, and troubleshooting signals.

## Required Principles

- **Observable by Default**: Every backend application must start with minimum production observability.
- **Structured Logs**: Use message templates and named properties, not interpolated strings.
- **Correlation Everywhere**: Every relevant operation must carry a correlation id.
- **Trace Distributed Operations**: Distributed flows must be traceable end to end.
- **No Sensitive Logging**: Never log secrets, credentials, tokens, unnecessary personal data, or sensitive payloads.
- **Actionable Telemetry**: Telemetry must help real diagnosis with tolerable cost and low operational noise.

## Decision Checklist

Before adding logs, metrics, or traces, answer:

1. Does this telemetry help real diagnosis?
2. Is every logged value safe?
3. Is cardinality bounded and low enough?
4. Is the log level correct?
5. Is correlation id present?
6. Is this a distributed operation that needs trace propagation?
7. Is the failure expected or unexpected?
8. Could this create excessive noise?
9. Is the metric actionable?
10. Is the telemetry cost acceptable?

## Structured Logs

Use structured message templates with stable property names.

Prefer:

```csharp
_logger.LogInformation(
    "Order {OrderId} created for customer {CustomerId}",
    orderId,
    customerId);
```

Avoid:

```csharp
_logger.LogInformation(
    $"Order {orderId} created for customer {customerId}");
```

Rules:

- Use message templates.
- Include relevant context: operation, entity id, dependency, status, duration, attempt, and correlation id when useful.
- Avoid full payloads unless explicitly safe, small, and necessary.
- Avoid generic logs such as `"Something failed"` or `"Processing item"`.
- Prefer stable low-cardinality properties over dynamic property names.
- Distinguish technical logs from business-event logs.

## Log Levels

Use levels consistently:

| Level | Use for |
| --- | --- |
| `Trace` | Very granular details, usually disabled in production. |
| `Debug` | Development and focused diagnostic information. |
| `Information` | Relevant normal-flow events and important business milestones. |
| `Warning` | Expected degradation, retries, recoverable timeouts, known external failures, and suspicious conditions. |
| `Error` | Unexpected failures or operations that could not be completed. |
| `Critical` | Severe failures that compromise system availability, safety, or data integrity. |

Expected business failures must not be logged as systemic `Error`.

## Correlation ID

Every request or distributed operation must have a correlation id.

Recommended HTTP header:

```text
X-Correlation-Id
```

Apply correlation id to:

- HTTP APIs.
- Workers and jobs.
- Queue consumers and message publishers.
- Integration events.
- External HTTP, gRPC, webhook, and SDK calls.
- Logs, traces, and error responses when safe.

Rules:

- Accept an incoming correlation id when present and valid.
- Generate a new id when absent.
- Return the correlation id in API responses when useful.
- Propagate it to external calls and messages.
- Include it in logging scopes or enrichers.
- Do not use sensitive identifiers such as tokens, documents, or account numbers as correlation ids.

Example middleware:

```csharp
public sealed class CorrelationIdMiddleware
{
    private const string HeaderName = "X-Correlation-Id";
    private readonly RequestDelegate _next;
    private readonly ILogger<CorrelationIdMiddleware> _logger;

    public CorrelationIdMiddleware(
        RequestDelegate next,
        ILogger<CorrelationIdMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var correlationId = context.Request.Headers.TryGetValue(HeaderName, out var value)
            && !StringValues.IsNullOrEmpty(value)
                ? value.ToString()
                : Guid.NewGuid().ToString("N");

        context.Response.Headers[HeaderName] = correlationId;

        using (_logger.BeginScope(new Dictionary<string, object>
        {
            ["CorrelationId"] = correlationId
        }))
        {
            await _next(context);
        }
    }
}
```

Register early in the pipeline:

```csharp
app.UseMiddleware<CorrelationIdMiddleware>();
```

Example propagation with `HttpClient`:

```csharp
public sealed class CorrelationIdHandler : DelegatingHandler
{
    private const string HeaderName = "X-Correlation-Id";
    private readonly ICorrelationIdAccessor _accessor;

    public CorrelationIdHandler(ICorrelationIdAccessor accessor)
    {
        _accessor = accessor;
    }

    protected override Task<HttpResponseMessage> SendAsync(
        HttpRequestMessage request,
        CancellationToken cancellationToken)
    {
        if (!request.Headers.Contains(HeaderName)
            && !string.IsNullOrWhiteSpace(_accessor.CorrelationId))
        {
            request.Headers.Add(HeaderName, _accessor.CorrelationId);
        }

        return base.SendAsync(request, cancellationToken);
    }
}
```

## Trace ID and Distributed Tracing

When OpenTelemetry or an equivalent tracing mechanism is used, preserve:

- `TraceId`
- `SpanId`
- `ParentId`
- W3C `traceparent` and `tracestate` when applicable

Correlation id can coexist with trace id. Use trace id for distributed trace topology and correlation id for business/request troubleshooting across systems and logs.

Instrument:

- Incoming HTTP requests.
- Outgoing HTTP or gRPC calls.
- Database operations.
- Messaging publish and consume flows.
- Cache operations.
- Jobs and background processing.
- External provider integrations.

Example scope:

```text
HTTP Request
|-- Application Use Case
|-- Database Query
|-- External API Call
`-- Message Publish
```

Example OpenTelemetry setup:

```csharp
builder.Services.AddOpenTelemetry()
    .WithTracing(tracing =>
    {
        tracing
            .AddAspNetCoreInstrumentation()
            .AddHttpClientInstrumentation()
            .AddEntityFrameworkCoreInstrumentation()
            .AddSource("Orders")
            .AddOtlpExporter();
    });
```

Use custom spans only where automatic instrumentation does not explain the operation well.

```csharp
private static readonly ActivitySource ActivitySource = new("Orders");

using var activity = ActivitySource.StartActivity("ProcessOrder");
activity?.SetTag("order.id", orderId);
activity?.SetTag("messaging.message_id", messageId);
```

Avoid sensitive tags and high-cardinality labels unless the tracing backend and retention policy explicitly support them.

## Metrics

Consider metrics for:

- Total requests.
- Latency and processing duration.
- Error rate.
- Throughput.
- Queue size, lag, retries, and dead letters.
- Resource usage.
- External dependency latency and failure rate.
- Critical business operations.

Metric names must be clear. Labels must be low-cardinality. Do not use unique ids such as `OrderId`, `UserId`, `MessageId`, `Email`, or `CorrelationId` as metric labels.

Example:

```csharp
private static readonly Meter Meter = new("Orders");
private static readonly Counter<long> OrdersCreated =
    Meter.CreateCounter<long>("orders.created");

private static readonly Histogram<double> OrderProcessingDuration =
    Meter.CreateHistogram<double>("orders.processing.duration", "ms");

OrdersCreated.Add(1, new KeyValuePair<string, object?>("channel", "api"));

var elapsedMs = stopwatch.Elapsed.TotalMilliseconds;
OrderProcessingDuration.Record(elapsedMs);
```

Prefer metrics that support alerts or operational decisions.

## Health Checks

Every backend application should consider health checks. Separate endpoints when the platform supports it:

- **Liveness**: The process is alive.
- **Readiness**: The application is ready to receive traffic.
- **Dependency checks**: Critical dependencies are usable enough for this service.

Check critical dependencies such as:

- Database.
- Cache.
- Queue or broker.
- Critical external APIs.
- Storage.

Example:

```csharp
builder.Services
    .AddHealthChecks()
    .AddSqlServer(
        builder.Configuration.GetConnectionString("OrdersDatabase")!,
        name: "orders-database")
    .AddRedis(
        builder.Configuration.GetConnectionString("Redis")!,
        name: "redis");

app.MapHealthChecks("/health/live");
app.MapHealthChecks("/health/ready");
```

Avoid fake health checks that always return `OK` and validate nothing relevant.

## Safe Logging

Never log:

- Passwords.
- Tokens.
- Authorization headers.
- Cookies.
- API keys.
- Connection strings.
- Bank data.
- Unnecessary personal data.
- Full sensitive payloads.
- Personal documents.
- Children's data.

When a value is necessary for diagnosis and safe to expose partially, mask it.

```csharp
_logger.LogInformation(
    "Payment provider request failed for order {OrderId} and card ending {CardLast4}",
    orderId,
    cardLast4);
```

Avoid:

```csharp
_logger.LogError(
    "Payment provider request failed with payload {Payload}",
    paymentRequest);
```

## Business Logs

Business events can be logged when they help auditability, operations, or diagnosis.

```csharp
_logger.LogInformation(
    "Payment approved for order {OrderId}",
    orderId);
```

Rules:

- Do not use logs as state persistence.
- Do not make business rules depend on logs.
- Do not log sensitive business data unless explicitly safe and required.
- Prefer domain events, integration events, audit tables, or outbox records for durable business history.

## Exception Logs

Unexpected exceptions should be logged with safe context.

```csharp
_logger.LogError(
    exception,
    "Unexpected error while processing order {OrderId}",
    orderId);
```

Expected failures should follow the project's failure pattern:

- Expected business failures: often no log, `Information`, or `Warning` depending on operational value.
- Known external failures: usually `Warning` near the external boundary.
- Unexpected failures: `Error` in the global exception pipeline or where context is added.

Do not catch and swallow exceptions silently.

## Exceptionless and Result Pattern

When the project uses `Result`, `Result<T>`, `ValidationResult`, notifications, or another exceptionless pattern:

- Log common domain failures as `Information` or `Warning` only when they provide operational value.
- Do not pollute logs with `Error` for normal business decisions.
- Log known external failures close to the infrastructure boundary.
- Let unexpected errors flow to the global exception pipeline.
- Include stable error codes in logs when safe and useful.

```csharp
if (result.IsFailure)
{
    _logger.LogInformation(
        "Order creation rejected with error {ErrorCode}",
        result.Errors[0].Code);

    return result;
}
```

## APIs

APIs should record:

- Correlation id.
- HTTP method.
- Path template or route name.
- Status code.
- Duration.
- User, tenant, or client id when safe.
- Unexpected errors.

Do not log request or response bodies by default.

Prefer route templates over raw paths when available to reduce cardinality:

```csharp
_logger.LogInformation(
    "HTTP {Method} {Route} responded {StatusCode} in {ElapsedMs} ms",
    method,
    route,
    statusCode,
    elapsedMs);
```

## Workers and Jobs

Workers should record:

- Processing start and finish.
- Total duration.
- Job id or message id.
- Correlation id.
- Attempt number.
- Result.
- Retries and final failures.

Example:

```csharp
_logger.LogInformation(
    "Starting job {JobName} with execution {ExecutionId}",
    jobName,
    executionId);

try
{
    await processor.ProcessAsync(cancellationToken);

    _logger.LogInformation(
        "Completed job {JobName} with execution {ExecutionId} in {ElapsedMs} ms",
        jobName,
        executionId,
        stopwatch.ElapsedMilliseconds);
}
catch (Exception ex)
{
    _logger.LogError(
        ex,
        "Job {JobName} with execution {ExecutionId} failed after {ElapsedMs} ms",
        jobName,
        executionId,
        stopwatch.ElapsedMilliseconds);

    throw;
}
```

## Messaging

Messages should carry:

- Correlation id.
- Message id.
- Causation id when applicable.
- Timestamp.
- Event type.
- Event version.

Consumers should log:

- Message received.
- Processing completed.
- Retry.
- Dead letter.
- Unexpected failure.

Example:

```csharp
using (_logger.BeginScope(new Dictionary<string, object>
{
    ["CorrelationId"] = message.CorrelationId,
    ["MessageId"] = message.MessageId,
    ["EventType"] = message.EventType
}))
{
    _logger.LogInformation(
        "Processing message {MessageId} of type {EventType}",
        message.MessageId,
        message.EventType);

    await handler.HandleAsync(message, cancellationToken);

    _logger.LogInformation(
        "Processed message {MessageId} of type {EventType}",
        message.MessageId,
        message.EventType);
}
```

When retrying or dead-lettering, include attempt count, reason category, and safe error code.

## External Integrations

External clients should record:

- Provider name.
- Operation.
- Duration.
- Status code or result category.
- Timeout.
- Retry count.
- Known failure type.
- Correlation id.

Example:

```csharp
try
{
    var response = await _httpClient.SendAsync(request, cancellationToken);

    _logger.LogInformation(
        "External provider {Provider} operation {Operation} returned {StatusCode} in {ElapsedMs} ms",
        "PaymentGateway",
        "AuthorizePayment",
        (int)response.StatusCode,
        stopwatch.ElapsedMilliseconds);

    return response;
}
catch (TaskCanceledException ex) when (!cancellationToken.IsCancellationRequested)
{
    _logger.LogWarning(
        ex,
        "External provider {Provider} operation {Operation} timed out after {ElapsedMs} ms",
        "PaymentGateway",
        "AuthorizePayment",
        stopwatch.ElapsedMilliseconds);

    throw;
}
```

Do not log sensitive payloads, raw tokens, authorization headers, or full provider responses by default.

## Database Observability

Consider:

- Query duration.
- Connection failures.
- Timeouts.
- Deadlocks.
- Slow critical queries.
- Number of records processed when safe.

Prefer standard EF Core, database driver, or OpenTelemetry instrumentation before custom query logs. Do not log SQL statements with sensitive parameters.

## Alerts

Consider alerts for:

- 5xx error increase.
- High latency.
- Critical dependency failure.
- Dead letters.
- Jobs failing repeatedly.
- Excessive resource consumption.
- Recurring timeouts.
- Abnormal authentication failures.

Alerts must be actionable, routed to an owner, and tuned to avoid fatigue.

## Dashboards

Dashboards should cover:

- Overall health.
- Latency.
- Throughput.
- Error rate.
- External dependencies.
- Queues and dead letters.
- Jobs and background processing.
- Critical business metrics.

Dashboards should help answer: "Is the system healthy?", "What changed?", "Where is the failure?", and "Who is affected?"

## Correct and Incorrect Cases

Correct:

```csharp
_logger.LogWarning(
    ex,
    "Inventory service timeout while reserving stock for order {OrderId}",
    orderId);
```

Incorrect:

```csharp
_logger.LogError(
    $"Inventory timeout for request {JsonSerializer.Serialize(request)}: {ex}");
```

Correct:

```csharp
_logger.LogInformation(
    "Consumer dead-lettered message {MessageId} of type {EventType} after {AttemptCount} attempts",
    messageId,
    eventType,
    attemptCount);
```

Incorrect:

```csharp
_logger.LogInformation("DLQ");
```

## Review Workflow

When analyzing existing observability:

1. Map logs by application area and severity.
2. Verify structured logging and message templates.
3. Identify string interpolation and concatenation in logs.
4. Verify correlation id generation and propagation.
5. Verify trace context propagation between services.
6. Check for sensitive data in logs, tags, metrics, and errors.
7. Identify incorrect log levels.
8. Review liveness, readiness, and dependency health checks.
9. Review metrics and cardinality.
10. Review tracing coverage for HTTP, database, messaging, cache, and external calls.
11. Review observability of integrations, workers, consumers, jobs, and retries.
12. Suggest prioritized improvements by production risk and implementation scope.

## Creation Workflow

When generating new code:

1. Add logs only where they provide operational value.
2. Use structured logging.
3. Include or preserve correlation id when applicable.
4. Propagate correlation id to dependencies and messages.
5. Avoid sensitive data.
6. Choose the correct log level.
7. Instrument external calls and messaging.
8. Consider metrics for latency, throughput, errors, retries, and business-critical operations.
9. Consider tracing for distributed operations.
10. Consider health checks for process and dependencies.

## Prohibited Anti-Patterns

- **String Interpolation Logging**: `_logger.LogInformation($"Order {orderId} created");`
- **Sensitive Logging**: Logging tokens, passwords, documents, secrets, or sensitive payloads.
- **Log Everything**: Excessive logs without diagnostic value.
- **No Correlation ID**: Distributed operations without correlation.
- **Error for Business Rule**: Expected business failure logged as systemic `Error`.
- **Swallowed Exception**: Capturing exceptions without log, context, rethrow, or useful action.
- **Health Check Fake**: Health check that always returns `OK`.
- **High Cardinality Metrics**: Metrics labeled with unique ids.
- **Body Logging by Default**: Logging full request or response bodies without explicit need and safeguards.

## Completion Checklist

- [ ] Logs are structured.
- [ ] Logs do not use string interpolation.
- [ ] Correlation id was considered.
- [ ] Correlation id is propagated.
- [ ] Sensitive data is not logged.
- [ ] Log levels are correct.
- [ ] Health checks were considered.
- [ ] Liveness and readiness were evaluated.
- [ ] Metrics were considered.
- [ ] Distributed tracing was considered.
- [ ] External integrations are observable.
- [ ] Workers and consumers are observable.
- [ ] Expected failures do not pollute logs as systemic errors.
- [ ] Unexpected failures are logged with safe context.
