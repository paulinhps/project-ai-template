---
name: dotnet-security-baseline
description: Guide AI agents in applying a minimum security baseline for .NET backend applications, REST APIs, workers, and microservices, including authentication, authorization, input validation, sensitive data protection, secure logging, safe error handling, CORS, rate limiting, SQL injection prevention, file upload safety, webhook validation, secrets handling, and Clean Architecture security boundaries. Use when creating, reviewing, or evolving ASP.NET Core APIs, Minimal APIs, controllers, background workers, integration endpoints, externally exposed services, or any .NET feature that accepts external input, exposes data, uses identities, stores secrets, logs requests, or handles errors.
---

# Dotnet Security Baseline

Use this skill to make .NET backend features secure by default. Apply it when adding new endpoints, reviewing existing code, changing authentication or authorization, handling external input, logging, returning errors, storing secrets, uploading files, processing webhooks, or exposing APIs and workers to external systems.

## Related Skills

Apply these skills when they exist in the project:

- `dotnet-clean-architecture`: owns layer separation, dependency direction, and boundary placement.
- `dotnet-rest-api-design`: owns HTTP semantics, status codes, routes, and REST endpoint shape.
- `dotnet-api-contracts`: owns DTO shape, JSON contracts, and response payload compatibility.
- `dotnet-error-handling`: owns project-wide error taxonomy and error response format.
- `dotnet-observability`: owns tracing, metrics, correlation, and operational telemetry.

When responsibilities conflict, this skill owns security requirements and risk reduction. Do not weaken authentication, authorization, validation, logging safety, or sensitive data protection to simplify another concern.

## Core Principles

- **Secure by default**: every feature starts from the safest reasonable behavior.
- **Least privilege**: grant only the permissions required for the action.
- **Defense in depth**: protect at multiple layers instead of relying on one control.
- **Never trust external input**: validate all data from outside the trusted boundary.
- **No sensitive data leakage**: never expose secrets or sensitive data in responses, logs, or exceptions.
- **Explicit authorization**: protected actions must declare their authorization requirements.

Treat public access as a deliberate product decision, not a convenient default.

## Security Workflow

Before creating or changing .NET backend code:

1. Decide whether the endpoint, worker input, webhook, or operation is public or protected.
2. Apply authentication for protected resources.
3. Apply explicit authorization close to the entry point and, when needed, in Application use cases.
4. Create request DTOs that include only client-controllable fields.
5. Validate every external input source.
6. Prevent sensitive data from appearing in responses, logs, traces, and error details.
7. Use safe error handling and production-safe diagnostics.
8. Check secrets, CORS, HTTPS, rate limiting, SQL construction, file upload handling, and webhook verification.
9. Keep security concerns in the correct Clean Architecture layer.
10. Report remaining risks clearly, with severity and prioritized remediation.

## Authentication

Use established authentication mechanisms when any resource is protected:

- JWT Bearer.
- OAuth2.
- OpenID Connect.
- API keys only for controlled service integrations.
- mTLS when the deployment and integration model require it.

Do:

- Use official ASP.NET Core authentication middleware when possible.
- Configure token issuer, audience, lifetime, signing keys, and clock skew deliberately.
- Store passwords only with appropriate password hashing.
- Keep tokens, client secrets, certificates, and private keys outside source code.

Do not:

- Create custom authentication unless there is a documented need.
- Parse or validate JWTs manually when middleware can do it.
- Trust identity data sent only in body, query string, or arbitrary headers.
- Store passwords in plaintext.
- Implement custom cryptography.

## Authorization

Require authorization explicitly for protected resources. Prefer declarative authorization:

```csharp
[Authorize]
[Authorize(Policy = "CanReadOrders")]
[Authorize(Roles = "Admin")]
```

Use policies for complex rules. Use roles only for simple role-gated scenarios. Validate claims before use, including type, issuer, value shape, and whether the claim is trustworthy for the decision.

