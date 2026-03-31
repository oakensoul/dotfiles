# Loadout — Dotfiles Base Layer

A layered macOS machine configuration system. This is the **public base layer** containing sensible defaults for any macOS machine. No personal information, no organization-specific content.

## How It Works

Loadout replaces traditional symlink-based dotfiles with a **layered merge system**:

```
Base (this repo)          Sensible macOS defaults for everyone
        |
   Org layer              Team/company tools, standards, configs
        |
  Private layer           Personal identity, secrets, API keys
```

Each layer extends and overrides the one below it. Shell configs concatenate, gitconfigs use `[include]`, and JSON merges deeply. The [loadout CLI](https://github.com/oakensoul/loadout) orchestrates everything.

## Prerequisites

- **macOS 13 Ventura** or later
- **Apple ID** (required for Xcode Command Line Tools)
- **GitHub account**
- **1Password account** (recommended, for secrets and SSH agent management)

## Quick Start

The recommended way to set up a new machine is with the `loadout` CLI:

```bash
# 1. Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install loadout
pip3 install oakensoul-loadout

# 3. Bootstrap your machine
loadout init --user=YOUR_USERNAME --orgs=YOUR_ORG
```

This runs a fully automated 12-step bootstrap that clones repos, generates SSH keys, installs packages, builds your dotfiles, and configures macOS defaults.

For the full walkthrough, see the **[Setup Guide](docs/SETUP.md)**.

### Manual Bootstrap (Alternative)

If you prefer to run things step by step without the loadout CLI:

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles

./bootstrap/install-base.sh      # Xcode CLI, Homebrew, base packages, macOS defaults
./bootstrap/install-user.sh      # Back up existing dotfiles, install base configs
./bootstrap/install-devbox.sh    # (Optional) Developer tools and overlay
```

See the [Setup Guide](docs/SETUP.md#manual-bootstrap) for details on this approach.

## Repository Structure

```
dotfiles/
├── bootstrap/          Installation scripts (base, user, devbox)
├── brewfiles/          Homebrew bundle files
├── globals/            Global language runtimes and tools
├── dotfiles/           Shell, git, and alias configs
│   ├── base/           Core dotfiles for any machine
│   └── devbox/         Developer overlay (zshrc.d drop-in)
├── claude/             Claude Code configuration templates
├── macos/              macOS system defaults and power management
├── iterm2/             iTerm2 profile generation
├── docs/               Architecture and setup documentation
└── test/               Validation and CI
```

## Documentation

- **[Setup Guide](docs/SETUP.md)** — Step-by-step getting started guide
- **[Architecture](docs/architecture/README.md)** — C4 diagrams, merge strategies, data flows
- **[loadout CLI](https://github.com/oakensoul/loadout)** — The orchestrator tool documentation

## The Loadout Ecosystem

| Repository | Purpose |
|---|---|
| **[dotfiles](https://github.com/oakensoul/dotfiles)** (this repo) | Public base layer — universal macOS defaults |
| **[loadout](https://github.com/oakensoul/loadout)** | CLI orchestrator — init, build, update, upgrade, check |
| **dotfiles-private** | Private layer — org configs, secrets, identity (your own repo) |
| **[devbox](https://github.com/oakensoul/devbox)** | Disposable SSH-only dev environments |
| **[canvas](https://github.com/oakensoul/canvas)** | Ephemeral Claude Code workspace sessions |

## Design Principles

- **Idempotent** — every script checks before acting, safe to re-run
- **No symlinks** — files are copied; `loadout build` merges layers
- **Overlay hooks** — `~/.zshrc.d/*.zsh`, `~/.gitconfig.d/`, `~/.zshrc.local`, `~/.gitconfig.local`
- **1Password CLI** (`op`) for secrets management and SSH agent
- **No personal data** — this repo contains zero identity information

## Validation

```bash
./test/validate.sh
```

Runs shellcheck, JSON/plist validation, secrets scanning, and portability checks. Also runs in CI on every push and PR via `.github/workflows/validate.yml`.

## Contributing

1. Fork this repository
2. Create a feature branch
3. Ensure `./test/validate.sh` passes
4. Submit a pull request

All shell scripts must pass `shellcheck --severity=warning`. No personal data, API keys, or machine-specific paths should ever appear in this repo.

## License

AGPL-3.0 — see [LICENSE](LICENSE) for details.
