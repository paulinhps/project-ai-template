---
name: ai-agent-diagnostic
description: Diagnose the AI tool currently in execution and evolve the canonical .ai ecosystem so new or existing AI agents can be activated through auditable tool profiles, generated entrypoints, documentation updates, and a fork-first pull request back to the canonical repository.
---

# Skill Name

ai-agent-diagnostic

# Objective

Use this skill to discover how the AI tool currently in execution identifies repository instructions, configuration, command surfaces, memory files, and project-local assets, then evolve the canonical `.ai` ecosystem so that tool can be activated reproducibly in future projects.

This skill generalizes the Claude Code compatibility audit into an AI-agnostic diagnostic workflow. It is used to add or adjust support for Codex, Claude Code, Cursor, Gemini CLI, OpenCode, Aider, or future AI coding agents without duplicating canonical context or hardcoding behavior into one tool.

The expected outcome is a canonical change set that:

- Identifies the running AI tool and its discovery surfaces.
- Adds or updates the tool profile needed by `setup-ai-environment`.
- Adds or updates only the root entrypoint bridges, pointer paths, override folders, templates, seeds, scripts, rules, skills, and docs required by that tool.
- Preserves `AGENTS.md` as the shared root operating guide.
- Preserves `.ai` as the canonical source of truth and `.ai-overlay` as the project-specific overlay.
- Documents the impact in README files, ADRs, prompts, setup instructions, and tool-specific overrides when applicable.
- Is produced from a fork of the remote canonical repository and returned by pull request to the canonical upstream repository.

This skill does not configure optional SDD/planning tools. It may document how a tool interacts with optional SDD flows only when the tool profile or root-entrypoint behavior would otherwise be ambiguous.

# Required Dependencies

- `skill-authoring-standard` when creating or changing skills.
- `setup-ai-environment` because tool activation profiles, generated entrypoints, pointer paths, seeds, and setup scripts are owned by that skill.
- `.ai/rules/repository-submodule-references.md` when repository reference, fork, submodule, or gitlink behavior is involved.
- `.ai/rules/conventional-commits.md` when creating commits.

# Recommended Dependencies

- `cross-platform-readiness-review` when a new AI tool introduces shell commands, filesystem links, platform-specific configuration, MCP assets, or generated files that must work on Windows, Linux, and macOS.
- `dotnet-ai-repository-structure` only when validating this skill inside a .NET repository that uses the canonical root and `sources/` layout.
- Official documentation for the AI tool being diagnosed, when public and available, to confirm native discovery files, config paths, project memory behavior, and command surfaces.

# Priority

When instructions conflict:

- Explicit user instructions for the current task have priority when they do not violate canonical source-of-truth, fork-first, prompt registry, or repository integrity rules.
- `.ai` remains canonical. Do not move shared behavior into `.ai-overlay`, tool pointer paths, or generated root bridge files.
- `.ai-overlay` remains project-specific. Use it only for local project customizations unless the user explicitly asks to evolve canonical `.ai`.
- `AGENTS.md` remains the shared root operating guide. Tool-specific root files are bridges unless a documented ADR changes that rule.
- Tool-specific behavior belongs in `.ai/<tool>/overrides` only when it cannot be stated neutrally in shared rules, skills, templates, or setup documentation.
- Optional SDD/planning tools are not configured unless the user explicitly requests the specific tool.
- The fork-first rule is mandatory for canonical repository evolution intended to return upstream.

# When To Use

Use this skill when:

- A user asks to adapt the canonical `.ai` ecosystem for a new AI coding tool.
- A user asks for an AI-agnostic or AI-diagnostic agent discovery workflow.
- A compatibility issue shows that the running AI tool does not discover `AGENTS.md`, `.ai`, `.ai-overlay`, skills, rules, commands, templates, MCP assets, or prompt registry conventions.
- A tool needs a new setup profile under `.ai/skills/setup-ai-environment/assets/tool-profiles`.
- A tool needs a root bridge such as `CLAUDE.md`, a pointer path such as `.claude`, a tool-specific override folder, or personal-configuration guidance.
- A previous one-off compatibility request should be generalized into canonical reusable behavior.
- Documentation must explain how a new AI tool is activated without making the whole ecosystem tool-specific.

# When Not To Use

Do not use this skill when:

- The user only wants to initialize a project that already supports the requested AI tool. Use `setup-ai-environment`.
- The user only wants project-specific local behavior. Use `.ai-overlay` and the relevant domain skill instead.
- The user asks to configure OpenSpec, another SDD tool, or a planning tool for one project. Use a project-specific overlay workflow unless the user explicitly asks to evolve canonical `.ai`.
- The work is limited to product code under `sources/`.
- The task is only a cross-platform audit without adding or changing AI tool support. Use `cross-platform-readiness-review`.
- The task is only skill structure review. Use `skill-authoring-standard`.

