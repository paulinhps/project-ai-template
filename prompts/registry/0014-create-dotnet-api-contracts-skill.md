# Create Dotnet API Contracts Skill

Created the shared `dotnet-api-contracts` skill for reusable guidance on JSON API contracts in .NET applications.

The skill complements `dotnet-rest-api-design`: REST behavior remains owned by the REST API design skill, while JSON representation, DTO shape, serializer configuration, payload clarity, and enum input/output behavior are owned by this skill.

The skill defines reusable guidance for:

- Creating explicit request and response DTOs.
- Using `camelCase` JSON contracts.
- Omitting null response properties.
- Returning empty arrays for empty collections.
- Serializing enums as strings.
- Accepting valid enum input by number or case-insensitive name when configured.
- Rejecting invalid enum values instead of falling back to defaults.
- Configuring `System.Text.Json` for lean, predictable payloads.
- Proposing custom enum converters when flexible enum input is required.
- Keeping `ProblemDetails` and validation errors consistent.
- Avoiding domain entity, EF entity, infrastructure, and sensitive-data exposure.
- Preserving public API contract compatibility.

The skill was added at:

```text
.ai/skills/dotnet-api-contracts/SKILL.md
```

This prompt registry entry records the AI-driven change to shared skill behavior.
