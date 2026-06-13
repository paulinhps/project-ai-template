# 0040 - Canonical AI Documentation Boundary

## Objective

Move canonical documentation about the reusable `.ai` structure out of the root project documentation and into the canonical `.ai` module.

## Context

The project owner clarified that this root repository is currently used to evolve, test, and support decisions for the canonical AI context. Documentation that defines the reusable `.ai` structure should therefore be versioned with `.ai`, not stored as a root ADR that appears to govern the root workspace itself.

The root workspace has a separate responsibility: it coordinates global project documentation, business context, source-module references, and repositories under `sources/`. The canonical `.ai` module defines a reproducible AI-agent context that can be reused across projects, AI tools, and operating systems.

## Decisions

- Add `.ai/docs` as the location for reusable canonical documentation.
- Store canonical ADRs under `.ai/docs/adr`.
- Move the tool profile activation ADR from root `docs/adr` into `.ai/docs/adr`.
- Broaden the ADR to document the ownership boundary between `.ai`, `.ai-overlay`, root `docs`, and `sources`.
- Document that root `docs` is for the current project workspace and source-module coordination.
- Update setup guidance and root `AGENTS.md` template so future generated roots know that canonical documentation belongs under `.ai/docs`.

## Files Changed

- `docs/README.md` - added canonical documentation index and boundary guidance.
- `docs/adr/0001-ai-tool-profile-activation.md` - canonical ADR for workspace structure and tool profile activation.
- `README.md` - documents canonical documentation as part of the `.ai` structure.
- `skills/setup-ai-environment/SKILL.md` - adds `.ai/docs` to canonical structure expectations.
- `skills/setup-ai-environment/assets/templates/root-agents.md.tpl` - exposes `.ai/docs` in generated root guides.
- Root `AGENTS.md` - exposes `.ai/docs` in the current root guide.
- Root `docs/adr/0001-ai-tool-profile-activation.md` - removed because the decision belongs to `.ai`.

## Non-Goals

- Do not alter existing diagnostics work.
- Do not configure SDD or planning tooling.
- Do not change the root workspace's business or source-module decisions.
