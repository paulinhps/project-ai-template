---
name: source-module-setup
description: Create, clone, initialize, validate, and register isolated application source modules under sources/. Use when an AI agent needs to set up an existing remote repository, create a new local source repository, register a Git submodule, inspect an existing source directory, validate Git repository state, or repair source-module setup without violating root repository source isolation.
---

# Source Module Setup

Use this skill to create and manage application source modules while preserving the repository's Source Isolation Architecture.

## Core Rule

Application source code must live under `sources/`. The root repository is an orchestration, documentation, and AI context repository; it is not an application source repository.

Valid module paths:

```text
sources/backend
sources/frontend
sources/mobile
sources/infrastructure
```

Invalid module paths:

```text
backend
frontend
mobile
src
```

Stop before creating application code outside `sources/`.

## Architectural Rules

### Rule 1: Root Source Isolation

Application source code must not be created directly in the root repository. Only create source modules under `sources/`.

### Rule 2: Independent Source Repositories

Every source module must be an independent Git repository with its own Git metadata, README, branches, commits, and remote `origin` when a remote exists. A new local repository may temporarily lack `origin`, but the agent must report `remote origin pending`.

### Rule 3: Remote Repositories Become Submodules

When `remote_repository` is provided and `register_submodule` is true, configure the module as a Git submodule:

```bash
git submodule add <remote-repository-url> sources/<module-name>
```

### Rule 4: New Local Repositories Are Bootstrapped Independently

When no `remote_repository` is provided, create a standalone Git repository under `sources/<module-name>`, generate `README.md` when requested, and create the first commit. Leave it ready for future remote configuration.

### Rule 5: Existing Repositories Require Verification

Never overwrite existing repositories or directories without verification. Before executing actions, validate root status, target existence, Git metadata, remote configuration, and submodule registration.

## Required Inputs

Accept these logical inputs from the user or infer them only when unambiguous:

```yaml
module_name:
  description: Logical name of the source module.

target_path:
  description: Destination path.
  default: sources/<module_name>

remote_repository:
  description: Optional remote repository URL.

initialize_readme:
  description: Create a default README.md for new local repositories.
  default: true

register_submodule:
  description: Register as a Git submodule when possible.
  default: true
```

Normalize `module_name` to a lowercase, path-safe directory name unless the user provides an explicit `target_path`.

## Invariants

Enforce these invariants for every module:

- The module path is inside `sources/`.
- The module is an independent Git repository.
- The module has its own README, branches, commits, and repository history.
- The module has a remote `origin` when a remote repository exists.
- New local modules without a remote are allowed only as a bootstrap state; report `remote origin pending`.
- Remote-backed modules should be registered as Git submodules of the root repository whenever possible.
- Existing repositories and submodules must never be overwritten automatically.

## Mandatory Preflight

Run preflight from the root repository before modifying anything:

```bash
git status --short
test -d sources
test -d <target-path>
test -d <target-path>/.git
test -e <target-path>/.git
git submodule status --recursive
git config -f .gitmodules --get-regexp 'submodule\..*\.path' || true
```

PowerShell equivalents:

```powershell
git status --short
Test-Path -LiteralPath sources -PathType Container
Test-Path -LiteralPath <target-path> -PathType Container
Test-Path -LiteralPath <target-path>/.git -PathType Container
Test-Path -LiteralPath <target-path>/.git
git submodule status --recursive
git config -f .gitmodules --get-regexp 'submodule\..*\.path'
```

Treat either a `.git` directory or a `.git` file as evidence of a Git worktree. Git submodules commonly use a `.git` file that points into the root repository's `.git/modules/` directory.

Also inspect the target directly when it exists:

```bash
git -C <target-path> status --short
git -C <target-path> remote -v
git -C <target-path> branch --show-current
git -C <target-path> log --oneline -n 3
```

## Decision Matrix

Use this deterministic selection order:

