---
name: ecosystem-overview
description: High-level overview of the 5-repo Loadout macOS machine configuration system and each repo's role
---

# Loadout Ecosystem Overview

Loadout is a multi-repo macOS machine configuration system with **5 repositories** that serve **3 roles**: orchestration, base config, and specialized tooling.

## Repositories

### loadout — The Orchestrator
- **Type**: Python CLI (Click + Rich + PyYAML)
- **Purpose**: Machine configuration orchestration — clones config repos, merges dotfile layers, installs packages, configures macOS, sets up Claude Code
- **Commands**: `init`, `build`, `update`, `upgrade`, `check`, `globals`, `display`
- **State**: `~/.dotfiles/.loadout.toml` (user, orgs, versions)
- **Status**: v0.1.0 Beta, 95%+ test coverage

### dotfiles — Public Base Layer
- **Type**: Git config repo (cloned to `~/.dotfiles`)
- **Purpose**: Universal macOS defaults — shell config, git config, aliases, Brewfiles, macOS defaults scripts, Claude Code templates, iTerm2 profile generator, bootstrap scripts
- **Key dirs**: `bootstrap/`, `brewfiles/`, `globals/`, `dotfiles/base/`, `dotfiles/devbox/`, `macos/`, `claude/`, `iterm2/`, `test/`
- **Design**: Idempotent scripts, no symlinks (copy-based), overlay hooks
- **Status**: Stable, public, AGPL-3.0

### dotfiles-private — Private Org Layer
- **Type**: Git config repo (cloned to `~/.dotfiles-private`)
- **Purpose**: Org-specific secrets, identity, and configuration overrides
- **Orgs**: user-defined (configured via `loadout init --orgs=...`)
- **Structure**: Each top-level dir has `base/` (shared private) + `orgs/` (per-org) subdirs
- **Key contents**: Git identity, secrets (op:// refs), Brewfiles, Claude configs, devbox presets, canvas templates
- **Status**: Active development (feature branch)

### devbox — Disposable Dev Environments
- **Type**: Python CLI (Click + Pydantic v2 + Rich + Requests)
- **Purpose**: Create and manage disposable SSH-only macOS user accounts (`dx-*` prefix) for project-scoped development
- **Commands**: `create`, `list`, `nuke`, `rebuild`
- **Features**: macOS user lifecycle (dscl), SSH keys + GitHub registration, iTerm2 profiles, preset-driven config, compensation stack for rollback
- **State**: `~/.devbox/` (config.json, registry.json)
- **Status**: v0.1.0 Alpha, 90%+ test coverage

### canvas — Claude Code Workspace Sessions
- **Type**: Python CLI (Click + Rich + Jinja2)
- **Purpose**: Ephemeral org-aware Claude Code workspace manager
- **Commands**: `new`, `list`, `show`, `archive`, `nuke`, `rename`, `open`
- **Features**: Org-aware CLAUDE.md rendering from Jinja2 templates, human-friendly slugs (YYYY-MM-DD-adjective-noun), JSON registry, iTerm2 integration, stale session detection
- **State**: `~/.canvas/` (config, registry.json, sessions/)
- **Status**: v0.1.0 Alpha, 95%+ test coverage

## Relationships

```
loadout (orchestrator)
  ├── reads from: dotfiles (base layer)
  ├── reads from: dotfiles-private (org layer)
  ├── merges → builds → installs to ~/
  └── exposes core.py API for future AIDA plugin

devbox (standalone CLI)
  ├── reads presets from: dotfiles-private/devbox/presets/
  ├── creates macOS user accounts
  └── exposes core.py API for future AIDA plugin

canvas (standalone CLI)
  ├── reads templates from: dotfiles-private/canvas/orgs/
  ├── creates session dirs under ~/.canvas/sessions/
  └── exposes core.py API for future AIDA plugin
```

## Shared Infrastructure

- **1Password CLI** (`op`) — secrets for all tools
- **iTerm2** — visual identity (color-coded per org, dynamic profiles)
- **GitHub CLI** (`gh`) — SSH key registration, PR workflows
- **All 3 Python CLIs** expose `core.py` stable APIs for AIDA plugin integration
- **AGPL-3.0** licensing across all repos
