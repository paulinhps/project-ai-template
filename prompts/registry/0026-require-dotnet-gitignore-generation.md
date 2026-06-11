# Require Dotnet Gitignore Generation

## Prompt Summary

The project owner observed that AI agents were repeatedly handling generated .NET artifacts that should not be tracked. The .NET project structure skill should require creating the standard .NET `.gitignore` during project setup.

## Decision

When creating or restructuring a .NET repository, run `dotnet new gitignore` from the .NET repository root if `.gitignore` is missing.

This keeps generated artifacts such as `bin/`, `obj/`, IDE files, test results, and package outputs out of root commits and source-module commits without repeated manual cleanup.

## Updated Assets

- `.ai/skills/dotnet-project-structure/SKILL.md`