1. If `target_path` is outside `sources/`, stop and report that it violates source isolation.
2. If `target_path` exists, run Flow C and stop before modifying it.
3. If `remote_repository` is provided and `register_submodule` is true, run Flow A.
4. If `remote_repository` is provided and submodule registration is not possible, explain why and ask before cloning directly.
5. If no `remote_repository` is provided, run Flow B.

## Flow A: Existing Remote Repository

Input:

```yaml
module_name: backend
remote_repository: https://github.com/example/backend.git
```

Expected behavior:

```bash
mkdir -p sources
git submodule add https://github.com/example/backend.git sources/backend
git submodule update --init --recursive
```

Expected result:

```text
sources/backend created
.gitmodules updated
submodule registered
remote origin configured
```

After registration, verify:

```bash
git submodule status --recursive
git config -f .gitmodules --get-regexp 'submodule\..*\.path'
git -C sources/backend remote -v
git -C sources/backend status --short
```

If the submodule add fails because the path already exists, do not force it. Run Flow C.

## Flow B: New Local Repository

Input:

```yaml
module_name: backend
```

Expected behavior:

```bash
mkdir -p sources/backend
cd sources/backend
git init
echo "# Backend" > README.md
git add README.md
git commit -m "chore: initialize backend repository"
cd ../..
```

PowerShell equivalent:

```powershell
New-Item -ItemType Directory -Force -Path sources/backend
Set-Location sources/backend
git init
Set-Content -Path README.md -Value "# Backend"
git add README.md
git commit -m "chore: initialize backend repository"
Set-Location ../..
```

Expected result:

```text
Independent repository created
README generated
Initial commit generated
remote origin pending
```

After creation, verify:

```bash
git -C sources/backend status --short
git -C sources/backend log --oneline -n 1
git -C sources/backend remote -v
```

Report that future remote configuration should use:

```bash
git -C sources/backend remote add origin <remote-repository-url>
```

After a remote is added later, register the module as a submodule only through an explicit migration plan.

## Flow C: Existing Directory or Repository Validation

If `target_path` already exists, stop and inspect before modifying anything.

Determine and report:

```text
Target path
Is directory empty?
Is Git initialized?
Is .git a directory or file?
Does remote origin exist?
Is it already a submodule?
Is it referenced in .gitmodules?
Does the module have uncommitted changes?
What branch or detached commit is checked out?
What is the latest commit?
```

Useful commands:

```bash
test -d <target-path>
find <target-path> -mindepth 1 -maxdepth 1
test -e <target-path>/.git
git -C <target-path> status --short
git -C <target-path> remote -v
git -C <target-path> branch --show-current
git -C <target-path> rev-parse --is-inside-work-tree
git -C <target-path> rev-parse HEAD
git submodule status --recursive
git config -f .gitmodules --get-regexp 'submodule\..*\.path'
```

PowerShell alternatives:

```powershell
Test-Path -LiteralPath <target-path> -PathType Container
Get-ChildItem -Force -LiteralPath <target-path>
Test-Path -LiteralPath <target-path>/.git
git -C <target-path> status --short
git -C <target-path> remote -v
git -C <target-path> branch --show-current
git -C <target-path> rev-parse --is-inside-work-tree
git -C <target-path> rev-parse HEAD
git submodule status --recursive
git config -f .gitmodules --get-regexp 'submodule\..*\.path'
```

Do not continue until the user confirms the next action if any change could overwrite, replace, reinitialize, or detach existing work.

## Safety Requirements

Never:

- Delete repositories automatically.
- Remove `.git` folders or `.git` files automatically.
- Reinitialize existing repositories automatically.
- Replace an existing submodule automatically.
- Force-push any repository.
- Move application source code into the root repository.
- Convert an existing directory into a submodule without reporting findings first.

Always:

- Inspect current state first.
- Report findings before modifying existing directories.
- Explain intended actions.
- Preserve user work and uncommitted changes.
- Request explicit confirmation before destructive or history-changing actions.
- Prefer `git submodule add` for remote-backed modules.
- Keep root repository commits separate from module repository commits.

