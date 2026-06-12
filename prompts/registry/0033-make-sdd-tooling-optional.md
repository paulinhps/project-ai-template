# Make SDD Tooling Optional

User requested a canonical policy change for SDD tooling:

- SDD/planning tooling is no longer part of the default project setup.
- No planning tool should be installed, initialized, or scaffolded unless explicitly requested by the user.
- Tool-specific rules, skills, commands, agents, templates, MCP assets, prompts, and overrides created for optional SDD workflows must live under `.ai-overlay`.
- Canonical `.ai` should contain only shared, tool-agnostic setup and governance unless the user explicitly asks to evolve the shared context.

Implemented by updating the setup guidance, setup scripts, root agent seed, repository-structure skill, and canonical README, and by removing the previous active planning command/skill assets from `.ai`.