Never trust a `userId`, tenant id, role, permission, or ownership value from the client when it can be derived from the authenticated principal or verified server-side.

Avoid spreading authorization across unstructured `if` statements. When imperative checks are required, centralize them in policies, authorization handlers, or Application services with clear names and tests.

## Public Endpoints

Mark public endpoints intentionally. `AllowAnonymous` is acceptable only when public access is a deliberate requirement, such as health probes, public catalog reads, callback endpoints with signature validation, login, or password recovery.

For every public endpoint, consider:

- Rate limiting.
- Input validation.
- Abuse cases.
- Sensitive data exposure.
- CORS restrictions.
- Logging safety.
- Whether a webhook signature, API key, mTLS, or another trust mechanism is needed.

## External Input Validation

Validate every external input source:

- Body.
- Query string.
- Route parameters.
- Headers.
- Files.
- Webhooks.
- Queue messages.
- External events.

Validate:

- Required fields.
- Maximum length and collection size.
- Format.
- Numeric ranges.
- Allowed enum values.
- Dates and time zones.
- IDs and tenant boundaries.
- File size, extension, MIME type, and content when possible.
- `Content-Type`.

Reject invalid input with the project-standard validation error format. Do not allow invalid values to fall back to defaults that could change behavior.

## Mass Assignment

Use request DTOs that are specific to each use case. Never expose domain entities, EF entities, or administrative properties as public request models.

Avoid:

```csharp
public class User
{
    public bool IsAdmin { get; set; }
}
```

Prefer:

```csharp
public sealed record UpdateUserProfileRequest(
    string DisplayName,
    string? Phone);
```

Never accept properties the caller should not control, such as `IsAdmin`, `Role`, `TenantId`, `OwnerId`, `CreatedBy`, `Balance`, `Status`, or security flags unless the specific use case is authorized to modify them.

## Secrets

Never commit secrets. Secrets include:

- Connection strings.
- Tokens.
- API keys.
- Client secrets.
- Certificates.
- Passwords.
- Private keys.

Use Secret Manager for local development when appropriate. Use Key Vault, environment variables, or a production secret store in deployed environments.

Do not log secrets, return them in responses, include real secrets in docs or examples, or keep them in `appsettings.json` files that are committed.

## Secure Configuration

Check configuration by environment:

- Enable HTTPS.
- Enable HSTS in production.
- Restrict CORS.
- Use secure cookies when cookies are present.
- Remove or avoid sensitive response headers.
- Hide stack traces in production.
- Keep development diagnostics out of production.
- Make environment-specific settings explicit.

## CORS

Keep CORS restrictive. Avoid in production:

```csharp
AllowAnyOrigin()
AllowAnyHeader()
AllowAnyMethod()
```

Prefer explicit origins:

```csharp
WithOrigins("https://app.example.com")
```

Do not use wildcard origins in production. Do not combine wildcard origins with credentials. Document allowed origins and why they are needed.

## Rate Limiting

Consider rate limiting for:

- Public endpoints.
- Login.
- Password recovery.
- Webhooks.
- Expensive operations.
- APIs exposed outside the trust boundary.

Choose limits based on risk, user impact, and deployment topology. Ensure clients receive predictable responses, such as `429 Too Many Requests`, when limits are exceeded.

## Sensitive Data

Protect sensitive data, including:

- Passwords.
- Tokens.
- Personal documents.
- Financial data.
- Banking data.
- Emails.
- Phone numbers.
- Addresses.
- Medical data.
- Children's data.
- Integration keys.

Return only the data needed by the caller and use case. Mask or omit sensitive values when possible. Avoid exposing internal identifiers when they increase risk. Do not log full sensitive payloads.

## Secure Logging

Logs must not contain:

- Passwords.
- Tokens.
- `Authorization` headers.
- Cookies.
- Banking data.
- Unnecessary personal data.
- Full sensitive payloads.

