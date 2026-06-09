# Conventional Commits Rule

All agents MUST use this rule whenever they create commits in any repository that belongs to this project.

This project follows Conventional Commits 1.0.0:

https://www.conventionalcommits.org/en/v1.0.0/

## Required Format

Every commit message MUST use this structure:

```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

The commit MUST start with a valid lowercase type, followed by an optional scope, an optional breaking-change marker, a colon, a space, and a short description.

Valid examples:

```text
feat(tenant): add activation workflow
fix(auth): validate expired refresh tokens
docs(readme): update setup instructions
build(dotnet): upgrade project to .NET 10
ci(github): add backend validation workflow
```

## Allowed Types

Only these types are allowed:

- `feat`: new functionality
- `fix`: bug fix
- `docs`: documentation
- `style`: formatting, whitespace, linting, or style-only changes without logic changes
- `refactor`: code restructuring without behavior changes
- `perf`: performance improvement
- `test`: tests
- `build`: build system, dependencies, packages, SDKs, or generated build assets
- `ci`: pipelines, GitHub Actions, Azure DevOps, or automation
- `chore`: auxiliary tasks without direct production-code impact
- `revert`: revert a previous commit

The type MUST be lowercase.

## Scope

The scope is optional, but SHOULD be used when it helps identify the changed area.

Recommended project scopes include:

- `api`
- `auth`
- `tenant`
- `database`
- `docs`
- `ci`
- `tests`
- `migration`
- `packages`

Example:

```text
feat(tenant): add activation workflow
```

## Description

The description MUST:

- be short, clear, and objective
- be written in English
- use the imperative mood when practical
- avoid a final period
- explain what changed, not how it changed

Valid examples:

```text
fix(auth): validate expired refresh tokens
docs(readme): update setup instructions
build(dotnet): upgrade project to .NET 10
ci(github): add backend validation workflow
```

Generic messages are forbidden, including:

- `update`
- `changes`
- `fix`
- `ajustes`
- `wip`
- `melhorias`
- `commit final`

## Breaking Changes

Breaking changes MUST use one of these forms.

Short form:

```text
feat(api)!: change tenant activation contract
```

Footer form:

```text
feat(api): change tenant activation contract

BREAKING CHANGE: tenant activation now requires an explicit activation token.
```

When used as a footer, `BREAKING CHANGE` MUST be uppercase.

## Footers

Use footers for issue, task, ticket, review, or breaking-change metadata.

Issue and ticket references SHOULD use:

```text
Refs: #123
Closes: #456
```

Footers MUST appear after a blank line following the body or description.

## Commit Splitting

If the working tree contains unrelated subjects, agents MUST prefer separate commits.

Examples:

- one commit for package updates
- one commit for breaking-change adjustments
- one commit for documentation updates
- one commit for test fixes

Commits SHOULD be small, cohesive, and traceable.

## Required Pre-Commit Procedure

Before creating any commit, every agent MUST:

1. Run `git status`.
2. Review the changed files.
3. Check for unrelated or out-of-scope changes.
4. Check for secrets, tokens, passwords, keys, credentials, and sensitive files.
5. Group changes semantically.
6. Choose the correct type.
7. Choose a scope when useful.
8. Confirm the commit message follows this rule.
9. Confirm required builds or tests for the task have passed, or document why they could not be run.

## Commit Blockers

Agents MUST NOT create a commit when:

- files outside the task scope are changed
- secrets, tokens, passwords, credentials, keys, or sensitive files are present
- required builds or tests are failing without explanation
- the commit message does not follow Conventional Commits

If unrelated local changes already exist, agents MUST leave them untouched and either commit only the relevant files or ask for guidance when the boundary is unclear.

## Project Examples

```text
build(dotnet): upgrade backend projects to .NET 10

fix(tenant): adjust activation workflow validation

docs(migration): update .NET version references

ci(backend): validate build and tests on pull requests

refactor(api): simplify tenant activation handlers

test(tenant): add coverage for activation failure scenarios

feat(tenant): add tenant activation workflow

feat(api)!: change tenant activation endpoint contract

BREAKING CHANGE: tenant activation endpoint now requires activationToken in the request body.
```
