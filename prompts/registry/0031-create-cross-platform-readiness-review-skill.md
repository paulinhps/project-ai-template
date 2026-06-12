# Create Cross Platform Readiness Review Skill

## Prompt

Create a canonical `.ai` skill for a cross-platform readiness review of the AI project structure.

The skill must guide agents to audit the entire repository, especially `.ai/rules`, `.ai/skills`, `.ai/commands`, `.ai/agents`, `.ai/templates`, `.ai/workflows`, `.ai/docs`, scripts, tools, automation, README, and docs.

The audit must identify Windows, Linux, and macOS portability risks, including hardcoded paths, directory separators, shell-specific commands, Git symlink and junction assumptions, environment variables, encoding and line endings, configuration files, agents, skills, commands, MCPs, external tools, Docker, DevContainer, and Codespaces readiness.

The skill must require an executive report with `Cross Platform Score: XX/100`, findings by severity, compatibility matrices, a prioritized correction plan, and a pull request plan.

## Result

Added `.ai/skills/cross-platform-readiness-review/SKILL.md` and `agents/openai.yaml`.

The skill defines the audit scope, required checks, scoring model, report format, remediation guidance, and approval criteria for making the canonical `.ai` ecosystem portable across Windows, Linux, and macOS.
