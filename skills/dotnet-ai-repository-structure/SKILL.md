---
name: dotnet-ai-repository-structure
description: Deterministic orchestrator for AI-governed repository roots and .NET project roots. Use when creating, reviewing, or repairing repositories that use canonical AI context in `.ai`, root workspace folders such as `docs/` and `sources/`, OpenSpec/Git setup from `configurar-ambiente-ai`, and .NET project structure from `dotnet-project-structure` under `sources/<dotnet-project>/`.
---

# Dotnet AI Repository Structure

Use this skill to connect two separate structures without mixing their scopes:

- `configurar-ambiente-ai` owns the repository root, canonical `.ai` context, tool links, OpenSpec, root Git setup, `docs/`, and `sources/`.
- `source-module-setup` owns source repository reference decisions under `sources/`, including local submodules and remote-backed submodules.
- `dotnet-project-structure` owns the internal structure of a .NET project rooted at `sources/<dotnet-project>/`.
- This skill owns the deterministic orchestration between the two.

## Core Rule

Keep `.ai` exclusively at the repository root. Do not create AI context directories inside .NET projects unless the user explicitly asks for a separate AI-governed repository there.

Never create these paths during the normal flow:

```text
sources/<dotnet-project>/.ai/
sources/<dotnet-project>/.codex/
sources/<dotnet-project>/.claude/
sources/<dotnet-project>/.agents/
```

When the root contains `.ai` and `sources/`, treat the root as the AI workspace and `sources/<project-name>` as the real code project root.

## Required Dependencies

Always coordinate with these skills:

- `configurar-ambiente-ai`
- `source-module-setup`
- `dotnet-project-structure`

Conflict resolution:

- Root workspace, `.ai`, `.codex`, `.claude`, `.agents`, OpenSpec, root `docs/`, root `sources/`, `.gitignore`, `.gitmodules`, and root Git rules follow `configurar-ambiente-ai`.
- Source module Git reference behavior follows `source-module-setup` and `.ai/rules/repository-submodule-references.md`. Every source project must be registered as a root Git submodule.
- .NET source layout, solution/project placement, tests, project docs, scripts, tools, deploy, and build folders follow `dotnet-project-structure`.
- This skill decides which scope each action belongs to and prevents cross-scope writes.

## Expected Final Shape

```text
<repository-root>/
  .ai/
  .codex -> .ai
  .claude -> .ai
  .agents -> .ai
  docs/
  sources/
    <dotnet-project>/
      src/
      tests/
      docs/
      tools/
      scripts/
      deploy/
      build/
      README.md
      CHANGELOG.md
  AGENTS.md
  .gitignore
  .gitmodules
  README.md
```

For microservice-oriented .NET projects, the project root may contain:

```text
sources/<dotnet-project>/
  src/
    Services/
      Orders/
      Sales/
      Companies/
    BuildingBlocks/
  tests/
  docs/
```

## Repository Root Responsibilities

Use the repository root for:

- AI governance and canonical context.
- Shared skills, rules, commands, agents, templates, MCP assets, and prompt registry.
- OpenSpec and SDD workflow assets.
- Cross-project documentation in `docs/`.
- The `sources/` workspace for code projects.
- Git submodule registration and root-level Git coordination.

Do not apply `dotnet-project-structure` at the AI workspace root.

## Dotnet Project Responsibilities

Use `sources/<dotnet-project>/` for:

- .NET source code and tests.
- `.sln` and `.csproj` files.
- Project-specific technical documentation.
- Project-specific scripts, tools, deploy assets, and build configuration.
- Application configuration owned by that .NET project.

Do not apply `configurar-ambiente-ai` inside `sources/<dotnet-project>/`.

## Creation Workflow

Follow this order for a new AI-governed .NET repository:

1. Prepare or repair the repository root with `configurar-ambiente-ai`.
2. Verify the root has `.ai/`, `.codex`, `.claude`, `.agents`, `docs/`, `sources/`, `AGENTS.md`, and `.gitignore`.
3. Decide whether the .NET project is new local source or an existing remote repository.
4. Create or register the project at `sources/<dotnet-project>/`.
5. If the project already has its own repository and remote `origin`, register it as a Git submodule using the remote URL instead of copying its source into the root repository.
6. If the project is local-only or has no remote, register it as a local Git submodule and report `remote origin pending`.
7. Change scope to `sources/<dotnet-project>/`.
8. Apply `dotnet-project-structure` inside that project root.
9. Return to the repository root and validate submodule state when applicable.

