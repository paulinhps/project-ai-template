# 0038 - AI Tool Profile Activation

## Objective

Restructure the canonical setup model so `.ai` remains AI-agnostic while generated project roots are activated for the AI tool surfaces explicitly requested by the project owner: Codex, Claude Code, or both.

## Conversation Structure

This prompt registry entry is intentionally documented using the structure of the chat that produced the decision.

### 1. External Claude Code Evolution Review

The project owner reported that an external developer had evolved `.ai` for Claude Code discovery and asked for a pull, structural analysis, Codex parity review, and a cross-platform readiness diagnosis.

The assistant pulled `.ai`, reviewed the Claude Code changes, identified that the root still lacked `CLAUDE.md`, and reported that the Claude change was conceptually correct but exposed a broader setup question.

### 2. Root Activation Rule

The project owner concluded that setup should initialize a root from the perspective of the AI in execution:

- If setup is run for Codex, normalize the root for Codex and keep Claude optional.
- If setup is run for Claude Code, normalize the root for Claude and keep Codex optional.
- If both are explicit, configure the root for both.

The assistant proposed separating canonical capabilities from root activation, adding explicit setup modes, adding Codex-specific overrides, and preserving compatibility.

### 3. Template-Based Entrypoints

The project owner asked whether a template should handle `AGENTS.md`, `CLAUDE.md`, and future AI-agent entrypoints.

The assistant agreed and refined the plan around tool profiles and generic templates:

- `AGENTS.md` remains the canonical shared operating guide.
- Tool-specific files such as `CLAUDE.md` are generated bridge files.
- Future tools should be added through profiles and templates, not hardcoded branches.

### 4. Execution Request

The project owner approved the plan and explicitly asked to execute it. The owner also required an architectural decision record under `docs/adr` in addition to prompt-registry audit history.

## Decisions

- Add setup tool profiles under `skills/setup-ai-environment/assets/tool-profiles`.
- Add generic root-entrypoint templates under `skills/setup-ai-environment/assets/templates`.
- Keep `AGENTS.md` as the canonical root operating guide in every setup mode.
- Generate tool-specific bridge files only when required by activated profiles.
- Support `--ai-tool codex`, `--ai-tool claude`, and `--ai-tool both` in the Node setup script.
- Support `-AiTool "codex"`, `-AiTool "claude"`, and `-AiTool "both"` in the PowerShell setup script.
- Keep `both` as the compatibility default.
- Add explicit Codex override documentation under `codex/overrides/codex.md`.
- Retire fixed `AGENTS.md` and `CLAUDE.md` seeds in favor of profile-rendered templates.
- Add root ADR `docs/adr/0001-ai-tool-profile-activation.md`.

## Files Changed

- `skills/setup-ai-environment/assets/tool-profiles/codex.json` - Codex setup profile.
- `skills/setup-ai-environment/assets/tool-profiles/claude.json` - Claude Code setup profile.
- `skills/setup-ai-environment/assets/templates/root-agents.md.tpl` - generated `AGENTS.md` template.
- `skills/setup-ai-environment/assets/templates/agent-entrypoint.md.tpl` - generated tool bridge template.
- `skills/setup-ai-environment/scripts/setup-ai-environment.mjs` - profile-driven setup generation.
- `skills/setup-ai-environment/scripts/setup-ai-environment.ps1` - profile-driven setup generation for PowerShell.
- `skills/setup-ai-environment/SKILL.md` - documented profile activation and generated entrypoints.
- `skills/setup-ai-environment/assets/seeds/.gitignore` - changed to a neutral seed; scripts add activated pointer paths.
- `skills/setup-ai-environment/assets/seeds/AGENTS.md` - removed; replaced by template rendering.
- `skills/setup-ai-environment/assets/seeds/CLAUDE.md` - removed; replaced by template rendering.
- `README.md` - documented activation and tool profiles.
- `CLAUDE.md` - adjusted canonical wording around activated pointers.
- `claude/overrides/claude-code.md` - updated Claude bridge wording for generated profiles.
- `codex/README.md` - points to Codex override details.
- `codex/overrides/README.md` - clarifies Codex override scope.
- `codex/overrides/codex.md` - explicit Codex discovery and setup behavior.
- Root `AGENTS.md` - updated current project root to both-tool activation.
- Root `CLAUDE.md` - added current project Claude Code bridge.
- Root `docs/adr/0001-ai-tool-profile-activation.md` - architectural decision record.

## Known Follow-Up

- Run setup validation in temporary project roots for `codex`, `claude`, and `both`.
- Re-run cross-platform readiness review after validation.
- Commit `.ai` first and push it before committing the root gitlink update.
