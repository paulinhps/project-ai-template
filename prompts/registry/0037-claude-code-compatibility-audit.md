# 0037 - Claude Code Compatibility Audit

## Objective

Audit and minimally adjust the canonical AI structure so Claude Code users can discover, use, and replicate it, while preserving `.ai` as the single canonical source of truth. Resolves issue #1 ("Adaptar a estrutura canônica para compatibilidade com Claude Code").

## Prompt Used

```text
Você está trabalhando em um fork do repositório canônico de estrutura de IA.

Objetivo: auditar e ajustar a estrutura canônica para que ela funcione corretamente
para usuários do Claude Code, preservando o modelo compartilhado em `.ai`.

Antes de alterar arquivos, faça discovery completo do repositório.

Analise especialmente:
1. Como o Claude Code descobre instruções neste projeto.
2. Se existe ou deveria existir um `CLAUDE.md` na raiz.
3. Se `.claude` está corretamente tratado como ponteiro para `.ai`.
4. Se `.ai/claude/overrides` existe e está adequado para comportamento específico do Claude.
5. Se o fluxo OpenSpec `propose -> apply -> archive` está claro para Claude Code.
6. Se instruções específicas do Codex precisam de equivalente neutro ou específico para Claude.
7. Se a replicação por novos usuários Claude Code está documentada.
8. Se o comportamento em Windows com junctions/symlinks está claro.
9. Se há riscos de duplicação, divergência ou perda da fonte canônica.

Depois do discovery: liste os problemas, classifique (obrigatório/recomendado/opcional),
implemente apenas os ajustes mínimos, preserve a autoridade de `.ai`, use
`.ai/claude/overrides` só para comportamento específico do Claude, crie/atualize
`CLAUDE.md` apenas como ponte curta, e não duplique documentação extensa.

Versionar no prompt registry com o próximo número sequencial, documentando objetivo,
prompt, escopo, decisões, arquivos alterados e pendências.
```

## Scope Analyzed

- `README.md`, `AGENTS.md` seed, and `skills/setup-ai-environment` (SKILL.md, scripts, seeds).
- Tool-pointer model: `.codex`, `.claude`, `.agents` as junctions to `.ai`; `.gitignore` seed.
- `claude/overrides` and `codex/overrides` symmetry.
- `prompts/registry` numbering and immutability.
- Claimed OpenSpec `propose -> apply -> archive` flow (searched repo-wide).

Note: this repository **is** the canonical `.ai` content, so `.ai/<x>` in the issue maps to `<x>` at this repository root (for example `.ai/claude/overrides` = `claude/overrides`).

## Findings

Classified per the issue's scheme.

**Obrigatório**

1. No `CLAUDE.md` existed anywhere. Claude Code reads `CLAUDE.md` natively as memory and does not read `AGENTS.md` natively, so a Claude Code user opened the project (or this template) with no discovered context.
2. The `.claude` pointer collides with Claude Code's own project config directory. `.claude` is a junction to `.ai` and is gitignored, so Claude Code config written under project `.claude/` resolves into canonical `.ai` and is untracked. This needed explicit documentation and guidance.

**Recomendado**

3. The OpenSpec `propose -> apply -> archive` flow referenced by the issue does not exist in the repository. The canonical position is that SDD/OpenSpec tooling is optional and opt-in; this needed to be stated explicitly rather than implying a wired flow.
4. Codex/Claude override folders are already symmetric and largely neutral; no neutralization changes were required beyond documenting the Claude entry point.

**Opcional (not changed)**

5. `commands/` is referenced by `AGENTS.md`/`README.md` and is created by the setup scripts, but no `commands/` directory exists at this template root (only `agents/` and `templates/` carry placeholder READMEs). Left as-is to keep the change minimal; tracked here as a known inconsistency.

## Decisions

- Keep the `.claude` junction model unchanged (no independent `.claude` tree); document the Claude Code config collision and direct personal Claude Code config to user-level `~/.claude`. Decision confirmed with the project owner.
- Add a short root `CLAUDE.md` bridge (this template repository) and a seed `CLAUDE.md` for generated projects; bridges point to `AGENTS.md` and `.ai` and must not duplicate canonical content.
- Document Claude-specific behavior in canonical `claude/overrides/claude-code.md` (= `.ai/claude/overrides/claude-code.md`).
- Document OpenSpec as an optional, non-wired SDD flow rather than adding it. Decision confirmed with the project owner.
- No `.ai-overlay` changes: nothing here is project-specific.

## Files Changed

- `CLAUDE.md` (new) - root bridge for this canonical repository.
- `claude/overrides/claude-code.md` (new) - Claude Code discovery, `.claude` pointer/config collision, bootstrap/replication, Windows junctions, optional OpenSpec.
- `skills/setup-ai-environment/assets/seeds/CLAUDE.md` (new) - seeded root bridge for generated projects.
- `skills/setup-ai-environment/scripts/setup-ai-environment.mjs` - seed `CLAUDE.md` and stage it in the initial commit.
- `skills/setup-ai-environment/scripts/setup-ai-environment.ps1` - same wiring for the PowerShell path.
- `skills/setup-ai-environment/SKILL.md` - list the `CLAUDE.md` seed, add a root-file assertion, add a validation checklist item.
- `skills/setup-ai-environment/assets/seeds/AGENTS.md` - note Claude Code discovery via `CLAUDE.md`; note OpenSpec is optional.
- `README.md` - Claude Code discovery note, `CLAUDE.md` in the expected root shape, OpenSpec optional clarification.

## Known Pending / Risks

- The `commands/` directory inconsistency (finding 5) is left unresolved to keep the change minimal.
- The seed `CLAUDE.md` wiring was reviewed by reading the setup scripts; a full generated-project run on a host with symbolic-link privileges was not exercised as part of this audit.
- If a future project actually adopts an OpenSpec flow, register its assets under `.ai-overlay` per the optional-SDD rule; revisit this entry only if the flow becomes canonical.
