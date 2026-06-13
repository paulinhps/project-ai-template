# {{rootEntrypoint}}

{{toolName}} reads this file as its project entry point. It is a short bridge to the canonical AI context and must not duplicate that context.

## Discovery Order

{{readFirstBullets}}

## Rules for {{toolName}}

{{ruleBullets}}
- Activated tool pointer paths point to `.ai`; do not turn them into independent trees.
- Load `.ai/` first, then `.ai-overlay/` for project-specific context when present.
- Follow `.ai/rules/conventional-commits.md` and `.ai/rules/repository-submodule-references.md`.
- Prompt files in `.ai/prompts/registry` are immutable; add the next sequential file and never edit existing ones.

## Personal Configuration

{{personalConfigGuidance}}