Prefer structured logs with minimal technical context: correlation id, authenticated subject id when safe, tenant id when safe, operation name, outcome, duration, and stable error code. Redact or omit sensitive fields before logging.

## Safe Errors

Error responses must not expose:

- Stack traces.
- Server names.
- Connection strings.
- SQL.
- Internal paths.
- Table names.
- Infrastructure details.

In production, return the project-standard safe error format, such as `ProblemDetails`, with stable codes and messages that help clients recover without revealing internals.

## SQL Injection

Use parameterized queries. Use EF Core and Dapper correctly.

Do not concatenate external input into SQL:

```csharp
$"SELECT * FROM Users WHERE Name = '{name}'"
```

Validate dynamic sorting, filtering, selected columns, table names, and raw SQL fragments against allowlists. Treat query builders and search expressions as external input surfaces.

## File Uploads

When handling uploads, validate:

- Size.
- Extension.
- MIME type.
- Content when possible.
- Safe generated file name.
- Storage location.
- Antivirus or malware scanning when applicable.

Do not trust the submitted file name. Do not save files directly with user-provided names. Do not allow uploaded files to execute. Do not expose physical paths.

## Webhooks

Validate webhooks with:

- Signature verification.
- Origin checks when possible.
- Replay protection.
- Timestamp tolerance.
- Idempotency.
- Payload schema validation.

Do not trust only an IP allowlist. Treat webhook payloads as untrusted external input until verified.

## Cryptography And Hashing

Do not implement custom cryptography. Use established libraries and platform APIs.

Use appropriate password hashing. Give tokens expirations. Encrypt sensitive data when required by risk, regulation, or product policy. Keep encryption keys outside source code and rotate them through managed secret infrastructure.

## Clean Architecture Boundaries

Keep security concerns in the right layer:

- Presentation applies HTTP authentication and authorization attributes, middleware, filters, and endpoint metadata.
- Application may validate use-case permissions and ownership rules using abstractions.
- Domain does not depend on authenticated users, claims, HTTP, policies, or identity providers.
- Infrastructure contains external provider details, secret stores, token services, and concrete integrations.
- Policies, claims, roles, and HTTP details must not leak into Domain.

## Existing Code Review

When analyzing an existing project:

1. Map public and protected endpoints.
2. Verify authentication.
3. Verify explicit authorization.
4. Verify input validation.
5. Verify CORS.
6. Verify logging.
7. Search for secrets.
8. Search for sensitive data exposure.
9. Search for concatenated SQL.
10. Search for mass assignment.
11. Classify risks by severity.
12. Suggest prioritized fixes.

Lead review output with findings ordered by severity. Include file and line references when available.

## New Code Checklist

Before completing a change, verify:

- [ ] Protected endpoints require authentication.
- [ ] Authorization is explicit.
- [ ] External input is validated.
- [ ] Request DTOs prevent mass assignment.
- [ ] No secrets are hardcoded or committed.
- [ ] Logs omit sensitive data.
- [ ] Errors do not expose internal details.
- [ ] CORS is restricted for production.
- [ ] HTTPS and production diagnostics were considered.
- [ ] SQL uses parameters.
- [ ] DTOs do not expose sensitive properties.
- [ ] Claims are validated before use.
- [ ] Rate limiting was considered for exposed or costly endpoints.
- [ ] Production does not show stack traces.

## Prohibited Anti-Patterns

- `AllowAnonymous` for convenience.
- `AllowAnyOrigin` in production without justification.
- Secrets in source code.
- Logging tokens, cookies, credentials, or full sensitive payloads.
- Mass assignment through public request models.
- Security by frontend.
- Manual token parsing instead of validated middleware.
- Concatenated SQL with external input.
- Exposing internal entities or infrastructure models through API contracts.
- Ignoring authorization for protected resources.

Always prioritize explicit, predictable security controls that match the risk of the feature.
