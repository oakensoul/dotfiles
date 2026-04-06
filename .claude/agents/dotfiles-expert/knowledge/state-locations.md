---
name: state-locations
description: Where each tool stores config, state, and runtime data on the filesystem
---

# State & Storage Locations

## Config Repositories (Git-managed)

| Path | Owner | Purpose |
|---|---|---|
| `~/.dotfiles/` | loadout (clones it) | Public base config repo |
| `~/.dotfiles-private/` | loadout (clones it) | Private org config repo |

## Build Output

| Path | Owner | Purpose |
|---|---|---|
| `~/.dotfiles/build/` | loadout build | Staged merged output before install to ~/ |
| `~/.dotfiles/backups/` | loadout build | Pre-overwrite backups (`{file}.{YYYYMMDDTHHMMSSZ}`) |

## Tool State

| Path | Owner | Purpose |
|---|---|---|
| `~/.dotfiles/.loadout.toml` | loadout | Config: user, orgs, versions, GitHub token op path |
| `~/.loadout/` | dotfiles bootstrap | Runtime: `logs/`, `backups/`, `last-fetch` timestamp |
| `~/.devbox/config.json` | devbox | Global config: `parent_github_user` |
| `~/.devbox/registry.json` | devbox | Devbox index: version, devboxes[], status lifecycle |
| `~/.canvas/config` | canvas / loadout | Active org selector (JSON with `org` field) |
| `~/.canvas/registry.json` | canvas | Session index: active/archived sessions |
| `~/.canvas/sessions/{slug}/` | canvas | Per-session dirs with rendered CLAUDE.md |

## Shell & Git Config (installed to ~/)

| Path | Owner | Purpose |
|---|---|---|
| `~/.zshrc` | loadout build | Merged shell config |
| `~/.aliases` | loadout build | Merged shell aliases |
| `~/.gitconfig` | loadout build | Merged git config (no [user] section) |
| `~/.gitconfig.local` | user (manual) | Personal git identity |
| `~/.gitconfig.d/` | loadout build | Per-org git configs via [include] |
| `~/.zshrc.d/` | loadout build + globals | Numeric-sorted shell drop-ins |
| `~/.zshrc.local` | user (manual) | Final private shell overrides |

## Claude Code Config

| Path | Owner | Purpose |
|---|---|---|
| `~/.claude/mcp.json` | loadout claude | Deep-merged MCP server config |
| `~/.claude/CLAUDE.md` | loadout claude | Concatenated org context |
| `~/.claude/providers/` | loadout claude | API key provider scripts (chmod 755) |
| `~/.claude/statusline.sh` | loadout claude | Custom status line formatter |

## Runtime Managers

| Path | Owner | Purpose |
|---|---|---|
| `~/.nvm/` | nvm (installed by globals) | Node.js version manager |
| `~/.pyenv/` or Homebrew-managed | pyenv | Python version manager |

## macOS System

| Path | Owner | Purpose |
|---|---|---|
| `~/Library/LaunchAgents/com.oakensoul.display-defaults.plist` | loadout init | Display-watch daemon |
| `~/.loadout/logs/display-watch.log` | display-watch.sh | Daemon log |
| `/etc/sudoers.d/devbox` | devbox (sudo) | Restrictive NOPASSWD for dx-* user management |

## Devbox User Accounts

| Path | Owner | Purpose |
|---|---|---|
| `/Users/dx-{name}/` | devbox create | Devbox user home directory |
| `/Users/dx-{name}/.devbox-env` | devbox create | Resolved secrets (mode 0600) |
| `/Users/dx-{name}/.devbox_heartbeat` | devbox zshrc hook | Last-login timestamp for atrophy detection |