## Existing Repository Analysis

When reviewing an existing repository:

1. Identify the actual repository root.
2. Verify whether `.ai` exists only at that root.
3. Verify `.codex`, `.claude`, and `.agents` point to `.ai`.
4. Verify `sources/` exists at the root.
5. Map projects inside `sources/`.
6. Identify .NET projects outside `sources/`.
7. Identify forbidden AI context directories inside .NET projects.
8. Inspect `.gitmodules`.
9. Determine whether projects in `sources/` are remote-backed submodules or local submodules.
10. Suggest corrections without mixing root governance and project source scopes.

## Submodule Rules

Use `.ai/rules/repository-submodule-references.md` for all source project references.

When `sources/<dotnet-project>` is a submodule:

- Preserve it as a submodule.
- Do not copy its source into the root repository.
- Do not create `.ai` or tool links inside the submodule unless explicitly requested.
- Do not mix commits from the root repository with commits from the .NET project repository.
- Commit only the submodule reference from the root repository.
- Commit project source changes inside the project repository itself.

When `sources/<dotnet-project>` is local-only:

- Preserve it as an independent Git repository.
- Register it as a local submodule in the root repository.
- Report `remote origin pending`.
- Replace the local `.gitmodules` URL with the remote `origin` URL after a remote exists and the user approves migration.

## Documentation Separation

Use root `docs/` for:

- Cross-project strategy.
- OpenSpec and SDD notes.
- AI workflow documentation.
- Workspace organization.
- Decisions that affect multiple projects.

Use `sources/<dotnet-project>/docs/` for:

- Backend architecture.
- Project ADRs.
- Technical requirements.
- Integrations.
- Runbooks.
- Domain glossary.

## Decision Checklist

Before creating or moving a directory, answer:

1. Does this directory belong to the repository root or the .NET project?
2. Is this content AI governance or source/project content?
3. Should the .NET project use a remote-backed submodule URL or a local submodule URL?
4. Does `.ai` already exist at the repository root?
5. Does root `sources/` already exist?
6. Is the .NET project being created under `sources/<dotnet-project>/`?
7. Is the right dependency skill being applied in the right scope?
8. Is there any risk of duplicating AI context inside the .NET project?

## Validation Checklist

Before finishing, verify:

- [ ] `.ai` exists only at the repository root.
- [ ] `.codex` points to `.ai`.
- [ ] `.claude` points to `.ai`.
- [ ] `.agents` points to `.ai`.
- [ ] `sources/` exists at the repository root.
- [ ] The .NET project is under `sources/<dotnet-project>/`.
- [ ] The .NET project does not contain `.ai`.
- [ ] The .NET project does not contain `.codex`, `.claude`, or `.agents`.
- [ ] The .NET project follows `dotnet-project-structure`.
- [ ] The repository root does not contain .NET source code outside `sources/`.
- [ ] Submodules were preserved.
- [ ] Local-only source repositories are registered as local submodules.
- [ ] Root documentation and project documentation are separated.
- [ ] The final structure is deterministic and predictable.

## Prohibited Anti-Patterns

Avoid these structures:

```text
sources/backend/.ai/
```

```text
<repository-root>/src/
<repository-root>/tests/
```

```text
<repository-root>/backend/
  src/
  tests/
```

Also avoid:

- Mixing skills, rules, commands, or agent assets with backend source code.
- Creating multiple `.ai` directories for each project.
- Running `dotnet-project-structure` at the AI workspace root.
- Running `configurar-ambiente-ai` inside `sources/<dotnet-project>/`.
- Creating .NET code directly at the root.
- Flattening submodules into the root repository.

## Correct Examples

Single backend:

```text
ai-workspace/
  .ai/
  sources/
    backend/
      src/
      tests/
      docs/
  docs/
```

Multiple projects:

```text
ai-workspace/
  .ai/
  sources/
    backend/
    frontend/
    workers/
  docs/
```

Microservice backend:

```text
ai-workspace/
  .ai/
  sources/
    platform-backend/
      src/
        Services/
          Orders/
          Sales/
          Companies/
        BuildingBlocks/
      tests/
      docs/
  docs/
```
