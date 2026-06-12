# MCP

Shared MCP assets for servers, configs, prompts, and skills.

MCP assets must document:

- Runtime command and package manager.
- Required environment variables.
- Windows, Linux, and macOS path or quoting differences.
- Credential and network requirements.
- Whether a server can run from a project-relative path.

Do not add host-specific absolute paths to shared MCP configs. Prefer placeholders such as `<project-root>`, `${WORKSPACE_ROOT}`, or `${AI_HOME}`.
