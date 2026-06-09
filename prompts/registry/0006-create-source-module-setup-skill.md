# Create Source Module Setup Skill

Created the shared `source-module-setup` skill to standardize source repository setup under the platform's Source Isolation Architecture.

The skill defines deterministic procedures for:

- Creating remote-backed modules under `sources/` as Git submodules.
- Creating new local independent Git repositories under `sources/`.
- Validating existing directories, Git repositories, and submodules before modification.
- Enforcing that application source code is never created directly in the root repository.
- Documenting submodule creation, registration, synchronization, update, removal, and migration.

The skill was added at:

```text
.ai/skills/source-module-setup.md
```

This prompt registry entry records the AI-driven change to shared skill behavior.
