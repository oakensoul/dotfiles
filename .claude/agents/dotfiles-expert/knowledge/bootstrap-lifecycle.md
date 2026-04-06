---
name: bootstrap-lifecycle
description: The loadout init 12-step bootstrap and daily update/upgrade workflows
---

# Bootstrap & Lifecycle

## loadout init — Full Machine Bootstrap (12 Steps)

Run once on a fresh machine: `loadout init --user=NAME --orgs=ORG1 --orgs=ORG2`

1. **Ensure Xcode CLI Tools** — headless install if missing
2. **Clone ~/.dotfiles** — public base repo from GitHub
3. **Clone ~/.dotfiles-private** — private org config repo
4. **Generate SSH key** — ed25519 format
5. **Register SSH key with GitHub** — via 1Password token + gh CLI
6. **Switch git remotes to SSH** — https → git@github.com:
7. **Build dotfiles** — merge 3 layers → atomic swap → install to ~/
8. **Brew bundle** — install all Brewfile fragments
9. **Install globals** — nvm + Node LTS, pyenv + Python, Claude Code, npm/pip globals
10. **Build Claude config** — assemble mcp.json + CLAUDE.md + providers
11. **Apply macOS defaults** — hardware-appropriate scripts (desktop vs laptop vs docked)
12. **Set up display launch agent** — launchctl for auto-detection daemon

Saves state to `~/.dotfiles/.loadout.toml` on completion.

## loadout update — Daily Safe Sync

Safe to run daily: `loadout update`

1. `git pull --ff-only` both repos (fails if local changes)
2. Rebuild merged dotfiles (atomic swap)
3. Build Claude config
4. `brew update && brew bundle` (install new packages only)
5. Install globals (check-before-install, safe)

## loadout upgrade — Update + Brew Upgrade

Potentially breaking: `loadout upgrade`

Same as update, plus `brew upgrade` (updates existing packages to latest versions).

## loadout build — Merge Pipeline Only

Just the dotfile merge: `loadout build`

Useful for testing merge changes without pulling or installing packages.

## loadout globals — Package Installation Only

Just global tools: `loadout globals`

1. Ensure nvm + Node LTS
2. Ensure Claude Code CLI
3. Ensure pyenv + Python
4. Run globals.base.sh
5. Run globals.private.sh (optional)
6. Install org globals scripts to ~/.zshrc.d/
7. Install npm globals (from npm-globals.txt files)
8. Install pip globals (from pip-globals.txt files)

## loadout check — Health Probes (Read-Only)

Never mutates: `loadout check`

Probes: Homebrew, Git, Node.js, Python, 1Password CLI, GitHub SSH, Claude Code, Brewfile fragments, globals scripts, Claude config files.

## loadout display — Power Profile Switching

`loadout display [connected|solo]`

Detects hardware (MacBook vs desktop) and display count, applies appropriate power management profile:
- Desktop → never sleep, display sleep 10m
- Laptop solo → battery-friendly (sleep 15m, display 5m)
- Laptop connected/docked → desktop-like on AC

## Legacy Bootstrap Scripts (in dotfiles repo)

The dotfiles repo also has standalone bootstrap scripts for use without the loadout CLI:
- `bootstrap/install-base.sh` — Xcode, Homebrew, Brewfile.base, globals
- `bootstrap/install-user.sh` — backup dotfiles, copy base configs to ~/
- `bootstrap/install-devbox.sh` — dev packages, devbox overlay, display detection