# Required Principles

## Discover Before Deciding

The AI must inspect the current repository, the canonical `.ai` structure, existing tool profiles, setup scripts, templates, root entrypoints, docs, ADRs, and prompt registry before proposing changes.

## Running Tool Awareness

The AI must identify the tool currently in execution using available evidence: provided system/developer instructions, native files loaded by the tool, environment metadata, active plugins, tool-specific config paths, command surfaces, and user-provided context.

## Canonical First

Shared rules, skills, templates, MCP assets, setup behavior, and documentation belong in `.ai`. Generated root files and pointer paths must not become independent canonical copies.

## Profile First

New tool support must be modeled as a tool profile and template/script behavior whenever possible. Avoid adding hardcoded one-off setup branches.

## Bridge, Do Not Duplicate

Tool-specific root entrypoints must point to the canonical guide and required `.ai` paths. They must not duplicate long canonical instructions.

## Fork First

Canonical changes intended for upstream must be made in a fork of the remote canonical repository and returned as a pull request. Do not push directly to the upstream canonical repository.

## Minimal Specificity

Tool-specific overrides must contain only behavior that is genuinely tool-specific. Neutral behavior belongs in shared `.ai` assets.

## Auditability

Every decision must be traceable to evidence: files read, tool docs, existing profiles, ADRs, prompts, generated outputs, changed files, and validation results.

## Cross-Platform Readiness

New profile behavior must work on Windows, Linux, and macOS, or document a supported fallback and known limitation.

# Rules

## Discovery Workflow

Before changing files:

1. Identify the repository root and the canonical `.ai` root.
2. Run a file inventory over root files and `.ai`.
3. Read `AGENTS.md`, `.ai/README.md`, setup skill documentation, existing tool profiles, setup scripts, root-entrypoint templates, tool override folders, relevant ADRs, and the latest prompt registry entries.
4. Identify the AI tool currently in execution and collect evidence for that identification.
5. Identify how that tool discovers repository instructions and project memory.
6. Identify whether the tool needs a root bridge file, pointer path, override folder, command assets, MCP config, or personal-configuration warning.
7. Identify whether existing setup templates can support the tool without script changes.
8. Identify all documentation impacted by the new or changed tool support.
9. Classify potential changes as required, recommended, or optional.
10. Implement only the required and explicitly approved recommended changes.

Use portable inspection commands when possible:

```bash
rg --files
rg -n "<tool-name>|AGENTS.md|CLAUDE.md|tool-profiles|overridePath|pointerName"
git status --short
git remote -v
git branch --show-current
```

## Running AI Tool Identification

Identify the running AI tool using evidence in this order:

1. Explicit user statement, such as "adapt this for Claude Code".
2. System or developer instructions naming the active tool or interface.
3. Available tool APIs, plugins, MCP servers, or command surfaces.
4. Native files already loaded by the tool, such as `AGENTS.md`, `CLAUDE.md`, or other memory files.
5. Environment variables, config files, or process metadata when safely available.
6. Official documentation or local docs describing that tool's discovery behavior.

If the running tool cannot be identified confidently, document it as `unknown`, perform repository discovery only, and ask for the target AI tool before editing canonical support.

## Remote Fork And Pull Request Workflow

Canonical repository evolution must follow this workflow when a remote upstream exists:

1. Identify the canonical `.ai` repository remote.
2. Identify the upstream repository URL and current branch.
3. Create or use a fork owned by the contributor.
4. Clone or switch the working copy to the fork remote.
5. Create a topic branch in the fork.
6. Apply the canonical changes in that branch.
7. Commit using `.ai/rules/conventional-commits.md`.
8. Push to the fork.
9. Open a pull request back to the upstream canonical repository.
10. Include discovery evidence, decisions, changed files, validation, and known follow-up in the PR description.

If a remote cannot be forked because credentials, network access, provider tools, or permissions are unavailable, do not pretend the fork occurred. Produce a blocked report with exact missing capability and a ready-to-apply change plan.

When working inside a project root where `.ai` is a submodule, make canonical `.ai` changes in the `.ai` repository first. Commit and push the `.ai` fork branch before updating any root gitlink or root documentation that references the new canonical revision.

## Tool Profile Requirements

Each tool profile must live under:

```text
.ai/skills/setup-ai-environment/assets/tool-profiles/<tool-id>.json
```

