# Refine Repository Reference Modes

## Prompt Summary

The project owner clarified that empty root workspace directories are acceptable under a YAGNI approach, but repository references need stronger deterministic behavior.

## Decisions

- Keep `docs/`, `sources/`, and `openspec/` as contextual conventions that may be created by initialization without requiring placeholder files.
- Treat copied `.ai` contexts without Git metadata as local-only and ignore them from the root repository.
- Treat `.ai` Git repositories without `origin` as local bootstrap state that may be ignored or explicitly registered as local submodules.
- Register `.ai` as a submodule only when a remote repository URL exists.
- Apply a stricter reference rule to projects under `sources/`: every source repository must be a submodule.
- Use remote URLs in `.gitmodules` when a repository has `origin`; use local URLs for source repositories while `origin` is missing.
- Require setup decisions for preexisting root files or structures: merge, replace, or restructure.

## Updated Assets

- `.ai/rules/repository-submodule-references.md`
- `.ai/skills/configurar-ambiente-ai/SKILL.md`
- `.ai/skills/configurar-ambiente-ai/scripts/setup-ai-environment.ps1`
- `.ai/skills/configurar-ambiente-ai/assets/seeds/AGENTS.md`
- `.ai/skills/source-module-setup.md`
- `.ai/skills/dotnet-ai-repository-structure/SKILL.md`
- `.ai/README.md`
