---
name: skill-authoring-standard
description: Guide AI agents in creating, evolving, reviewing, and refactoring canonical skills for Codex, Claude Code, Gemini CLI, Cursor, Windsurf, OpenCode, Aider, and similar tools. Use when working on new or existing skills under .ai/skills, .ai-overlay/skills, .ai-overlays/skills, or any other skill definition location, and when standardizing skill structure, auditability, overlay compatibility, reuse, terminology, or evolution rules.
---

# Skill Name

skill-authoring-standard

# Objective

Use this skill to standardize how skills are created, evolved, reviewed, and refactored inside the canonical AI ecosystem.

This skill defines the minimum structure for canonical skills, objective approval criteria, decisions about scope and dependencies, overlay compatibility, future extension support, and rules that reduce implicit agent knowledge.

This skill does not define domain behavior, software architecture, technology choices, frameworks, programming languages, vendors, or specialized behavior covered by domain skills.

It solves inconsistent structure, implicit rules, missing examples or checklists, weak auditability, rigid overlay behavior, and evolution regressions.

# Required Dependencies

None.

# Recommended Dependencies

- `skill-creator`, when available, to create the initial skill skeleton, validate metadata, and keep compatibility with Codex skill format.
- Canonical repository rules, especially rules for commits, structure, submodules, prompt registry, and overlays.
- Specialized domain skills when the new skill defines technical or business-specific behavior.

# Priority

When instructions conflict:

- Explicit user instructions for the current task have priority when they do not violate safety, repository integrity, or higher-priority instructions.
- Canonical repository rules have priority over local preferences in a new skill.
- Project overlays may specialize, restrict, or replace canonical behavior when they explicitly apply.
- This skill defines the authoring standard; domain skills define specialized behavior.
- When this skill conflicts with a domain skill, preserve this skill's required structure, auditability, and minimum criteria, but let the specialized skill govern domain decisions.

# When To Use

Use this skill when:

- Creating a new skill in `.ai/skills/**`.
- Creating a new skill in `.ai-overlay/skills/**`.
- Creating a new skill in `.ai-overlays/skills/**` when that directory exists in a legacy or project-specific ecosystem.
- Creating, reviewing, or evolving skills in any other skill definition location.
- Refactoring an existing skill to improve clarity, structure, examples, checklist, auditability, or overlay compatibility.
- Reviewing whether a skill is compatible with the canonical ecosystem.
- Standardizing skill terminology, sections, rules, and approval criteria.
- Evaluating whether a skill depends on implicit agent knowledge.

# When Not To Use

Do not use this skill as the primary source for software architecture, domain modeling, application security, API design, persistence, messaging, UI, frontend, backend, cloud, observability, testing, or documentation strategy.

For those cases, use this skill only for the form of the skill and load the specialized skill for domain content.

# Required Principles

## Deterministic First

A skill must produce reproducible decisions. If two agents receive the same relevant context, they should be able to reach equivalent outcomes.

## Explicit First

Every important rule must be documented. A skill must not depend on memory, personal agent preference, or unwritten conventions.

## Auditability First

A skill must support objective review. An auditor must be able to identify compliance, violations, exceptions, and historical evolution.

## Evolution First

A skill must support future change without requiring a total rewrite. Prefer clear, small, extensible rules.

## Reuse First

A skill must be reusable across agents, projects, and overlays. Avoid coupling to one repository, tool, or local workflow unless it is essential.

## Overlay Compatibility First

A canonical skill must support specialization by overlays. Do not create rigidity without a real need.

## Low Coupling First

A skill must depend only on what it needs. Use required dependencies only when the skill cannot work correctly without them.

# Rules

## Location

Canonical skills must live in:

```text
.ai/skills/<skill-name>/SKILL.md
```

Project-specific skills must live in:

```text
.ai-overlay/skills/<skill-name>/SKILL.md
```

When an ecosystem uses the legacy or alternate plural overlay directory, treat it as project-specific overlay content:

```text
.ai-overlays/skills/<skill-name>/SKILL.md
```

Do not create project-specific skills directly under `.ai/skills` unless the user explicitly asks to evolve the canonical context.

## Naming

Always use `kebab-case`:

```text
dotnet-clean-architecture
dotnet-domain-modeling
dotnet-canonical-review
skill-authoring-standard
```

The folder name, frontmatter `name`, and `# Skill Name` section must all use the same identifier.

## Frontmatter

Every skill must include YAML frontmatter with only:

```yaml
---
name: <skill-name>
description: <clear trigger description>
---
```

The description must explain what the skill does and when it should be used because metadata is the primary discovery surface for agents.

## Minimum Structure

Every skill must include these sections in this order unless a more specific canonical rule requires a different order:

