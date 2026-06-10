---
name: dotnet-api-contracts
description: Guide AI agents in creating, reviewing, and evolving JSON API contracts in .NET applications, including request/response DTOs, System.Text.Json options, camelCase naming, null omission, enum serialization and flexible enum deserialization, lean payloads, ProblemDetails JSON shape, public contract compatibility, and avoiding domain or EF entity exposure. Use with ASP.NET Core APIs, Controllers, Minimal APIs, OpenAPI examples, DTO mapping, payload reviews, and API contract refactors.
---

# Dotnet API Contracts

Use this skill to define the JSON representation of .NET API contracts. It complements `dotnet-rest-api-design`, which owns REST behavior, routes, methods, and status codes; this skill owns JSON shape, DTO representation, serialization, deserialization, and payload consistency.

## Related Skills

Apply these skills when they exist in the project:

- `dotnet-rest-api-design`: owns REST behavior, HTTP semantics, routes, status codes, and API presentation behavior.
- `dotnet-error-handling`: owns project-wide error taxonomy and error pipeline.
- `dotnet-security-baseline`: owns sensitive-data, authentication, authorization, and API security requirements.

When responsibilities conflict, let `dotnet-rest-api-design` define REST behavior and this skill define JSON contract representation.

## Operating Mode

Before creating or changing a JSON contract, answer:

1. Is this property necessary in the response?
2. Should this null property be omitted?
3. Should this collection return `[]`?
4. Should this enum be serialized as a string?
5. Can enum input accept variations without ambiguity?
6. Does this change break existing consumers?
7. Does the contract expose internal, domain, EF, or sensitive details?
8. Is the JSON camelCase?
9. Is the contract consistent with related endpoints?

When reviewing existing contracts, map DTOs first, then inspect serializer options, null handling, enum format, enum input behavior, entity exposure, naming inconsistencies, excessive payloads, sensitive data exposure, and breaking-change risk. Report fixes in priority order.

## Required Defaults

Prefer these defaults for public JSON APIs:

- Use explicit API DTOs for requests and responses.
- Use `camelCase` JSON names.
- Omit null response properties when technically viable.
- Return empty collections as `[]`, not `null`.
- Serialize enums as strings.
- Accept valid enum input by number or case-insensitive name when the project supports flexible enum input.
- Reject invalid enum values with validation errors.
- Use ISO-8601 dates; prefer UTC for system events.
- Keep responses lean without hiding necessary meaning.
- Never expose domain entities, EF entities, infrastructure models, secrets, stack traces, or internal identifiers that consumers should not know.

Prefer:

```json
{
  "id": 1,
  "name": "Paulo"
}
```

Avoid:

```json
{
  "id": 1,
  "name": "Paulo",
  "email": null,
  "phone": null,
  "address": null
}
```

## System.Text.Json

When a project uses `System.Text.Json`, recommend a centralized configuration unless the project already has an equivalent standard:

```csharp
using System.Text.Json;
using System.Text.Json.Serialization;

builder.Services
    .AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
        options.JsonSerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull;
        options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter());
    });
```

For Minimal APIs using `Microsoft.AspNetCore.Http.Json`:

```csharp
builder.Services.ConfigureHttpJsonOptions(options =>
{
    options.SerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
    options.SerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull;
    options.SerializerOptions.Converters.Add(new JsonStringEnumConverter());
});
```

If the API must accept enum input as `1`, `"first"`, `"FIRST"`, and `"First"`, propose a custom enum converter. Do not silently coerce invalid values to the enum default.

## DTO Rules

Create API-specific DTOs. Do not return domain entities or EF entities directly.

Common names:

```text
CreateCustomerRequest
UpdateCustomerRequest
CustomerResponse
CustomerSummaryResponse
PagedResponse<T>
ErrorResponse
```

Rules:

- Prefer `record` for immutable DTOs when it matches project style.
- Keep DTOs behavior-free; no business rules.
- Keep request DTOs tolerant only where that does not create ambiguity.
- Allow nullable request properties only when the input is optional or partial.
- Make response DTOs explicit and stable.
- Use public API language, not domain implementation language.
- Avoid over-generic DTOs that blur a specific use case.

Example:

```csharp
public sealed record CreateCustomerRequest(
    string Name,
    string? Email,
    CustomerType Type);

public sealed record CustomerResponse(
    Guid Id,
    string Name,
    string Type,
    string? Email,
    DateTimeOffset CreatedAt);
```

With null omission, a customer without email serializes as:

```json
{
  "id": "00000000-0000-0000-0000-000000000000",
  "name": "Paulo",
  "type": "Individual",
  "createdAt": "2026-06-10T15:30:00Z"
}
```

## Naming and Payload Shape

JSON contracts must use `camelCase`:

```json
{
  "customerId": "123",
  "createdAt": "2026-06-10T15:30:00Z"
}
```

Avoid PascalCase or mixed naming:

```json
{
  "CustomerId": "123",
  "created_at": "2026-06-10T15:30:00Z"
}
```

For collections:

- Use `[]` for an empty list.
- Use `null` only for genuine absence of a value.
- Do not omit primary collections in paged responses.

Prefer:

```json
{
  "items": []
}
```

Avoid:

```json
{
  "items": null
}
```

## Enum Contracts

Serialize enums as strings by default:

```csharp
public enum EMyEnum
{
    FIRST = 1,
    SECOND = 2
}
```

Prefer:

