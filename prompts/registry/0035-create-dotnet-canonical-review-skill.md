# Create Dotnet Canonical Review Skill

## Prompt

Create a canonical `.ai` skill named `dotnet-canonical-review`.

The skill must guide AI agents such as Codex, Claude Code, Gemini CLI, Cursor, Windsurf, OpenCode, Aider, and similar tools through complete read-first audits of .NET projects hosted in the canonical `.ai` repository structure. It must apply the canonical .NET skills, global repository rules, local overlays, documentation, ADRs, OpenSpec, business context, physical structure, and source code.

The audit must discover project context, consolidate the effective ruleset, identify architectural violations, technical debt, pattern deviations, technical risks, architectural risks, operational risks, and canonical skill compliance, then produce a compliance score, correction plan, evolution roadmap, pull request plan, and persistent human-readable and machine-readable audit artifacts.

## Result

Added `.ai/skills/dotnet-canonical-review/SKILL.md` and `agents/openai.yaml`.

The skill defines project discovery, mandatory canonical skill dependencies, context sources, rule precedence, read-only diagnosis mode, fourteen audit phases, missing-information handling, severity and scoring rules, required finding identifiers, required report format, persistence paths, JSON structure, decision checklist, and prohibited anti-patterns.