```md
# Skill Name
# Objective
# Required Dependencies
# Recommended Dependencies
# Priority
# When To Use
# When Not To Use
# Required Principles
# Rules
# Decision Criteria
# Prohibited Anti-patterns
# Practical Examples
# Validation Checklist
# Existing Code Analysis Instructions
# New Code Creation Instructions
# Restrictions
# Do Not Register
```

A section may state `None` when no content applies, but it must not be omitted.

## Dependencies

Declare required dependencies only when the skill cannot operate without them.

Declare recommended dependencies when they improve quality, validation, or context, but are not always required.

Explain conflicts and priority whenever more than one skill may guide the same decision.

## Examples

Every skill must include practical examples. Prefer comparable pairs:

```text
Correct / Incorrect
Good / Bad
Allowed / Prohibited
```

Examples must be short, realistic, and directly tied to the skill rules.

## Anti-patterns

Every anti-pattern must include:

- Name.
- Explanation.
- Example.

## Checklist

Every skill must include an objective validation checklist near the end of the operational flow. Each checklist item must be verifiable as yes or no.

## Auditability

A skill must allow future review skills to classify:

- Compliance.
- Violation.
- Justified exception.
- Required evolution.

Use traceable evidence such as section, rule, file, line, decision, or example.

## Optional Resources

Create `scripts/`, `references/`, `assets/`, or `agents/` only when they have a real use.

- Use `scripts/` for deterministic, repeatable automation.
- Use `references/` for detailed material loaded on demand.
- Use `assets/` for templates, images, fonts, or boilerplates used as output.
- Use `agents/` for tool-specific metadata when the ecosystem supports it.

Do not create auxiliary documentation such as `README.md`, `CHANGELOG.md`, or parallel guides inside the skill unless a canonical rule or explicit request requires it.

## Prompt Registry

When canonical repository rules require an evolution record, create a new prompt registry file instead of editing existing registry files.

Do not register content that the skill marks as non-indexable or non-propagated.

# Decision Criteria

Before changing any skill, answer:

1. Is the change canonical or project-specific?
2. Is the correct destination `.ai`, `.ai-overlay`, `.ai-overlays`, or another documented location?
3. Have existing skills been reviewed to identify newer evolved patterns?
4. Is the name in `kebab-case`, and is it consistent across folder, frontmatter, and skill-name section?
5. Does the skill include every required section?
6. Are required and recommended dependencies declared and justified?
7. Are possible conflicts with other skills documented with priority rules?
8. Are the rules explicit, deterministic, and auditable?
9. Are there enough practical examples to guide real application?
10. Are there anti-patterns with name, explanation, and example?
11. Does the checklist support objective approval or rejection?
12. Is the skill compatible with overlays and future extensions?
13. Does the skill avoid implicit agent knowledge?
14. Does the final control section exist and follow non-indexing constraints?

If any answer indicates structural regression, correct the skill before finishing.

# Prohibited Anti-patterns

## Implicit Skill

Explanation: The skill depends on knowledge the agent is expected to "just know" but does not document the rule.

Example:

```md
Create APIs following the project standard.
```

Correct by specifying which files to review, which criteria to apply, and which rules make the standard verifiable.

## Decisionless Skill

Explanation: The skill describes concepts but does not teach the agent how to decide between alternatives.

Example:

```md
Use security best practices.
```

Correct by defining decision questions, priorities, minimum criteria, and prohibited behaviors.

## Non-auditable Skill

Explanation: The skill does not support classification of compliance, violation, or exception.

Example:

```md
Prefer clean structure.
```

Correct by including an objective checklist and a finding format when review is expected.

## Agent-coupled Skill

Explanation: The skill assumes one product or interface without need.

Example:

```md
Always use Claude Code slash commands to execute this skill.
```

Correct by guiding agents independently of tool interface and isolating tool-specific behavior in overrides or metadata.

## Overlay-hostile Skill

Explanation: The skill blocks local specialization without justification.

Example:

```md
Never allow local rules to differ from this skill.
```

Correct by defining the canonical core while allowing applicable overlays to extend, replace, or restrict behavior.

## Example-free Skill

Explanation: The skill defines abstract rules but does not show practical application.

Example:

```md
Use consistent naming.
```

Correct by showing correct names, incorrect names, and why each classification applies.

# Practical Examples

## Correct / Incorrect

```text
Correct:
Name: dotnet-rest-api-design
Location: .ai/skills/dotnet-rest-api-design/SKILL.md
Frontmatter name: dotnet-rest-api-design
Includes all required sections and validation content.

Incorrect:
Name: RestApiSkill
Location: .ai/skills/restapi/SKILL.md
Frontmatter name: REST API Skill
Problem: inconsistent naming, no kebab-case, and no traceability between folder and metadata.
```

