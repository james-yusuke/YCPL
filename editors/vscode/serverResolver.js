const fs = require("fs");
const path = require("path");
const childProcess = require("child_process");

function firstWorkspaceFolder(workspaceFolders) {
  if (!workspaceFolders || workspaceFolders.length === 0) {
    return undefined;
  }

  const first = workspaceFolders[0];
  if (typeof first === "string") {
    return first;
  }
  if (first.uri && first.uri.fsPath) {
    return first.uri.fsPath;
  }
  return undefined;
}

function expandConfiguredPath(configured, workspaceFolder, homeDir) {
  if (!configured || configured.trim().length === 0) {
    return "";
  }

  let expanded = configured.trim();
  if (workspaceFolder) {
    expanded = expanded.replace(/\$\{workspaceFolder\}/g, workspaceFolder);
  }
  if (homeDir && expanded === "~") {
    expanded = homeDir;
  } else if (homeDir && expanded.startsWith("~/")) {
    expanded = path.join(homeDir, expanded.slice(2));
  }
  return expanded;
}

function defaultWorkspaceServerPath(workspaceFolder) {
  if (!workspaceFolder) {
    return undefined;
  }
  return path.join(workspaceFolder, "tools", "lsp", "build", "YCPL-lsp");
}

function defaultBuildScriptPath(workspaceFolder) {
  if (!workspaceFolder) {
    return undefined;
  }
  return path.join(workspaceFolder, "tools", "lsp", "build.sh");
}

function resolveServerPath(options) {
  const existsSync = options.existsSync || fs.existsSync;
  const homeDir = options.homeDir || "";
  const workspaceFolder = firstWorkspaceFolder(options.workspaceFolders);
  const configured = expandConfiguredPath(options.configured, workspaceFolder, homeDir);

  if (configured.length > 0) {
    return { command: configured, source: "configured" };
  }

  const workspaceServer = defaultWorkspaceServerPath(workspaceFolder);
  if (workspaceServer && existsSync(workspaceServer)) {
    return { command: workspaceServer, source: "workspace" };
  }

  if (options.extensionPath) {
    const developmentServer = path.resolve(options.extensionPath, "..", "..", "tools", "lsp", "build", "YCPL-lsp");
    if (existsSync(developmentServer)) {
      return { command: developmentServer, source: "development" };
    }
  }

  return { command: "YCPL-lsp", source: "path" };
}

function shouldBuildDefaultServer(options) {
  const existsSync = options.existsSync || fs.existsSync;
  const workspaceFolder = firstWorkspaceFolder(options.workspaceFolders);
  const configured = expandConfiguredPath(options.configured, workspaceFolder, options.homeDir || "");
  if (configured.length > 0 || !options.buildOnActivate || !workspaceFolder) {
    return false;
  }

  const serverPath = defaultWorkspaceServerPath(workspaceFolder);
  const buildScript = defaultBuildScriptPath(workspaceFolder);
  return !!serverPath && !!buildScript && !existsSync(serverPath) && existsSync(buildScript);
}

function buildDefaultServer(options) {
  const workspaceFolder = firstWorkspaceFolder(options.workspaceFolders);
  const buildScript = defaultBuildScriptPath(workspaceFolder);
  const spawnSync = options.spawnSync || childProcess.spawnSync;
  const result = spawnSync(buildScript, [], {
    cwd: workspaceFolder,
    encoding: "utf8"
  });

  const stdout = result.stdout || "";
  const stderr = result.stderr || "";
  const lines = stdout.split(/\r?\n/).filter((line) => line.trim().length > 0);
  return {
    status: result.status,
    error: result.error,
    stdout,
    stderr,
    serverPath: lines.length > 0 ? lines[lines.length - 1].trim() : defaultWorkspaceServerPath(workspaceFolder)
  };
}

function isLinuxElfOnNonLinux(filePath, platform, readFileSync) {
  const currentPlatform = platform || process.platform;
  if (currentPlatform === "linux" || !filePath || filePath === "YCPL-lsp") {
    return false;
  }

  const reader = readFileSync || fs.readFileSync;
  try {
    const header = reader(filePath, { encoding: null, flag: "r" }).subarray(0, 4);
    return header.length === 4 && header[0] === 0x7f && header[1] === 0x45 && header[2] === 0x4c && header[3] === 0x46;
  } catch (_err) {
    return false;
  }
}

module.exports = {
  buildDefaultServer,
  defaultBuildScriptPath,
  defaultWorkspaceServerPath,
  expandConfiguredPath,
  firstWorkspaceFolder,
  isLinuxElfOnNonLinux,
  resolveServerPath,
  shouldBuildDefaultServer
};
