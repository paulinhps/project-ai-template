# Require Published Submodule Gitlinks

## Prompt Summary

The project owner asked whether gitlinks need explicit canonical rules. The answer is yes: a root repository can point to an unpublished submodule commit, which makes clean clones unreproducible.

## Decisions

- Define gitlink as the root repository entry, mode `160000`, that stores the expected commit for a submodule path.
- For `.ai` with `origin`, push `.ai` commits before updating the root gitlink.
- For `sources/<module>` with `origin`, push source-module commits before updating the root gitlink.
- For local source submodules without `origin`, allow local gitlinks only as local bootstrap state and report that the root is not portable for that module.
- Validation must check that remote-backed submodule gitlinks point to commits reachable from the configured remote.

## Updated Assets

- `.ai/rules/repository-submodule-references.md`
- `.ai/skills/source-module-setup.md`
- `.ai/skills/dotnet-ai-repository-structure/SKILL.md`