The `<tool-id>` must use lowercase kebab-case and must not contain spaces, product marketing punctuation, or version numbers unless a version is required to distinguish incompatible discovery behavior.

A profile must declare at least:

```json
{
  "id": "tool-id",
  "displayName": "Tool Display Name",
  "rootEntrypoint": "TOOL.md",
  "canonicalEntrypoint": "AGENTS.md",
  "pointerName": ".tool",
  "overridePath": ".ai/tool/overrides",
  "nativeDiscovery": true,
  "discoverySummary": "How this tool discovers project instructions.",
  "personalConfigGuidance": "Where personal configuration should live.",
  "readFirst": [
    "AGENTS.md",
    ".ai/tool/overrides/tool.md",
    ".ai/rules/"
  ],
  "rules": [
    "AGENTS.md remains the canonical root operating guide."
  ]
}
```

Use `AGENTS.md` as `rootEntrypoint` only when the tool natively reads it or does not require another bridge. Use another root entrypoint only when tool discovery requires it.

## Root Entrypoint Requirements

Generated root entrypoints must:

- Be short bridges.
- Name the canonical guide.
- Point to `.ai` and `.ai-overlay`.
- List only the minimum read-first paths required for the tool.
- Avoid duplicating full canonical rules.
- Avoid project-specific content unless generated into a project root by setup.

## Pointer Path Requirements

Tool pointer paths must point to `.ai` and must not become independent directories.

If the pointer path collides with a tool's project config directory, document:

- The collision.
- The canonical reason the pointer still exists or why it should not exist.
- Where personal or project-local config should live instead.
- The `.gitignore` impact.
- Windows symlink and junction behavior when relevant.

## Override Requirements

Create `.ai/<tool-id>/overrides` only when the tool needs shared behavior that is not neutral.

An override file must explain:

- Native discovery behavior.
- Relationship to `AGENTS.md`.
- Relationship to `.ai` and `.ai-overlay`.
- Pointer path behavior.
- Personal configuration guidance.
- Setup activation behavior.
- Known limitations and non-goals.

If the behavior is neutral across tools, update shared rules, skills, templates, or README content instead.

## Setup Script Requirements

Change setup scripts only when profile data and templates cannot support the tool.

When scripts change:

- Update both the Node script and the PowerShell script when both paths are supported.
- Preserve existing `codex`, `claude`, and `both` behavior unless the user explicitly asks for a breaking change.
- Validate that generated root files and pointer paths match the selected activation.
- Update `setup-ai-environment` documentation and validation checklist.

## Documentation Requirements

Update documentation impacted by the new or changed tool support:

- `.ai/README.md` for canonical tool activation concepts and user-facing discovery.
- `.ai/skills/setup-ai-environment/SKILL.md` for setup behavior, profiles, script options, and validation.
- `.ai/<tool-id>/README.md` and `.ai/<tool-id>/overrides/*.md` when a new tool namespace is added.
- Root bridge templates when generated entrypoints change.
- `.ai/docs/adr/*.md` when a canonical architecture decision changes, such as profile activation behavior or pointer semantics.
- `.ai/prompts/registry/####-*.md` for every canonical evolution.

Do not edit existing prompt registry entries. Create the next sequential file.

## Change Classification

Classify findings before implementation:

```text
Required: Without this change, the AI tool cannot discover or use the canonical context correctly.
Recommended: Improves setup, clarity, portability, or future reuse but is not blocking.
Optional: Nice-to-have, cosmetic, or deferred to avoid broadening the change.
```

Implement required changes. Implement recommended changes only when they are low risk, tightly scoped, or explicitly approved. Do not implement optional changes unless the user explicitly asks.

## Pull Request Requirements

The pull request description must include:

- Target AI tool and version or documented capability date when known.
- Discovery evidence.
- Required, recommended, and optional findings.
- Decisions made.
- Files changed.
- Validation performed.
- Cross-platform considerations.
- Known pending work.
- Confirmation that `.ai` remains canonical and generated entrypoints remain bridges.

# Decision Criteria

Before evolving canonical AI tool support, answer:

1. What AI tool is currently in execution or explicitly targeted?
2. What evidence identifies that tool?
3. How does the tool discover repository instructions?
4. Does it read `AGENTS.md` natively?
5. Does it require a root bridge file?
6. Does it require a pointer path to `.ai`?
7. Does its pointer path collide with personal or project config?
8. Does it need shared tool-specific overrides?
9. Can existing setup templates generate the needed files?
10. Does setup need a new profile only, or script changes too?
11. What docs, ADRs, prompts, templates, or seed files are impacted?
12. Are the changes canonical or project-specific?
13. Has the canonical remote been forked before implementation?
14. Are changes made in the fork and returned by pull request?
15. Is the change cross-platform?
16. Are SDD/planning tools left unconfigured unless explicitly requested?
17. Is every prompt registry change a new immutable file?
18. Are generated entrypoints bridges rather than duplicate canonical docs?

