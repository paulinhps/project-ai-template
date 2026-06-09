# Fix Agents Link Mapping

Updated the shared AI environment setup convention so the root `.agents` path maps to the canonical `.ai` directory, matching `.codex` and `.claude`.

This change updates:

- Root and seed `AGENTS.md` guidance.
- `.ai/README.md` expected project shape.
- The `configurar-ambiente-ai` skill assertions.
- The setup script link target for `.agents`.
- The setup script repair behavior for existing links that point to an unexpected target.

The corrected root link mapping is:

```text
.codex  -> .ai
.claude -> .ai
.agents -> .ai
```

This prompt registry entry records the AI-driven setup convention and shared skill change.
