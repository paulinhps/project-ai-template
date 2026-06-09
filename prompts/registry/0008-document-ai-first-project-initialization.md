# Document AI-First Project Initialization

Updated the shared setup guidance to make the project initialization decision explicit.

The standard new-project flow is:

```text
1. Create or open an empty project root.
2. Clone or download the shared .ai context into that root.
3. Run the configurar-ambiente-ai setup skill/script.
```

The setup skill/script owns root initialization tasks:

- Initializing the root Git repository.
- Creating root directories and seed files.
- Creating `.codex`, `.claude`, and `.agents` links to `.ai`.
- Initializing OpenSpec.
- Registering `.ai` as a submodule/gitlink of the root repository.
- Creating the initial root commit.

This change updates `.ai/README.md`, the `configurar-ambiente-ai` skill instructions, and the seed `AGENTS.md` so future projects document the same initialization decision.