If any answer is unknown, document the uncertainty and either gather more evidence or ask for the missing decision before editing canonical assets.

# Prohibited Anti-patterns

## Direct Upstream Mutation

Explanation: The AI changes or pushes directly to the canonical upstream repository instead of using a fork and pull request.

Example:

```text
git push origin main
```

Correct by creating a fork branch and opening a PR back to upstream.

## Root Entrypoint Duplication

Explanation: The AI copies full canonical instructions into a tool-specific root file, creating divergence risk.

Example:

```text
CLAUDE.md contains the full AGENTS.md content plus custom edits.
```

Correct by making the tool file a short bridge to `AGENTS.md` and `.ai`.

## Independent Pointer Tree

Explanation: The AI creates `.cursor`, `.claude`, `.codex`, or `.agents` as independent directories containing copied canonical files.

Example:

```text
.claude/skills/setup-ai-environment/SKILL.md copied from .ai/skills.
```

Correct by using a pointer to `.ai` or a documented generated bridge when the tool cannot use pointers.

## Hardcoded Tool Branch

Explanation: The AI adds a script branch for one tool when profile data and templates can represent the behavior.

Example:

```text
if (tool === "new-tool") writeSpecialFiles();
```

Correct by adding a profile and extending generic rendering only when necessary.

## Overlay Misplacement

Explanation: The AI adds shared tool support under `.ai-overlay`, making future projects unable to reuse it.

Example:

```text
.ai-overlay/skills/setup-ai-environment/assets/tool-profiles/cursor.json
```

Correct by adding canonical shared profiles under `.ai`.

## Optional SDD Coupling

Explanation: The AI wires OpenSpec or another planning tool while adding AI tool support, even though the user did not explicitly request that SDD tool.

Example:

```text
Adding .ai/openspec commands as part of Cursor activation by default.
```

Correct by documenting that SDD tooling remains optional and project-specific unless explicitly requested.

## Unverified Discovery

Explanation: The AI assumes a tool reads a file or config path without evidence.

Example:

```text
Assuming a future tool reads AGENTS.md because Codex does.
```

Correct by checking official docs, local behavior, or clearly marking the profile as requiring confirmation.

# Practical Examples

## Correct / Incorrect

```text
Correct:
Add .ai/skills/setup-ai-environment/assets/tool-profiles/claude.json.
Generate CLAUDE.md as a bridge to AGENTS.md.
Document Claude-specific config collision in .ai/claude/overrides/claude-code.md.

Incorrect:
Copy AGENTS.md into CLAUDE.md and edit it manually for Claude Code.
```

## Good / Bad

```text
Good:
The new tool profile declares pointerName, rootEntrypoint, readFirst, overridePath, and personalConfigGuidance.

Bad:
The setup script has a new hardcoded branch but no reusable profile.
```

## Allowed / Prohibited

```text
Allowed:
Document that a tool-specific root file is generated only for the activated profile.

Prohibited:
Create every possible tool root file in every generated project just because .ai supports those tools.
```

## Fork Workflow Example

```text
Correct:
Fork upstream canonical .ai repository.
Create branch feat/ai-agent-profile-cursor in the fork.
Commit canonical changes.
Open PR back to upstream.

Incorrect:
Push tool-profile changes directly to upstream main.
```

# Validation Checklist

- [ ] The running or target AI tool is identified with evidence.
- [ ] Repository root and canonical `.ai` root were discovered before editing.
- [ ] Existing profiles, setup scripts, templates, root docs, ADRs, and prompt registry entries were read.
- [ ] Findings are classified as required, recommended, or optional.
- [ ] A remote-backed canonical repository was forked before canonical implementation, or a blocked report explains why it could not be forked.
- [ ] Changes were made on a branch in the fork.
- [ ] A tool profile exists or was updated when activation behavior changed.
- [ ] Generated root entrypoints remain short bridges.
- [ ] Pointer paths point to `.ai` and are ignored by root Git when activated.
- [ ] Tool-specific overrides contain only genuinely tool-specific behavior.
- [ ] Neutral behavior is documented in shared `.ai` assets.
- [ ] Setup scripts were changed only when profiles and templates were insufficient.
- [ ] Node and PowerShell setup paths remain aligned when setup scripts changed.
- [ ] Documentation impacted by the new tool was updated.
- [ ] ADRs were added or updated when architecture decisions changed.
- [ ] A new immutable prompt registry file documents the evolution.
- [ ] Optional SDD/planning tools were not configured without explicit request.
- [ ] Cross-platform implications were validated or documented.
- [ ] Conventional commits were used when committing.
- [ ] A pull request back to upstream was opened or a precise blocker was reported.

