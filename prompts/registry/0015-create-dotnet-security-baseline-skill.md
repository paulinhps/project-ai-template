# Create Dotnet Security Baseline Skill

Created the shared `dotnet-security-baseline` skill for reusable guidance on a minimum security baseline for .NET backend applications, REST APIs, workers, and microservices.

The skill complements existing .NET skills by owning security requirements and risk reduction while deferring REST semantics, API contract shape, Clean Architecture boundaries, error taxonomy, and observability details to their specialized skills when available.

The skill defines reusable guidance for:

- Secure-by-default backend development.
- Authentication with established ASP.NET Core mechanisms.
- Explicit authorization through attributes, policies, roles, and validated claims.
- External input validation across body, query, route, headers, files, webhooks, queues, and events.
- Mass-assignment prevention through use-case-specific request DTOs.
- Secrets handling outside source code.
- Secure configuration, HTTPS, HSTS, CORS, cookies, and production diagnostics.
- Rate limiting for public, costly, authentication, recovery, webhook, and externally exposed endpoints.
- Sensitive data minimization, masking, and response safety.
- Secure structured logging.
- Safe error responses without infrastructure details.
- SQL injection prevention through parameterization and allowlisted dynamic query parts.
- Safe file upload handling.
- Webhook signature, timestamp, replay, idempotency, and schema validation.
- Avoidance of custom cryptography.
- Clean Architecture placement of security concerns.
- Existing-code security review and new-code validation checklists.

The skill was added at:

```text
.ai/skills/dotnet-security-baseline/SKILL.md
```

This prompt registry entry records the AI-driven change to shared skill behavior.
