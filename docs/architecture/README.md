# Loadout Ecosystem Architecture

> C4 architecture documentation for the Loadout multi-repo macOS machine configuration system.
>
> Version: 0.1.0 | Last updated: 2026-03-31
>
> For getting started, see the [Setup Guide](../SETUP.md).

---

## Table of Contents

1. [System Context (C4 Level 1)](#1-system-context-c4-level-1)
2. [Container Diagram (C4 Level 2)](#2-container-diagram-c4-level-2)
3. [Component Diagram (C4 Level 3)](#3-component-diagram-c4-level-3)
4. [Data Flow Diagrams](#4-data-flow-diagrams)
5. [Merge Strategy Details](#5-merge-strategy-details)
6. [State and Storage](#6-state-and-storage)
7. [Multi-Org Model](#7-multi-org-model)
8. [Glossary](#8-glossary)

---

## 1. System Context (C4 Level 1)

The Loadout system configures and maintains macOS development machines. It interacts with several external systems to install software, manage secrets, provide visual identity, and enable AI-assisted development.

```mermaid
C4Context
    title Loadout System Context

    Person(dev, "Developer", "macOS user who develops software across multiple orgs")

    System(loadout, "Loadout Ecosystem", "Multi-repo machine config system: CLI orchestrator, config layers, devbox environments, Claude Code workspaces")

    System_Ext(github, "GitHub", "Git hosting, SSH key registration, PR workflows")
    System_Ext(onepassword, "1Password", "Secret storage, SSH agent, op:// URI resolution")
    System_Ext(homebrew, "Homebrew", "macOS package manager, cask installer, bundle files")
    System_Ext(macos, "macOS", "System defaults, user accounts (dscl), power management (pmset), launch agents")
    System_Ext(iterm2, "iTerm2", "Terminal emulator with dynamic profiles, color-coded per org")
    System_Ext(claude, "Claude Code", "AI coding assistant, MCP servers, CLAUDE.md context, API providers")
    System_Ext(nvm, "nvm / pyenv", "Node.js and Python version managers")

    Rel(dev, loadout, "Runs CLI commands")
    Rel(loadout, github, "Clones repos, registers SSH keys, manages remotes")
    Rel(loadout, onepassword, "Reads secrets via op CLI")
    Rel(loadout, homebrew, "Installs packages via brew bundle")
    Rel(loadout, macos, "Applies system defaults, manages users, configures power")
    Rel(loadout, iterm2, "Generates dynamic profiles")
    Rel(loadout, claude, "Builds config: mcp.json, CLAUDE.md, provider scripts")
    Rel(loadout, nvm, "Installs Node.js / Python runtimes and global packages")
```

---

## 2. Container Diagram (C4 Level 2)

The ecosystem spans five repositories. Three are Python CLIs (loadout, devbox, canvas) and two are configuration repositories (dotfiles, dotfiles-private). The loadout CLI orchestrates everything; devbox and canvas are specialized tools that share infrastructure.

```mermaid
C4Container
    title Loadout Ecosystem — Containers

    Person(dev, "Developer")

    System_Boundary(ecosystem, "Loadout Ecosystem") {
        Container(loadout_cli, "loadout", "Python 3.11+, Click, Rich", "Orchestrator CLI: init, build, update, upgrade, check, globals, display")
        Container(devbox_cli, "devbox", "Python 3.11+, Click, Pydantic v2, Rich", "Disposable dev environment CLI: create, list, nuke, rebuild")
        Container(canvas_cli, "canvas", "Python 3.11+, Click, Rich, Jinja2", "Claude Code session manager: new, list, show, archive, nuke")
        ContainerDb(dotfiles, "dotfiles", "Git repo at ~/.dotfiles", "Public base layer: shell config, Brewfiles, bootstrap scripts, Claude templates")
        ContainerDb(dotfiles_priv, "dotfiles-private", "Git repo at ~/.dotfiles-private", "Private org layer: per-org secrets (op://), git identity, Claude config, devbox presets, canvas templates")
    }

    System_Ext(github, "GitHub")
    System_Ext(onepassword, "1Password")
    System_Ext(homebrew, "Homebrew")
    System_Ext(macos, "macOS")
    System_Ext(iterm2, "iTerm2")
    System_Ext(claude, "Claude Code")

    Rel(dev, loadout_cli, "loadout init / build / update / upgrade")
    Rel(dev, devbox_cli, "devbox create / nuke")
    Rel(dev, canvas_cli, "canvas new / list / archive")

    Rel(loadout_cli, dotfiles, "Clones, reads base config")
    Rel(loadout_cli, dotfiles_priv, "Clones, reads org config")
    Rel(loadout_cli, homebrew, "brew bundle")
    Rel(loadout_cli, macos, "defaults write, pmset")
    Rel(loadout_cli, github, "git clone, gh ssh-key add")
    Rel(loadout_cli, onepassword, "op read")
    Rel(loadout_cli, claude, "Writes mcp.json, CLAUDE.md, providers/")

    Rel(devbox_cli, dotfiles_priv, "Reads devbox presets")
    Rel(devbox_cli, macos, "dscl (user accounts)")
    Rel(devbox_cli, onepassword, "Resolves op:// secrets")
    Rel(devbox_cli, github, "Registers SSH keys")
    Rel(devbox_cli, iterm2, "Creates per-devbox profiles")

    Rel(canvas_cli, dotfiles_priv, "Reads Jinja2 templates from canvas/orgs/")
    Rel(canvas_cli, claude, "Launches Claude Code in session dir")
    Rel(canvas_cli, iterm2, "Uses per-org iTerm2 profiles")
```

### Container Summary

| Container | Repo | Type | Version | Key Responsibility |
|---|---|---|---|---|
| **loadout** | `oakensoul/loadout` | Python CLI | v0.1.0 Beta | Machine bootstrap and ongoing maintenance |
| **dotfiles** | `oakensoul/dotfiles` (this repo) | Config repo | n/a | Public base layer — universal macOS defaults |
| **dotfiles-private** | `oakensoul/dotfiles-private` | Config repo | n/a | Private org layer — secrets, identity, overrides |
| **devbox** | `oakensoul/devbox` | Python CLI | v0.1.0 Alpha | Disposable SSH-only dev environments |
| **canvas** | `oakensoul/canvas` | Python CLI | v0.1.0 Alpha | Ephemeral Claude Code workspaces |

---

## 3. Component Diagram (C4 Level 3)

Internal architecture of the **loadout** orchestrator CLI.

```mermaid
C4Component
    title loadout CLI — Components

    Container_Boundary(loadout, "loadout CLI") {
        Component(cli, "CLI Layer", "Click", "Command routing: init, build, update, upgrade, check, globals, display")
        Component(init, "Init Module", "Python", "12-step bootstrap: Xcode, clone, SSH, brew, globals, claude, macos, canvas config")
        Component(build, "Build Module", "Python", "Three-layer merge pipeline: concat, include, deep merge, replace")
        Component(brew, "Brew Module", "Python", "Homebrew bundle: aggregate Brewfiles, run brew bundle")
        Component(globals, "Globals Module", "Python", "Runtime installers: nvm, pyenv, Claude Code (curl), npm globals, pip globals")
        Component(claude_mod, "Claude Module", "Python", "Build Claude config: mcp.json, CLAUDE.md, API provider scripts")
        Component(check, "Check Module", "Python", "Health probes: git status, brew doctor, stale sessions, disk space")
        Component(display, "Display Module", "Python", "Power profiles: pmset config per hardware, launch agent for display watch")
        Component(macos_mod, "macOS Module", "Python", "System defaults: Dock, Finder, keyboard, trackpad, screenshots, private defaults")
        Component(core, "core.py", "Python", "Stable public API for AIDA plugin integration")
        Component(config, "Config", "TOML", "~/.dotfiles/.loadout.toml — user, orgs, versions, paths")
    }

    Rel(cli, init, "loadout init")
    Rel(cli, build, "loadout build")
    Rel(cli, brew, "loadout brew / update")
    Rel(cli, globals, "loadout globals")
    Rel(cli, claude_mod, "loadout build / init")
    Rel(cli, check, "loadout check")
    Rel(cli, display, "loadout display")
    Rel(cli, macos_mod, "loadout init")
    Rel(cli, core, "Delegates operations")
    Rel(init, build, "Step 7: merge dotfiles")
    Rel(init, brew, "Step 8: brew bundle")
    Rel(init, globals, "Step 9: install runtimes")
    Rel(init, claude_mod, "Step 10: build Claude config")
    Rel(init, macos_mod, "Step 11: apply defaults")
    Rel(init, display, "Step 12: launch agent")
    Rel(build, config, "Reads merge rules, org list")
```

---

## 4. Data Flow Diagrams

### 4.1 loadout init (Bootstrap Flow)

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant LO as loadout CLI
    participant macOS as macOS
    participant GH as GitHub
    participant OP as 1Password
    participant HB as Homebrew
    participant NVM as nvm / pyenv
    participant CC as Claude Code

    Dev->>LO: loadout init
    Note over LO: Step 1
    LO->>macOS: Ensure Xcode CLI Tools (xcode-select --install)

    Note over LO: Step 2
    LO->>GH: git clone oakensoul/dotfiles → ~/.dotfiles

    Note over LO: Step 3
    LO->>GH: git clone oakensoul/dotfiles-private → ~/.dotfiles-private

    Note over LO: Step 4
    LO->>macOS: ssh-keygen -t ed25519

    Note over LO: Step 5
    LO->>OP: op read (SSH passphrase)
    LO->>GH: gh ssh-key add

    Note over LO: Step 6
    LO->>GH: Switch remotes HTTPS → SSH

    Note over LO: Step 7
    LO->>LO: Build dotfiles (three-layer merge → ~/)

    Note over LO: Step 8
    LO->>HB: brew bundle (aggregated Brewfiles)

    Note over LO: Step 9
    LO->>NVM: Install Node.js, Python, Claude Code (curl), npm globals, pip globals

    Note over LO: Step 10
    LO->>CC: Write mcp.json, CLAUDE.md, provider scripts → ~/.claude/

    Note over LO: Step 11
    LO->>macOS: defaults write (Dock, Finder, keyboard, trackpad, screenshots, private defaults)

    Note over LO: Step 12
    LO->>macOS: Install display-watch launch agent (pmset)
```

### 4.2 loadout build (Merge Pipeline)

```mermaid
sequenceDiagram
    participant LO as loadout CLI
    participant Base as ~/.dotfiles/dotfiles/base/
    participant PrivBase as ~/.dotfiles-private/dotfiles/base/
    participant Org as ~/.dotfiles-private/dotfiles/orgs/{org}/
    participant Build as ~/.dotfiles/build/
    participant Home as ~/

    LO->>LO: Read .loadout.toml (active orgs, merge rules)

    LO->>Base: Read public base files
    LO->>PrivBase: Read private base files (optional)
    LO->>Org: Read org overlay files (per active org)

    Note over LO: Per-file merge strategy
    LO->>LO: .zshrc, .aliases → concatenate layers (separator comments)
    LO->>LO: .gitconfig → generate [include] directives
    LO->>LO: *.json → recursive deep merge (jq)
    LO->>LO: *.yaml → recursive deep merge
    LO->>LO: other files → last layer wins (replace)

    LO->>Build: Write merged output (atomic staging)
    LO->>Home: Backup existing files → ~/.dotfiles/backups/
    LO->>Home: Copy merged files to ~/
    LO->>Home: Write ~/.zshrc.d/*.zsh overlay files
    LO->>Home: Write ~/.gitconfig.d/ include files
```

### 4.3 devbox create (Environment Provisioning)

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant DB as devbox CLI
    participant OP as 1Password
    participant macOS as macOS
    participant GH as GitHub
    participant IT as iTerm2
    participant Priv as dotfiles-private

    Dev->>DB: devbox create --name myproject --org splash
    DB->>Priv: Load preset from devbox/presets/

    Note over DB: Compensation stack initialized (rollback on failure)

    DB->>macOS: dscl — create user dx-myproject
    DB->>macOS: Create home directory, set permissions

    DB->>macOS: ssh-keygen -t ed25519 (for dx-myproject)
    DB->>OP: op read (SSH passphrase)
    DB->>GH: gh ssh-key add (register devbox SSH key)

    DB->>DB: Apply preset config (shell, git, packages)
    DB->>IT: Generate iTerm2 dynamic profile for dx-myproject

    DB->>DB: Write heartbeat file (atrophy detection)
    DB->>DB: Register in ~/.devbox/registry.json

    DB-->>Dev: Devbox dx-myproject ready (SSH: ssh dx-myproject@localhost)
```

### 4.4 canvas new (Session Creation)

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant CV as canvas CLI
    participant Priv as dotfiles-private
    participant FS as Filesystem
    participant CC as Claude Code
    participant IT as iTerm2

    Dev->>CV: canvas new --org splash --name "api refactor"

    CV->>CV: Generate slug: 2026-03-30-azure-falcon
    CV->>FS: mkdir ~/.canvas/sessions/2026-03-30-azure-falcon/

    CV->>Priv: Load Jinja2 template from canvas/orgs/splash/CLAUDE.md.tmpl
    CV->>CV: Render CLAUDE.md with org context injection
    CV->>FS: Write CLAUDE.md to session directory

    CV->>FS: Update ~/.canvas/registry.json (add session entry)

    CV->>IT: Open in org-specific iTerm2 profile (splash color scheme)
    CV->>CC: Launch Claude Code in session directory

    CV-->>Dev: Session ready: ~/.canvas/sessions/2026-03-30-azure-falcon/
```

---

## 5. Merge Strategy Details

The `loadout build` command merges dotfiles from three layers in priority order. Later layers override earlier ones.

### Layer Priority (lowest to highest)

| Priority | Layer | Source Path |
|---|---|---|
| 1 (base) | Public base | `~/.dotfiles/dotfiles/base/` |
| 2 | Private base | `~/.dotfiles-private/dotfiles/base/` |
| 3 (highest) | Org overlays | `~/.dotfiles-private/dotfiles/orgs/{org}/` |

### Merge Strategy by File Type

| File Pattern | Strategy | Behavior |
|---|---|---|
| `.zshrc` | Concatenation | Layers appended sequentially, separated by comment markers (`# --- layer: base ---`) |
| `.aliases` | Concatenation | Same as `.zshrc` — all aliases from all layers combined |
| `.zprofile` | Concatenation | Same as `.zshrc` |
| `.zshenv` | Concatenation | Same as `.zshrc` |
| `.gitconfig` | Include directives | Each layer written to `~/.gitconfig.d/{layer}.gitconfig`; root `.gitconfig` uses `[include]` to load them in order |
| `*.json` | Recursive deep merge | Objects merged recursively; arrays replaced; later layers win on key conflicts |
| `*.yaml`, `*.yml` | Recursive deep merge | Same as JSON — recursive object merge, later layers win |
| All other files | Replace | Last layer providing the file wins entirely |

### Overlay Hook System

Beyond the merge pipeline, Loadout installs overlay hooks that allow runtime customization without rebuilding:

| Hook | Location | Purpose |
|---|---|---|
| `~/.zshrc.d/*.zsh` | Numeric-prefix ordered | `10-*` org config, `50-*` devbox, `90-*` private overrides |
| `~/.gitconfig.d/` | Include-loaded | Per-org git configs with conditional includes |
| `~/.zshrc.local` | Sourced last | Machine-specific shell overrides (not managed by loadout) |
| `~/.gitconfig.local` | Included last | Machine-specific git overrides (not managed by loadout) |

---

## 6. State and Storage

Each tool maintains its own state directory. There are no shared databases — tools communicate through the filesystem and well-known paths.

| Path | Owner | Contents |
|---|---|---|
| `~/.dotfiles/` | loadout (git) | Public base config repo (this repo) |
| `~/.dotfiles-private/` | loadout (git) | Private org config repo |
| `~/.dotfiles/.loadout.toml` | loadout | Primary config: user identity, active orgs, tool versions, paths |
| `~/.dotfiles/build/` | loadout | Merged build output (staging area before copy to `~/`) |
| `~/.dotfiles/backups/` | loadout | Timestamped backups of files before overwrite |
| `~/.loadout/` | loadout | Runtime state: `logs/`, `backups/`, timestamps, future `manifest.json` |
| `~/.devbox/` | devbox | `config.json`, `registry.json` (devbox inventory and settings) |
| `~/.canvas/` | canvas | `config`, `registry.json` (session inventory), `sessions/` (workspace dirs) |
| `~/.claude/` | loadout / canvas | `mcp.json`, `CLAUDE.md`, `providers/` (API key scripts) |
| `~/Library/Application Support/iTerm2/DynamicProfiles/` | loadout / devbox / canvas | Generated iTerm2 dynamic profile JSON files |

### State Ownership Rules

- **loadout** is the sole writer of `~/.dotfiles/`, `~/.dotfiles-private/`, and merged output in `~/`.
- **devbox** manages macOS user accounts and `~/.devbox/` state. It reads presets from `~/.dotfiles-private/` but never writes to it.
- **canvas** manages `~/.canvas/` state. It reads Jinja2 templates from `~/.dotfiles-private/` but never writes to it.
- **loadout check** reads state from all three tools to report health.

---

## 7. Multi-Org Model

Loadout supports five organizations, each receiving isolated configuration across every tool.

### Supported Organizations

| Org Slug | Purpose |
|---|---|
| `personal` | Personal projects and default identity |
| `splash` | Primary employer |
| `mythical-journeys` | Side project |
| `sidequest-syndicate` | Side project collective |
| `equinox-consulting` | Consulting work |

### Per-Org Configuration Surface

| Concern | Mechanism | Location |
|---|---|---|
| **Git identity** | Conditional includes in `.gitconfig` | `~/.gitconfig.d/{org}.gitconfig` |
| **Shell globals** | Sourced via `~/.zshrc.d/10-{org}.zsh` | `dotfiles-private/globals/orgs/{org}/` |
| **Brewfile extensions** | Aggregated by `loadout brew` | `dotfiles-private/brewfiles/orgs/{org}/Brewfile` |
| **Claude Code config** | Per-org `CLAUDE.md`, MCP servers, API providers | `dotfiles-private/claude/orgs/{org}/` |
| **Devbox presets** | Preset JSON loaded by `devbox create --org` | `dotfiles-private/devbox/presets/{org}/` |
| **Canvas templates** | Jinja2 `CLAUDE.md.tmpl` rendered per session | `dotfiles-private/canvas/orgs/{org}/CLAUDE.md.tmpl` |
| **iTerm2 profiles** | Color-coded dynamic profiles per org | Generated at runtime; colors identify org visually |
| **Secrets** | `op://` references scoped per org vault | `dotfiles-private/globals/orgs/{org}/` |

### Org Resolution

1. `loadout init` prompts for active orgs, writes to `.loadout.toml`.
2. `loadout build` iterates active orgs, merging their overlays in order.
3. `devbox create --org <slug>` loads the matching preset.
4. `canvas new --org <slug>` selects the matching Jinja2 template and iTerm2 profile.

---

## 8. Glossary

| Term | Definition |
|---|---|
| **Base layer** | The public `dotfiles` repo containing universal macOS defaults. First (lowest priority) merge layer. |
| **Org layer** | Per-organization configuration in `dotfiles-private`. Overrides the base layer. |
| **Private layer** | The combination of `dotfiles-private/dotfiles/base/` and org overlays. Higher priority than public base. |
| **Overlay hook** | A well-known file path (`~/.zshrc.d/`, `~/.gitconfig.d/`, `~/.zshrc.local`) that allows runtime customization without rebuilding. |
| **Three-layer merge** | The build pipeline that combines public base, private base, and org overlays into final dotfiles. |
| **Loadout** | Both the ecosystem name and the orchestrator CLI (`oakensoul/loadout`). |
| **Devbox** | A disposable SSH-only macOS user account (prefixed `dx-`) for project-scoped development. |
| **Canvas** | An ephemeral Claude Code workspace — a dated directory with rendered context and session tracking. |
| **Slug** | A human-friendly identifier. Canvas uses `YYYY-MM-DD-adjective-noun` format. |
| **Preset** | A JSON configuration file in `dotfiles-private` that defines a devbox environment (packages, shell config, git identity). |
| **Provider script** | A shell script in `~/.claude/providers/` that outputs a Claude Code API key, typically via `op read`. |
| **Compensation stack** | Devbox's rollback mechanism — records each provisioning step so partial failures can be cleanly reversed. |
| **Heartbeat file** | A timestamp file in a devbox home directory, updated on activity. Used for atrophy detection (stale devbox cleanup). |
| **Atrophy detection** | Health check that identifies devbox environments with no recent activity, candidates for `devbox nuke`. |
| **`op://` URI** | A 1Password CLI reference (e.g., `op://vault/item/field`) resolved at runtime by `op read`. No secrets are stored in config files. |
| **Dynamic profile** | An iTerm2 feature where JSON files in `~/Library/Application Support/iTerm2/DynamicProfiles/` are auto-loaded as terminal profiles. |
| **AIDA** | A future plugin system. All three Python CLIs expose `core.py` stable APIs for AIDA integration. |
| **`loadout check`** | Health probe command that inspects git status, brew state, stale canvas sessions, devbox heartbeats, and disk space. |
| **Atomic swap** | The build module writes merged output to a staging directory (`~/.dotfiles/build/`) then copies to `~/`, minimizing the window of inconsistent state. |