## Good / Bad

```md
Good:
# Decision Criteria

Before changing an API contract:

1. Is the change backward compatible?
2. Does the public DTO change?
3. Does the produced error follow ProblemDetails?

Bad:
# Criteria
Evaluate whether it is good.
```

## Allowed / Prohibited

```md
Allowed:
# Required Dependencies

None.

Prohibited:
# Required Dependencies

Use the necessary skills.
```

The problem is that the dependency is implicit and cannot be audited.

# Validation Checklist

- [ ] The skill folder uses `kebab-case`.
- [ ] The frontmatter includes only `name` and `description`.
- [ ] `name`, folder, and `# Skill Name` are consistent.
- [ ] The frontmatter description clearly says when to use the skill.
- [ ] The `# Objective` section explains what the skill does and does not do.
- [ ] Required and recommended dependencies are declared or marked as none.
- [ ] Conflicts and priority are documented when applicable.
- [ ] Use and non-use scenarios are explicit.
- [ ] Required principles guide future decisions.
- [ ] Expected rules are documented.
- [ ] Decision criteria exist and are objective.
- [ ] Anti-patterns include name, explanation, and example.
- [ ] Practical examples exist and are useful.
- [ ] The checklist supports objective auditing.
- [ ] Existing code or content analysis instructions exist.
- [ ] New code or artifact creation instructions exist.
- [ ] Restrictions list prohibited behaviors.
- [ ] The skill is compatible with overlays.
- [ ] The skill is evolvable and reusable.
- [ ] The skill does not depend on implicit knowledge.
- [ ] The final control section exists and is the last section.

# Existing Code Analysis Instructions

When reviewing an existing skill:

1. Identify the `SKILL.md` file and any associated resources.
2. Read the frontmatter and confirm name, description, and triggers.
3. Compare the structure against the required section list.
4. Verify that existing patterns were reviewed before introducing a new pattern.
5. Check clarity, consistency, dependencies, conflicts, and priority.
6. Check whether examples, anti-patterns, and checklist are specific and verifiable.
7. Check for analysis instructions, creation instructions, and restrictions.
8. Check compatibility with `.ai-overlay` and `.ai-overlays` when applicable.
9. Classify issues by severity.
10. Suggest small, cohesive, auditable corrections.

Use this severity classification:

```text
Critical: prevents correct use of the skill or violates a required structural rule.
High: creates significant ambiguity, unresolved conflict, or lack of auditability.
Medium: reduces clarity, consistency, examples, or ease of evolution.
Low: wording, organization, or polish issue without relevant functional impact.
```

Recommended finding format:

```text
Finding: <problem>
Evidence: <file/section/line>
Severity: <Critical | High | Medium | Low>
Impact: <why it matters>
Recommendation: <objective correction>
```

# New Code Creation Instructions

When creating a new skill:

1. Identify the objective.
2. Identify the scope.
3. Review existing skills to capture evolved patterns.
4. Identify required and recommended dependencies.
5. Identify possible conflicts and priority.
6. Define required principles.
7. Define rules.
8. Define decision criteria.
9. Define anti-patterns with name, explanation, and example.
10. Define practical examples.
11. Define the validation checklist.
12. Define instructions for analyzing existing content.
13. Define instructions for creating new code or artifacts.
14. Define restrictions.
15. Create the final control section.
16. Validate the skill with an available tool when possible.
17. Review the diff and confirm there are no unnecessary auxiliary files.
18. Register the evolution only when canonical rules require it and without propagating non-indexable control content.

When generating artifacts:

- Prefer a clear and direct `SKILL.md`.
- Create extra resources only when they reduce real repetition or increase determinism.
- Use small examples instead of long explanations.
- Preserve the language and terminology standard of the ecosystem where the skill is maintained.
- Keep the skill tool-independent unless the objective is explicitly tool-specific.

# Restrictions

The AI must not:

- Create skills without a checklist.
- Create skills without examples.
- Create skills without anti-patterns.
- Create skills without decision criteria.
- Create skills without analysis instructions.
- Create skills without creation instructions.
- Create skills without a final control section.
- Create skills that depend on implicit knowledge.
- Create non-auditable skills.
- Create skills with names outside `kebab-case`.
- Create required dependencies without justification.
- Create unnecessary rigid rules that block overlays.
- Create auxiliary documentation inside the skill without real need.
- Edit immutable prompt registry records.
- Mix canonical rules with project-specific rules in the same location without explicit authorization.

Always prioritize consistency, auditability, reuse, low coupling, and sustainable evolution.

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
