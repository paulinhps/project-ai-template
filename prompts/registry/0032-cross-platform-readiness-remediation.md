# Cross-Platform Readiness Remediation

Prompt executed:

```text
Execute o Plano ignorando a etapa 7, ela não é necessária no momento
```

Scope:

- Implement the remediation plan from `cross-platform-readiness-review`.
- Skip the Docker, DevContainer, and Codespaces fallback step for now.

Changes requested:

- Commit and publish pending `.ai` changes, then update the root gitlink.
- Add explicit encoding and line-ending policy.
- Normalize shared documentation toward slash-form paths and Windows/Linux/macOS guidance.
- Add a cross-platform setup path.
- Add portable fallbacks for `opsx` commands and generated OpenSpec skills.
- Document required tools, minimum versions, and MCP portability expectations.

Implementation notes:

- Added `.editorconfig` and `.gitattributes` to the root and `.ai` repositories.
- Added `skills/setup-ai-environment/scripts/setup-ai-environment.mjs` as the Node-based cross-platform setup script.
- Kept `setup-ai-environment.ps1` as the supported Windows PowerShell equivalent.
- Updated shared setup documentation and AGENTS seed guidance to prefer slash-form paths.
- Added portable tool fallbacks to `opsx` commands and matching OpenSpec skills.
- Added toolchain and MCP readiness documentation.

Skipped:

- Docker, DevContainer, and Codespaces fallback, by explicit user direction.
