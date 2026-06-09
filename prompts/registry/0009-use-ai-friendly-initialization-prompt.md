# Use AI-Friendly Initialization Prompt

Updated the new-project setup guidance so the main initialization step asks an AI agent to execute the setup skill instead of telling the user to run the setup script directly.

The documented prompt is:

```text
inialize project using .ai\skills\configurar-ambiente-ai\SKILL.md skill
```

The setup skill remains responsible for the full project initialization, including root Git initialization, root files and directories, tool links, OpenSpec initialization, `.ai` submodule/gitlink registration, and the initial root commit.

This change updates `.ai/README.md`, the `configurar-ambiente-ai` skill instructions, and the seed `AGENTS.md`.