```json
{
  "enumValue": "FIRST"
}
```

Avoid:

```json
{
  "enumValue": 1
}
```

For requests, accept multiple valid representations when technically viable:

```json
{
  "enumA": 1,
  "enumB": "first",
  "enumC": "FIRST",
  "enumD": "First"
}
```

Each value must deserialize to `EMyEnum.FIRST`. Reject missing members, out-of-range numbers, incompatible token types, and unknown names.

## Flexible Enum Converter

Use a custom converter when the built-in enum converter does not match the required input tolerance or validation behavior. The converter must:

- Read string and number tokens.
- Treat strings as case-insensitive enum names.
- Validate numbers with `Enum.IsDefined`.
- Validate parsed strings with `Enum.IsDefined`.
- Throw `JsonException` with a clear message for invalid values.
- Never convert invalid values to default.

Example converter:

```csharp
using System.Text.Json;
using System.Text.Json.Serialization;

public sealed class FlexibleEnumJsonConverter<TEnum> : JsonConverter<TEnum>
    where TEnum : struct, Enum
{
    public override TEnum Read(
        ref Utf8JsonReader reader,
        Type typeToConvert,
        JsonSerializerOptions options)
    {
        if (reader.TokenType == JsonTokenType.Number &&
            reader.TryGetInt64(out var number))
        {
            var value = (TEnum)Enum.ToObject(typeof(TEnum), number);

            if (Enum.IsDefined(typeof(TEnum), value))
            {
                return value;
            }
        }

        if (reader.TokenType == JsonTokenType.String)
        {
            var text = reader.GetString();

            if (!string.IsNullOrWhiteSpace(text) &&
                Enum.TryParse<TEnum>(text, ignoreCase: true, out var value) &&
                Enum.IsDefined(typeof(TEnum), value))
            {
                return value;
            }
        }

        throw new JsonException($"The value is not valid for {typeof(TEnum).Name}.");
    }

    public override void Write(
        Utf8JsonWriter writer,
        TEnum value,
        JsonSerializerOptions options)
    {
        writer.WriteStringValue(value.ToString());
    }
}
```

Register specific converters deliberately:

```csharp
options.JsonSerializerOptions.Converters.Add(
    new FlexibleEnumJsonConverter<EMyEnum>());
```

Use a `JsonConverterFactory` only when the project needs this behavior for many enums and can enforce the same validation policy globally.

## Requests

Requests must reject:

- malformed JSON
- incompatible types
- missing required fields
- invalid enum names or numbers
- ambiguous values
- values that would be silently converted to defaults

Keep request tolerance intentional. Accepting enum name variations is useful; accepting arbitrary strings, unknown numbers, or default fallbacks is not.

## Responses

Responses must be lean, explicit, and safe:

- Omit null optional properties.
- Return arrays for collections.
- Use camelCase.
- Use string enums.
- Use ISO-8601 dates.
- Expose DTOs only.
- Exclude sensitive values and internal implementation details.

Correct response:

```json
{
  "id": "9b44b7bf-7473-4632-a1a7-8d77edc4df0d",
  "name": "Paulo",
  "status": "ACTIVE",
  "roles": [],
  "createdAt": "2026-06-10T15:30:00Z"
}
```

Incorrect response:

```json
{
  "Id": "9b44b7bf-7473-4632-a1a7-8d77edc4df0d",
  "Name": "Paulo",
  "Status": 1,
  "Roles": null,
  "PasswordHash": "..."
}
```

## ProblemDetails and Errors

Errors are JSON contracts too. Keep them camelCase, stable, and free of sensitive details. Follow the project error format from `dotnet-error-handling` when present.

Example:

```json
{
  "type": "https://httpstatuses.com/400",
  "title": "Invalid request",
  "status": 400,
  "errors": [
    {
      "code": "enum.invalid",
      "message": "The value 'THIRD' is not valid for EMyEnum.",
      "target": "enumValue"
    }
  ]
}
```

Do not expose exception types, stack traces, SQL, framework internals, secrets, or infrastructure details.

## Compatibility

Avoid breaking public contracts. Treat these as breaking changes unless versioned or migrated deliberately:

- Renaming a property.
- Removing a property.
- Changing a property type.
- Changing enum output from number to string after clients depend on numbers.
- Changing field semantics.
- Starting to serialize nulls where nulls were previously omitted.
- Making optional request input required.
- Changing error shape without migration.

Prefer additive changes: add optional response fields, introduce new versioned DTOs, or keep old behavior during transition.

## Prohibited Anti-Patterns

Reject or refactor:

- null-heavy payloads
- enum magic numbers in responses
- silent enum default conversion
- domain entity exposure
- EF entity exposure
- mixed `camelCase`, `PascalCase`, and `snake_case`
- over-generic DTOs
- breaking public contracts silently
- sensitive data in responses or errors

## Validation Checklist

Before completing an API contract change, verify:

- [ ] JSON uses `camelCase`.
- [ ] Responses omit null properties.
- [ ] Collections return `[]` when applicable.
- [ ] Enums serialize as strings.
- [ ] Enums accept valid numeric input when configured.
- [ ] Enums accept case-insensitive string input when configured.
- [ ] Invalid enum values are rejected.
- [ ] DTOs do not expose domain entities.
- [ ] DTOs do not expose EF entities.
- [ ] Dates use ISO-8601.
- [ ] Responses expose no sensitive data.
- [ ] No breaking change is introduced without versioning or migration.
