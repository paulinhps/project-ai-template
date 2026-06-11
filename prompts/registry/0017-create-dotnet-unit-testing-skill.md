# Create Dotnet Unit Testing Skill

Created the shared `dotnet-unit-testing` skill for reusable guidance on creating, reviewing, and evolving unit tests in .NET applications.

The skill complements the existing .NET guidance by owning unit-test scope, organization, naming, determinism, builders, fakes, mocks, and test quality while deferring domain behavior, Result-oriented failures, persistence testing, and API contract behavior to their specialized skills when available.

The skill defines reusable guidance for:

- Keeping unit tests fast, deterministic, isolated, and behavior-oriented.
- Following existing xUnit, NUnit, MSTest, assertion, mocking, and helper patterns.
- Organizing unit-test projects for Domain, Application, and shared test support.
- Naming tests descriptively while preserving project conventions.
- Testing domain entities, value objects, aggregates, invariants, state transitions, and domain events.
- Testing Result Pattern success and failure flows without using exceptions for expected business failures.
- Testing application services, handlers, repositories as ports, Unit of Work calls, and observable event publication.
- Choosing fakes, stubs, and mocks without mocking domain objects or over-specifying interactions.
- Creating Test Builders only from proven valid states and keeping them valid, simple, local, and preferably immutable.
- Avoiding nondeterministic data, direct wall-clock time, private-method tests, infrastructure dependencies, and cosmetic coverage tests.
- Distinguishing unit tests from API, EF Core, persistence, integration, contract, and functional tests.
- Reviewing existing tests for fragility, excessive mocks, missing assertions, nondeterminism, infrastructure leakage, duplication, and missing business coverage.

The skill was added at:

```text
.ai/skills/dotnet-unit-testing/SKILL.md
```

This prompt registry entry records the AI-driven change to shared skill behavior.