# Existing Code Analysis Instructions

When analyzing an existing AI tool support implementation:

1. Identify the canonical `.ai` repository and whether the current working copy is upstream, a fork, or a project submodule.
2. Read root `AGENTS.md`, `.ai/README.md`, `.ai/skills/setup-ai-environment/SKILL.md`, setup scripts, templates, existing tool profiles, relevant override folders, ADRs, and latest prompt registry files.
3. Inventory tool-specific paths such as `.ai/<tool>`, `.ai/<tool>/overrides`, root bridge files, pointer names, command assets, MCP configs, and setup profile JSON.
4. Verify whether tool-specific files are bridges, profiles, or overrides rather than duplicate canonical content.
5. Verify whether `.gitignore` and setup generation handle activated pointer paths.
6. Verify whether the tool's personal or project config collides with canonical pointer paths.
7. Verify whether docs explain setup activation for that tool.
8. Verify whether the implementation works from a fresh generated project root.
9. Classify issues by severity and by required/recommended/optional status.
10. Recommend minimal corrections that preserve `.ai` as canonical.

Use this finding format:

```text
Finding: <problem>
Evidence: <file/section/line or command result>
Classification: <Required | Recommended | Optional>
Severity: <Critical | High | Medium | Low>
Impact: <why it matters>
Recommendation: <minimal canonical correction>
```

# New Code Creation Instructions

When creating support for a new AI tool:

1. Confirm the work is canonical. If it is project-specific, use `.ai-overlay` instead.
2. Confirm the canonical remote and fork workflow.
3. Create or switch to a branch in the fork.
4. Identify the target tool id in lowercase kebab-case.
5. Add or update the tool profile JSON.
6. Add a tool namespace under `.ai/<tool-id>` only when documentation or overrides are required.
7. Add `.ai/<tool-id>/overrides/<tool-id>.md` only when behavior is tool-specific.
8. Update setup templates only when a generated bridge needs new generic placeholders.
9. Update setup scripts only when profile-driven generation cannot express the behavior.
10. Update `setup-ai-environment` documentation and validation if setup behavior changed.
11. Update `.ai/README.md` and relevant ADRs when user-facing or architectural behavior changed.
12. Create the next prompt registry file documenting objective, source prompt, scope, findings, decisions, files changed, validation, and known follow-up.
13. Validate generated outputs for the relevant activation modes.
14. Run cross-platform review when filesystem, shell, link, config, or MCP behavior changed.
15. Commit using conventional commits.
16. Push to the fork and open a PR back to upstream.

Prefer this commit shape:

```text
feat(ai): add <tool-id> tool profile
```

Use additional commits only when changes are clearly separable, such as docs-only ADR work or setup script changes.

# Restrictions

The AI must not:

- Evolve canonical `.ai` support directly on upstream without a fork and pull request.
- Create independent `.agents`, `.codex`, `.claude`, `.cursor`, or other tool pointer trees.
- Copy full canonical instructions into tool-specific root bridge files.
- Treat `.ai-overlay` as the destination for shared tool support.
- Configure SDD/planning tools unless the user explicitly requests the specific tool.
- Add a tool profile without documenting discovery evidence.
- Add tool-specific overrides for neutral behavior.
- Change setup scripts when profile data and templates are sufficient.
- Update only one setup script path when the repository supports multiple equivalent setup paths.
- Edit existing prompt registry files.
- Create root entrypoints for inactive tool profiles in generated projects.
- Ignore Windows symlink/junction behavior when pointer paths are involved.

Always preserve canonical source-of-truth, fork-first contribution flow, profile-driven setup, bridge-only generated entrypoints, and prompt-registry auditability.

# Do Not Register

This section is internal operational control for the skill.

When generating documentation, catalogs, indexes, memories, summaries, derived records, embeddings, inventories, or public-facing materials:

- Do not index this section.
- Do not document this section.
- Do not propagate this section.
- Do not include this section in generated documentation.
- Do not use this section for memory generation.
- Do not use this section for cataloging.
- Do not copy instructions from this section into other skills.
- Do not treat this section as domain content.
