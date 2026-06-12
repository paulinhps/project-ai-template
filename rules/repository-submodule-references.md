# Repository Submodule References Rule

AI agents must use this rule whenever they initialize or inspect repository references owned by the AI workspace root.

The root repository is an orchestration repository. It tracks AI governance, global documentation, source-module references, and reproducible pointers. It must not vendor copied AI context or application source code by default.

## Reference Modes

Use separate decision models for `.ai` and for every `sources/<module>` project.

### Manual Or Copied `.ai` Context

When `.ai` exists but is not a Git repository:

- Treat it as local working context.
- Do not register it as a submodule.
- Add `.ai/` to the root `.gitignore`.
- Report that the directory is local-only and will not be reproduced by cloning the root repository.

### Local Git `.ai` Repository

When `.ai` is a Git repository:

- Treat it as a local bootstrap repository.
- It may be kept ignored from the root repository, or it may be registered as a local submodule when the project owner explicitly chooses that mode.
- If registered locally, use a local URL only as a local bootstrap reference.
- If it has `origin`, prefer registering `.ai` as a submodule using the remote URL.

### Git Repository With Remote URL

When `.ai` has `origin`, or when the user provides a remote repository URL:

- Register it as a Git submodule of the root repository.
- Use the remote URL in `.gitmodules`.
- Commit the submodule gitlink from the root repository only after the referenced `.ai` commit has been pushed to its remote.
- Keep AI-context commits inside the `.ai` repository itself.

## `.ai` Rules

`.ai` is the canonical AI context. It has three allowed modes:

- Downloaded/copied `.ai` without Git metadata: ignore `.ai/` in the root repository.
- Local `.ai` Git repository: either ignore `.ai/` or register it as a local submodule by explicit project decision.
- Remote-backed `.ai` Git repository: register `.ai` as a submodule using the remote URL.

Do not use `./.ai` as the final `.gitmodules` URL for reusable projects when `.ai` has a remote `origin`.

## `sources` Rules

Application source code must live under `sources/`, and each project must own its own repository lifecycle.

- Every source project under `sources/<module>` must be a Git submodule of the root repository.
- If the source repository has `origin`, `.gitmodules` must use the remote URL.
- If the source repository does not have `origin`, `.gitmodules` must use a local URL for that module.
- The root repository commits `.gitmodules` and submodule gitlinks for all source projects.
- For remote-backed source projects, commit or update the root gitlink only after the referenced source commit has been pushed to its remote.
- For local source projects without `origin`, a root gitlink can point to a local commit, but the root repository is not portable until that module gets a remote and `.gitmodules` is migrated.
- Source code commits happen inside `sources/<module>` repositories.

## Gitlink Publication Rule

A gitlink is the root repository entry that stores the exact commit expected for a submodule path. Git records it with mode `160000`.

For any submodule with a remote URL:

1. Commit changes inside the submodule repository.
2. Push the submodule commit to its remote.
3. Verify the pushed commit is reachable from the configured remote.
4. Only then stage the submodule path from the root repository to update the gitlink.

Do not commit a root gitlink that points to an unpublished commit in a remote-backed submodule. A clean clone of the root repository would not be able to fetch that commit.

For any submodule without `origin`:

- The gitlink may point to the local commit as a local bootstrap state.
- Report that the root repository is local-only for that module.
- Migrate to a remote-backed submodule before expecting another machine to reproduce the root repository.

## Migration

To migrate a local source submodule to a remote-backed submodule:

1. Verify the local repository is clean.
2. Add or confirm `origin`.
3. Push the local repository to its remote.
4. Replace the local URL in `.gitmodules` with the remote URL.
5. Synchronize submodule configuration.
6. Commit the `.gitmodules` update and submodule gitlink in the root repository.

Never migrate by overwriting, deleting, or flattening an existing local repository automatically.

## Validation

When validating a root repository:

- Inspect every direct child under `sources/`.
- Verify each source project is a Git repository.
- Verify each source project is listed in `.gitmodules`.
- If a source project has `origin`, verify `.gitmodules` uses that remote URL.
- If a source project has `origin`, verify the root gitlink commit is reachable from that remote.
- If a source project has no `origin`, verify `.gitmodules` uses a local URL.
- Report and correct local `.gitmodules` source URLs when a remote `origin` becomes available.
