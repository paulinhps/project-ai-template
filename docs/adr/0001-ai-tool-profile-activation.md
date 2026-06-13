# ADR 0001: Canonical AI Workspace Structure and Tool Profile Activation

## Status

Accepted

## Context

The repository uses a reusable `.ai` module to provide canonical AI operating context. This context initializes project roots, exposes shared rules and skills, supports multiple AI coding tools, and gives agents a repeatable way to discover how work should be organized.

The root repository is not the canonical module itself. It is an orchestration and documentation workspace that consumes `.ai`, owns project-wide context, and coordinates source repositories under `sources/`. This makes the root similar to a monorepo coordination layer, but not identical: source code remains isolated in independent repositories and is referenced through submodules.

Earlier setup behavior also created Codex and Claude paths together. That was convenient, but it made every generated root look like it had activated every supported AI tool. The Claude Code compatibility work showed that different tools have different discovery surfaces. Claude Code reads `CLAUDE.md` natively, while Codex uses `AGENTS.md` as the shared operating guide. Future AI tools may add their own root entrypoints, pointer names, or override locations.

Canonical documentation about this reusable structure must live with the canonical `.ai` module and be versioned there. Root documentation should describe the current project workspace, business decisions, source-module coordination, and decisions that affect the projects under `sources`.

## Decision

Separate canonical AI context, project-root context, project-specific AI overlay, and source repositories.

- `.ai` is the canonical reusable AI context. It stores shared rules, skills, commands, agents, templates, MCP assets, prompt history, tool overrides, tool profiles, and canonical documentation.
- `.ai/docs` stores documentation that defines the reusable `.ai` structure itself, including canonical ADRs.
- `.ai-overlay` is the versioned project-specific AI context overlay. It mirrors `.ai` conceptually and is loaded after `.ai`, but starts with only `README.md` and grows only when project-specific AI assets are needed.
- Root `docs` stores global documentation for the current project workspace, including business context, product context, requirements, engineering notes, and decisions that affect the repositories coordinated by the root.
- `sources` stores real source repositories evolved or referenced by the root. Each source project owns its own Git lifecycle and is registered as a root submodule.
- The root repository owns AI governance, global documentation, source-module references, and root Git coordination. It must not become an application source repository by default.

Separate canonical AI capabilities from root activation.

- `.ai` may contain support for multiple AI tools.
- `AGENTS.md` remains the canonical shared root operating guide generated for project roots.
- Tool-specific root files such as `CLAUDE.md` are generated bridges, not canonical replacements for `AGENTS.md`.
- The setup skill uses tool profiles to decide which root entrypoints, pointer paths, and ignore entries to create.
- Supported setup activations are `codex`, `claude`, and `both`; `both` remains the compatibility default.
- Activated pointer paths point to `.ai`; inactive tool paths are optional and must not be created as independent trees.

## Consequences

The canonical `.ai` module can evolve its own documentation without creating root-level ADRs for decisions that do not govern the root workspace.

Agents can reason about four distinct ownership layers:

- Canonical reusable AI workflow in `.ai`.
- Project-specific AI customization in `.ai-overlay`.
- Root-level project context and documentation in root `docs`.
- Productive source repositories under `sources`.

The setup skill can initialize a Codex-focused root, a Claude-focused root, or a root that exposes both tool surfaces. Adding a future AI tool should require a new tool profile and, when needed, a bridge template output rather than another hardcoded setup path.

Existing projects are not automatically stripped of previously activated pointers. Removing or changing existing tool paths requires an explicit project decision because those paths may already be part of local workflow.

## Validation

- Canonical ADRs about `.ai` itself live under `.ai/docs/adr`.
- Root ADRs remain under `docs/adr` only when they govern the root workspace or projects under `sources`.
- A Codex activation creates `AGENTS.md`, `.agents`, and `.codex`.
- A Claude activation creates `AGENTS.md`, `CLAUDE.md`, `.agents`, and `.claude`.
- A both activation creates `AGENTS.md`, `CLAUDE.md`, `.agents`, `.codex`, and `.claude`.
- `AGENTS.md` remains the canonical shared guide in every mode.
- Tool-specific behavior lives under `.ai/<tool>/overrides` or `.ai-overlay/<tool>/overrides`.
