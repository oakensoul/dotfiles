# Loadout

A layered macOS machine configuration system. This is the **public base layer** — no personal information, no organization-specific content.

## Overview

Loadout replaces traditional symlink-based dotfiles with a **layered merge system**:

- **Base layer** (this repo) — sensible defaults for any macOS machine
- **Org layer** — team/company tools, standards, and configs
- **Private layer** — personal identity, secrets, API keys

Each layer extends and overrides the one below it. Shell configs concatenate, gitconfigs use `[include]`, JSON merges deeply via `jq`.

## Quick Start

```bash
# 1. Clone
git clone https://github.com/oakensoul/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Bootstrap base tools (Xcode CLI, Homebrew, core packages)
./bootstrap/install-base.sh

# 3. Install base dotfiles
./bootstrap/install-user.sh

# 4. (Optional) Install dev tools
./bootstrap/install-devbox.sh
```

## Structure

```
dotfiles/
├── bootstrap/          # Installation scripts (base, user, devbox)
├── brewfiles/          # Homebrew bundle files
├── globals/            # Global language runtimes and tools
├── dotfiles/           # Shell, git, and alias configs
│   ├── base/           # Core dotfiles for any machine
│   └── devbox/         # Developer overlay (zshrc.d drop-in)
├── claude/             # Claude Code configuration templates
├── macos/              # macOS system defaults and power management
├── iterm2/             # iTerm2 profile generation
├── test/               # Validation and CI
├── webapps/            # Web app configs (placeholder)
├── slack/              # Slack configs (placeholder)
└── canvas/             # Canvas configs (placeholder)
```

## Design Principles

- **Idempotent** — every script checks before acting, safe to re-run
- **No symlinks** — files are copied; future `loadout build` will merge layers
- **Overlay hooks** — `~/.zshrc.local`, `~/.zshrc.d/*.zsh`, `~/.gitconfig.local`, `~/.gitconfig.d/`
- **1Password CLI** (`op`) for secrets management and SSH agent
- **No personal data** — this repo contains zero identity information

## Overlay System

### Shell
- `~/.zshrc` — base shell config
- `~/.zshrc.d/*.zsh` — numbered drop-ins (10-* org, 50-* devbox, 90-* private)
- `~/.zshrc.local` — final private overrides (sourced last)

### Git
- `~/.gitconfig` — base git config (no `[user]` section)
- `~/.gitconfig.d/` — include directory for org/team configs
- `~/.gitconfig.local` — private identity and overrides

### State Directory
- `~/.loadout/` — managed state: `backups/`, `logs/`, future `manifest.json`

## Bootstrap Scripts

| Script | What it does |
|--------|-------------|
| `install-base.sh` | Xcode CLI tools, Homebrew, Brewfile.base, global runtimes, macOS defaults |
| `install-user.sh` | Back up existing dotfiles, copy base configs to `~/`, create `~/.loadout/` |
| `install-devbox.sh` | Brewfile.devbox, dev runtimes, devbox shell overlay, display detection |

## Validation

```bash
./test/validate.sh
```

Runs shellcheck, JSON/plist validation, secrets scanning, and portability checks. Also runs in CI on every push and PR.

## License

AGPL-3.0 — see [LICENSE](LICENSE) for details.
