# Use Main as the Default Branch

## Prompt

Review the main branch. The project should change the primary branch from `master` to `main`. Review the project initialization skill so root repository creation is initialized with the `main` branch.

## Outcome

- Updated the AI environment setup skill to default newly initialized Git repositories to `main`.
- Added a `DefaultBranch` script parameter with `main` as the default value.
- Updated local bootstrap initialization for the `.ai` repository to use the configured default branch.
- Added a fallback that runs `git branch -M main` when the installed Git version does not support `git init --initial-branch`.
- Updated project usage documentation so new project instructions use `git init --initial-branch=main`.

## Files

- `.ai/skills/configurar-ambiente-ai/SKILL.md`
- `.ai/skills/configurar-ambiente-ai/scripts/setup-ai-environment.ps1`
- `.ai/README.md`
- `README.md`
