# CLAUDE.md

## Repository Overview

**Loadout** — a layered macOS machine configuration system. This is the public base layer containing configuration templates, bootstrap scripts, and system defaults. No personal information, no org-specific content.

## Architecture

### Layer System

Loadout uses a three-layer merge model (only the base layer lives here):

1. **Base** (this repo) — universal macOS defaults
2. **Org** — team/company configs (separate repo)
3. **Private** — personal identity and secrets (separate repo)

Merge strategy: shell concatenation, gitconfig `[include]`, JSON deep merge via `jq`.

### Directory Layout

- **bootstrap/** — Installation scripts (`install-base.sh`, `install-user.sh`, `install-devbox.sh`)
- **brewfiles/** — Homebrew bundle files (`Brewfile.base`, `Brewfile.devbox`)
- **globals/** — Global runtime installers (`globals.base.sh`, `globals.devbox.sh`)
- **dotfiles/base/** — Core dotfiles (`.zshrc`, `.gitconfig`, `.aliases`)
- **dotfiles/devbox/** — Developer overlay (`50-devbox.zsh` for `~/.zshrc.d/`)
- **claude/** — Claude Code config templates and MCP configs
- **macos/** — System defaults scripts and power management
- **iterm2/** — iTerm2 Dynamic Profile generator (Python, stdlib only)
- **test/** — Validation script and CI workflow
- **webapps/, slack/, canvas/** — Placeholder directories for future configs

### Key Design Patterns

- **Idempotent scripts** — all `.sh` files use `command -v` guards, check before acting
- **No symlinks** — files are copied to `~/`; future `loadout build` merges layers
- **Overlay hooks** — `~/.zshrc.local`, `~/.zshrc.d/*.zsh` (numeric prefix ordering), `~/.gitconfig.local`, `~/.gitconfig.d/`
- **State directory** — `~/.loadout/` holds `backups/`, `logs/`, future `manifest.json`
- **nvm via curl** (not Homebrew), **pyenv via Homebrew**, profile suppression with `PROFILE=/dev/null`
- **1Password CLI** (`op`) for secrets, SSH via 1Password SSH agent
- **pmset** for power management (not deprecated systemsetup)

## Common Commands

```bash
# Bootstrap a new machine
./bootstrap/install-base.sh
./bootstrap/install-user.sh
./bootstrap/install-devbox.sh    # optional

# Run validation
./test/validate.sh

# Generate iTerm2 profile
python3 iterm2/generate-profile.py --name "My Profile" --output ~/Library/Application\ Support/iTerm2/DynamicProfiles/profile.json
```

## Important Constraints

### Public Repository Rules

**NEVER commit**:
- API keys, tokens, or secrets
- Personal email addresses or identifiers
- Machine-specific paths (no `/Users/username/`)
- Organization-specific configurations

### Script Standards

- All `.sh` files must have `#!/usr/bin/env bash` shebang
- All `.py` files must have `#!/usr/bin/env python3` shebang
- All scripts must be executable (`chmod +x`)
- All scripts must pass `shellcheck --severity=warning`
- No `>>` appends without guards, no `mkdir` without `-p`

### Testing

`test/validate.sh` runs 10 checks — shellcheck, JSON/plist validation, secrets scan, path scan, idempotency checks. CI runs on every push/PR via `.github/workflows/validate.yml`.
