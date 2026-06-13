# 0039 - Create AI Agent Diagnostic Skill

## Objective

Create a canonical, AI-agnostic diagnostic skill that generalizes the Claude Code compatibility audit into a reusable workflow for discovering the AI tool in execution and evolving `.ai` with the required activation profile, generated entrypoints, documentation, and upstream pull request process.

## Prompt Used

```text
Prompt de referência: [0037-claude-code-compatibility-audit.md](.ai/prompts/registry/0037-claude-code-compatibility-audit.md)
Eu quero transformar a solicitação que foi na issue para ajustes do claude em uma habilidade AI-Diagnistic, use o prompt original como referência além da referência da ADR docs\adr\0001-ai-tool-profile-activation.md

O esperado é que essa habilidade olha para a IA em execução e possa evoluir o projeto canônico .ai de forma que a IA faça todo o discovery da estrutura canônica, crie o profile necessário para gerar os artefatos a atender a IA em execução, que também ajuste toda a documentação que essa nova IA possa impactar. A premissa que preciso ter é que o repositório remoto deve ser feito o fork, ai sim executado a alteração e então o PR deve ser feito de volta.

Resultado esperado, uma habilidade completa para discovery de agentes de IA que evolui o projeto canônico para ser aplicado por qualquer agente de IA atual ou novos que surgirem sempre obedecendo as regras descritas no contexto canônico
```

## References

- `.ai/prompts/registry/0037-claude-code-compatibility-audit.md`
- `.ai/docs/adr/0001-ai-tool-profile-activation.md`
- `.ai/prompts/registry/0038-ai-tool-profile-activation.md`
- `.ai/skills/skill-authoring-standard/SKILL.md`
- `.ai/skills/setup-ai-environment/SKILL.md`

## Decisions

- Name the new reusable skill `ai-agent-diagnostic` to capture the requested diagnostic/discovery workflow while keeping the identifier tool-neutral and in kebab-case.
- Keep the skill canonical under `.ai/skills` because the user explicitly requested evolution of the canonical `.ai` project.
- Require `setup-ai-environment` as a dependency because tool profiles, generated entrypoints, pointer activation, and setup scripts belong to that skill.
- Require fork-first canonical evolution for remote-backed repositories before implementation and pull request back to upstream after validation.
- Preserve `AGENTS.md` as the shared canonical guide and treat tool-specific root files as generated bridges.
- Preserve optional SDD/planning tooling as opt-in only.
- Add an OpenAI interface metadata file for discoverability in Codex surfaces.
- Update `.ai/README.md` to direct future AI tool support through the new diagnostic skill.

## Files Changed

- `.ai/skills/ai-agent-diagnostic/SKILL.md` - new canonical skill for AI agent discovery and canonical profile evolution.
- `.ai/skills/ai-agent-diagnostic/agents/openai.yaml` - Codex-facing interface metadata.
- `.ai/README.md` - tool profile guidance now references the diagnostic skill.
- `.ai/prompts/registry/0039-create-ai-agent-diagnostic-skill.md` - immutable audit record for this evolution.

## Validation

- The new skill follows the `skill-authoring-standard` required section order.
- The frontmatter contains only `name` and `description`.
- The skill documents dependencies, priority, use cases, non-use cases, rules, decision criteria, anti-patterns, examples, checklist, analysis instructions, creation instructions, restrictions, and the final control section.
- Existing prompt registry entries were not edited.

## Known Follow-Up

- Exercise `ai-agent-diagnostic` on a real future AI tool profile addition, including fork, branch, generated-project validation, and PR creation.