## Submodule Lifecycle

### Creation

Use when the remote repository exists and the target path does not:

```bash
mkdir -p sources
git submodule add <remote-repository-url> sources/<module-name>
git submodule update --init --recursive
```

Commit the root repository metadata separately:

```bash
git add .gitmodules sources/<module-name>
git commit -m "chore: add <module-name> source submodule"
```

### Registration

Use when a valid repository already exists at the target and must be registered as a submodule. This is a migration, not a default action. Stop, report findings, and request confirmation before proceeding.

Preferred clean path:

```bash
git submodule add <remote-repository-url> sources/<module-name>
git submodule update --init --recursive
```

If the directory already exists, do not force registration. Plan a manual migration that preserves the existing repository and root state.

### Synchronization

Use after `.gitmodules` URL changes or when local submodule configuration may be stale:

```bash
git submodule sync --recursive
git submodule update --init --recursive
```

### Update

Use to fetch the commit recorded by the root repository:

```bash
git submodule update --init --recursive
```

Use to advance the submodule intentionally:

```bash
git -C sources/<module-name> fetch origin
git -C sources/<module-name> checkout <branch-or-commit>
git -C sources/<module-name> pull --ff-only
git add sources/<module-name>
git commit -m "chore: update <module-name> source submodule"
```

### Removal

Submodule removal is destructive to local checkout state. Do not perform it automatically. After explicit confirmation and backup, a typical removal plan is:

```bash
git submodule deinit -f sources/<module-name>
git rm -f sources/<module-name>
git commit -m "chore: remove <module-name> source submodule"
```

Then inspect `.git/modules/sources/<module-name>` and remove leftover metadata only with explicit user approval.

### Migration

Use migration when converting a local repository to a remote-backed submodule:

1. Verify the local repository is committed and clean.
2. Add or confirm `origin`.
3. Push the local repository to the remote.
4. Preserve or back up the local directory.
5. Remove or relocate the local checkout only with explicit confirmation.
6. Add the remote as a submodule with `git submodule add`.
7. Verify `.gitmodules`, submodule status, and checked-out commit.
8. Commit root repository metadata.

Never migrate by deleting or overwriting the existing local repository without confirmation.

## Troubleshooting

### `target path already exists`

Run Flow C. Common outcomes:

- Empty directory: ask whether to remove it, use it for a new local repository, or choose another module name.
- Existing non-Git directory: stop and ask whether it should become a repository.
- Existing Git repository: report origin, branch, status, and whether it is already a submodule.
- Existing submodule: run sync/update commands instead of adding it again.

### `.gitmodules` references the path but checkout is missing

Use:

```bash
git submodule sync --recursive
git submodule update --init --recursive
```

### Submodule has detached HEAD

Detached HEAD is normal for submodules when they are checked out at the commit recorded by the root repository. If active development is needed inside the module, check out a branch inside the module repository:

```bash
git -C sources/<module-name> checkout <branch-name>
```

### Remote origin is missing

For bootstrap local repositories, report `remote origin pending`. Add a remote only when the user provides a URL:

```bash
git -C sources/<module-name> remote add origin <remote-repository-url>
```

### Root repository is dirty

Do not assume dirty root changes are related. Report the status and proceed only if the intended source-module operation will not overwrite or obscure existing work.

## Best Practices

- Use `sources/<module-name>` as the default path.
- Keep module names short, lowercase, and purpose-oriented, such as `backend`, `frontend`, `mobile`, or `infrastructure`.
- Use Conventional Commits for both root repository commits and module commits.
- Commit module repository changes inside the module first, then commit submodule pointer changes in the root repository.
- Keep `.gitmodules` tracked in the root repository.
- Do not vendor source repositories by copying their files into the root repository.
- Do not mix multiple application modules in one Git repository unless the user explicitly chooses a monorepo module under `sources/`.
- Prefer explicit reports over silent repair when repository state is ambiguous.
