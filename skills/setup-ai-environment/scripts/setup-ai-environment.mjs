#!/usr/bin/env node

import { copyFileSync, existsSync, lstatSync, mkdirSync, readFileSync, readdirSync, symlinkSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";

const scriptPath = fileURLToPath(import.meta.url);
const scriptRoot = dirname(scriptPath);
const skillRoot = dirname(scriptRoot);
const assetRoot = join(skillRoot, "assets");
const seedRoot = join(assetRoot, "seeds");
const templateRoot = join(assetRoot, "templates");
const profileRoot = join(assetRoot, "tool-profiles");

const options = parseArgs(process.argv.slice(2));
const projectRoot = resolve(options.projectRoot ?? process.cwd());
const defaultBranch = options.defaultBranch ?? "main";
const initialCommitMessage = options.initialCommitMessage ?? "chore: initialize AI project environment";
const aiRepositoryUrl = options.aiRepositoryUrl ?? "";
const registerLocalAiSubmodule = Boolean(options.registerLocalAiSubmodule);
const skipInitialCommit = Boolean(options.skipInitialCommit);
const activeProfiles = resolveActiveProfiles(options.aiTool ?? "both");

if (!defaultBranch.trim()) {
  throw new Error("Default branch cannot be empty");
}

process.chdir(projectRoot);
step(`Configuring ${projectRoot}`);
step(`Activated AI tools: ${activeProfiles.map((profile) => profile.id).join(", ")}`);

if (!gitOk(["rev-parse", "--is-inside-work-tree"])) {
  step("Initializing root Git repository");
  initializeGitRepository(projectRoot);
}

const aiRoot = join(projectRoot, ".ai");
if (!existsSync(aiRoot)) {
  if (!aiRepositoryUrl) {
    throw new Error(".ai must exist before setup. Clone, download, or provide --ai-repository-url.");
  }
  runGit(["submodule", "add", aiRepositoryUrl, ".ai"]);
}

for (const dir of canonicalAiDirectories()) {
  ensureDirectory(join(aiRoot, dir));
}

for (const dir of [
  "docs/adr",
  "docs/architecture",
  "docs/business",
  "docs/decisions",
  "docs/engineering",
  "docs/product",
  "docs/references",
  "docs/requirements",
  "docs/specs",
  "sources",
]) {
  ensureDirectory(join(projectRoot, dir));
}

const overlayRoot = join(projectRoot, ".ai-overlay");
ensureDirectory(overlayRoot);
copySeedIfMissing("AI_OVERLAY_README.md", join(overlayRoot, "README.md"));

const gitignorePath = join(projectRoot, ".gitignore");
ensureAgentsFile(join(projectRoot, "AGENTS.md"), activeProfiles);
copyToolEntrypoints(activeProfiles);
copySeedIfMissing(".gitignore", gitignorePath);

for (const pointer of activePointerNames(activeProfiles)) {
  ensureLine(gitignorePath, `${pointer}/`);
  newDirectoryLink(join(projectRoot, pointer), aiRoot);
}

const aiRegisteredAsSubmodule = ensureAiSubmodule(projectRoot);

if (!skipInitialCommit) {
  const hasHead = gitOk(["rev-parse", "--verify", "HEAD"]);
  if (!hasHead) {
    step("Creating root initial commit");
    runGit(["add", ...initialCommitPaths(activeProfiles)]);
    if (existsSync(".gitmodules")) runGit(["add", ".gitmodules"]);
    if (aiRegisteredAsSubmodule) runGit(["add", ".ai"]);
    runGit(["commit", "-m", initialCommitMessage]);
  } else {
    step("Root repository already has commits; leaving commit creation to the user");
  }
}

step("Done");
runGit(["status", "--short"]);

function parseArgs(args) {
  const parsed = {};
  for (let i = 0; i < args.length; i += 1) {
    const arg = args[i];
    if (arg === "--register-local-ai-submodule") {
      parsed.registerLocalAiSubmodule = true;
    } else if (arg === "--skip-initial-commit") {
      parsed.skipInitialCommit = true;
    } else if (arg.startsWith("--")) {
      const key = arg.slice(2).replace(/-([a-z])/g, (_, c) => c.toUpperCase());
      parsed[key] = args[++i];
    }
  }
  return parsed;
}

function step(message) {
  console.log(`[ai-setup] ${message}`);
}

function run(command, args, opts = {}) {
  const result = spawnSync(command, args, { stdio: "inherit", shell: false, ...opts });
  if (result.status !== 0) {
    throw new Error(`${command} ${args.join(" ")} failed with exit code ${result.status}`);
  }
}

function capture(command, args, opts = {}) {
  return spawnSync(command, args, { encoding: "utf8", shell: false, ...opts });
}

function runGit(args) {
  run("git", args);
}

function gitOk(args) {
  const result = capture("git", args, { stdio: "ignore" });
  return result.status === 0;
}

function initializeGitRepository(path) {
  const result = capture("git", ["-C", path, "init", `--initial-branch=${defaultBranch}`], { stdio: "inherit" });
  if (result.status === 0) return;
  step("Git does not support init --initial-branch; falling back to branch rename");
  runGit(["-C", path, "init"]);
  runGit(["-C", path, "branch", "-M", defaultBranch]);
}

function ensureDirectory(path) {
  if (!existsSync(path)) {
    mkdirSync(path, { recursive: true });
  }
}

function ensureLine(path, line) {
  if (!existsSync(path)) writeFileSync(path, "", "utf8");
  const current = readFileSync(path, "utf8");
  const lines = current.split(/\r?\n/);
  if (!lines.includes(line)) {
    const suffix = lines.at(-1) === "" ? "" : "\n";
    writeFileSync(path, `${current}${suffix}${line}\n`, "utf8");
  }
}

function removeLine(path, line) {
  if (!existsSync(path)) return;
  const lines = readFileSync(path, "utf8").split(/\r?\n/);
  const filtered = lines.filter((current) => current !== line);
  if (filtered.length !== lines.length) {
    writeFileSync(path, filtered.join("\n"), "utf8");
  }
}

function copySeedIfMissing(seedName, destinationPath) {
  if (existsSync(destinationPath)) return;
  const seedPath = join(seedRoot, seedName);
  if (!existsSync(seedPath)) throw new Error(`Missing seed file: ${seedPath}`);
  ensureDirectory(dirname(destinationPath));
  copyFileSync(seedPath, destinationPath);
  step(`Created ${destinationPath.split(/[\\/]/).at(-1)} from seed`);
}

function writeRenderedIfMissing(templateName, destinationPath, values) {
  if (existsSync(destinationPath)) return;
  const text = renderTemplate(templateName, values);
  ensureDirectory(dirname(destinationPath));
  writeFileSync(destinationPath, text, "utf8");
  step(`Created ${destinationPath.split(/[\\/]/).at(-1)} from template`);
}

function renderTemplate(templateName, values) {
  const templatePath = join(templateRoot, templateName);
  if (!existsSync(templatePath)) throw new Error(`Missing template file: ${templatePath}`);
  let rendered = readFileSync(templatePath, "utf8");
  for (const [key, value] of Object.entries(values)) {
    rendered = rendered.replaceAll(`{{${key}}}`, value);
  }
  return rendered;
}

function newDirectoryLink(linkPath, targetPath) {
  const resolvedTarget = resolve(targetPath);
  if (existsSync(linkPath)) {
    const item = lstatSync(linkPath);
    if (item.isSymbolicLink()) {
      step(`Link already exists: ${linkPath}`);
      return;
    }
    throw new Error(`${linkPath} already exists and is not a link. Move it aside before running this setup.`);
  }

  try {
    symlinkSync(resolvedTarget, linkPath, "dir");
    step(`Created symbolic link ${linkPath} -> ${resolvedTarget}`);
  } catch (error) {
    if (process.platform !== "win32") throw error;
    symlinkSync(resolvedTarget, linkPath, "junction");
    step(`Created junction fallback ${linkPath} -> ${resolvedTarget}`);
  }
}

function ensureAgentsFile(path, profiles) {
  writeRenderedIfMissing("root-agents.md.tpl", path, rootAgentsValues(profiles));
  const required = [
    "`.ai` is the canonical AI context directory.",
    "`.ai-overlay` is the project-specific AI context directory.",
    "Project-specific AI assets must live in `.ai-overlay` unless the user explicitly asks to change `.ai`.",
    "Activated tool pointer paths point to `.ai`",
    "Shared agents must live in `.ai/agents`.",
    "Prompt source files are immutable and versioned under `.ai/prompts/registry`.",
  ];
  const text = readFileSync(path, "utf8");
  for (const snippet of required) {
    if (!text.includes(snippet)) {
      throw new Error(`AGENTS.md exists but is missing required assertion: ${snippet}. Choose merge, replace, or restructure before continuing.`);
    }
  }
}

function copyToolEntrypoints(profiles) {
  for (const profile of profiles) {
    if (profile.rootEntrypoint === "AGENTS.md") continue;
    writeRenderedIfMissing("agent-entrypoint.md.tpl", join(projectRoot, profile.rootEntrypoint), entrypointValues(profile));
  }
}

function ensureAiSubmodule(root) {
  const aiPath = join(root, ".ai");
  const gitModulesPath = join(root, ".gitmodules");
  const gitIgnorePath = join(root, ".gitignore");

  if (!existsSync(aiPath)) {
    if (!aiRepositoryUrl) throw new Error(".ai must exist before setup. Clone, download, or provide --ai-repository-url.");
    runGit(["submodule", "add", aiRepositoryUrl, ".ai"]);
    return true;
  }

  if (!existsSync(join(aiPath, ".git"))) {
    step(".ai is a local copied context without Git metadata; ignoring it in the root repository");
    ensureLine(gitIgnorePath, ".ai/");
    return false;
  }

  ensureAiReadme(aiPath);
  if (!gitOk(["-C", aiPath, "rev-parse", "--verify", "HEAD"])) {
    step("Creating initial commit in .ai repository");
    runGit(["-C", aiPath, "add", "-A"]);
    runGit(["-C", aiPath, "commit", "-m", "chore: initialize AI context"]);
  }

  let url = aiRepositoryUrl || getGitOriginUrl(aiPath);
  if (!url) {
    if (!registerLocalAiSubmodule) {
      step(".ai is a Git repository without remote origin; ignoring it in the root repository");
      ensureLine(gitIgnorePath, ".ai/");
      return false;
    }
    step(".ai is a Git repository without remote origin; registering it as a local submodule");
    url = "./.ai";
  }

  removeLine(gitIgnorePath, ".ai/");
  runGit(["config", "-f", gitModulesPath, "submodule..ai.path", ".ai"]);
  runGit(["config", "-f", gitModulesPath, "submodule..ai.url", url]);
  runGit(["add", ".gitignore", ".gitmodules", ".ai"]);
  return true;
}

function ensureAiReadme(aiPath) {
  const readmePath = join(aiPath, "README.md");
  if (existsSync(readmePath)) return;
  writeFileSync(readmePath, `# AI Context

This directory is the canonical AI context for the project.

Shared rules, skills, commands, agents, templates, prompts, and MCP assets live here. Activated root tool pointers point to this directory.
`, "utf8");
}

function getGitOriginUrl(path) {
  const result = capture("git", ["-C", path, "remote", "get-url", "origin"]);
  if (result.status === 0 && result.stdout.trim()) {
    return result.stdout.trim();
  }
  return "";
}

function resolveActiveProfiles(aiTool) {
  const requested = aiTool === "both" ? ["codex", "claude"] : aiTool.split(",").map((item) => item.trim()).filter(Boolean);
  if (requested.length === 0) throw new Error("--ai-tool cannot be empty. Use codex, claude, or both.");
  const seen = new Set();
  return requested.filter((id) => {
    if (seen.has(id)) return false;
    seen.add(id);
    return true;
  }).map(loadToolProfile);
}

function loadToolProfile(id) {
  const profilePath = join(profileRoot, `${id}.json`);
  if (!existsSync(profilePath)) {
    throw new Error(`Unknown AI tool profile '${id}'. Add ${profilePath} or use codex, claude, or both.`);
  }
  return JSON.parse(readFileSync(profilePath, "utf8"));
}

function allToolProfiles() {
  return readdirSync(profileRoot)
    .filter((file) => file.endsWith(".json"))
    .map((file) => loadToolProfile(file.slice(0, -".json".length)));
}

function canonicalAiDirectories() {
  const toolDirs = allToolProfiles().map((profile) => `${profile.id}/overrides`);
  return [
    "agents",
    "commands",
    "mcp",
    "prompts/registry",
    "rules",
    "skills",
    "templates",
    ...toolDirs,
  ];
}

function activePointerNames(profiles) {
  return [".agents", ...profiles.map((profile) => profile.pointerName)];
}

function initialCommitPaths(profiles) {
  return [
    "AGENTS.md",
    ...profiles.map((profile) => profile.rootEntrypoint).filter((entrypoint) => entrypoint !== "AGENTS.md"),
    ".gitignore",
    ".ai-overlay",
    "docs",
    "sources",
  ];
}

function rootAgentsValues(profiles) {
  return {
    enabledToolNames: profiles.map((profile) => profile.displayName).join(", "),
    activatedPointerNames: activePointerNames(profiles).map((pointer) => `\`${pointer}\``).join(", "),
    toolDiscoverySection: profiles.map((profile) => `- ${profile.displayName}: ${profile.discoverySummary}`).join("\n"),
    toolOverrideSection: profiles.flatMap((profile) => [
      `- Shared ${profile.displayName}-specific behavior must live in \`${profile.overridePath}\`.`,
      `- Project-specific ${profile.displayName}-specific behavior must live in \`.ai-overlay/${profile.id}/overrides\`.`,
    ]).join("\n"),
  };
}

function entrypointValues(profile) {
  return {
    rootEntrypoint: profile.rootEntrypoint,
    toolName: profile.displayName,
    readFirstBullets: profile.readFirst.map((item) => `1. Read \`${item}\`.`).join("\n"),
    ruleBullets: profile.rules.map((item) => `- ${item}`).join("\n"),
    personalConfigGuidance: profile.personalConfigGuidance,
  };
}
