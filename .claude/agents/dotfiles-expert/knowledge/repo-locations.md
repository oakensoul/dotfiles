---
name: repo-locations
description: Source code paths and key file locations in each repository
---

# Repository Locations & Key Files

## Source Repositories

All repos live under `~/Developer/{github-user}/`:

| Repo | Local Path | GitHub |
|---|---|---|
| loadout | `~/Developer/{github-user}/loadout` | {github-user}/loadout |
| dotfiles | `~/Developer/{github-user}/dotfiles` | {github-user}/dotfiles |
| dotfiles-private | `~/Developer/{github-user}/dotfiles-private` | {github-user}/dotfiles-private |
| devbox | `~/Developer/{github-user}/devbox` | {github-user}/devbox |
| canvas | `~/Developer/{github-user}/canvas` | {github-user}/canvas |

## Key Files by Repo

### loadout
- `loadout/cli.py` — Click CLI entry point
- `loadout/core.py` — Stable public API (for AIDA plugins)
- `loadout/config.py` — LoadoutConfig dataclass + TOML I/O
- `loadout/build.py` — Dotfile merge engine (MergeStrategy enum)
- `loadout/init.py` — 12-step machine bootstrap
- `loadout/brew.py` — Brewfile fragment assembly
- `loadout/claude.py` — Claude Code config assembly
- `loadout/globals.py` — nvm/pyenv/npm/pip global installs
- `loadout/update.py` — Daily update + upgrade flows
- `loadout/check.py` — Health check probes
- `loadout/display.py` — macOS display profile detection
- `loadout/merge.py` — Deep merge utility
- `docs/architecture/README.md` — Architecture documentation

### dotfiles
- `bootstrap/install-base.sh` — Phase 1: system foundations
- `bootstrap/install-user.sh` — Phase 2: user dotfiles
- `bootstrap/install-devbox.sh` — Phase 3: developer tools
- `dotfiles/base/.zshrc` — Base shell config
- `dotfiles/base/.gitconfig` — Base git config (no [user])
- `dotfiles/base/.aliases` — Shell aliases with modern tool replacements
- `dotfiles/devbox/50-devbox.zsh` — Dev aliases drop-in
- `brewfiles/Brewfile.base` — Core Homebrew packages
- `brewfiles/Brewfile.devbox` — Dev Homebrew packages
- `globals/globals.base.sh` — nvm, pyenv, Claude Code installer
- `globals/globals.devbox.sh` — npm/pip global packages
- `macos/defaults-base.sh` — Universal macOS preferences
- `macos/display-watch.sh` — Hardware detection daemon
- `claude/statusline.sh` — Claude Code status line formatter
- `iterm2/generate-profile.py` — iTerm2 dynamic profile generator
- `claude/base/mcp-shared.json` — Base MCP server config
- `claude/base/settings.json` — Base Claude Code settings
- `claude/devbox/mcp-devbox.json` — Devbox MCP server config
- `claude/CLAUDE.md.template` — Template for merged CLAUDE.md
- `claude/statusline.sh` — Claude Code status line formatter
- `test/validate.sh` — 10-check validation suite
- `docs/architecture/README.md` — Ecosystem architecture (C4 diagrams)

### dotfiles-private
- `dotfiles/orgs/{org}/.gitconfig` — Per-org git identity
- `dotfiles/orgs/{org}/.zshrc` — Per-org shell config
- `globals/orgs/globals.{org}.sh` — Per-org env vars (op:// secrets)
- `brewfiles/orgs/Brewfile.{org}` — Per-org Homebrew packages
- `claude/orgs/{org}/CLAUDE.md` — Per-org Claude instructions
- `claude/orgs/{org}/mcp-{org}.json` — Per-org MCP config
- `claude/providers/*.sh` — API key provider scripts
- `devbox/presets/*.json` — Per-project devbox presets
- `canvas/orgs/{org}/CLAUDE.md.tmpl` — Per-org canvas session templates

### devbox
- `src/devbox/cli.py` — Click CLI entry
- `src/devbox/core.py` — Core orchestration (create/nuke/list/rebuild)
- `src/devbox/registry.py` — ~/.devbox/registry.json CRUD
- `src/devbox/presets.py` — Preset loading + Pydantic validation
- `src/devbox/macos.py` — dscl user management
- `src/devbox/ssh.py` — SSH key generation
- `src/devbox/github.py` — GitHub API (SSH key lifecycle)
- `src/devbox/iterm2.py` — iTerm2 dynamic profile management
- `src/devbox/bootstrap.py` — nvm/pyenv/brew/npm/pip setup
- `src/devbox/auth.py` — Anthropic/AWS credential injection
- `src/devbox/health.py` — Heartbeat + atrophy detection
- `docs/architecture/README.md` — Architecture documentation

### canvas
- `canvas/cli.py` — Click CLI commands
- `canvas/core.py` — Core orchestration (new_session, list, archive, etc.)
- `canvas/registry.py` — Registry CRUD
- `canvas/models.py` — Session dataclass + enums
- `canvas/slug.py` — Slug generation + validation
- `canvas/template.py` — Jinja2 template rendering
- `canvas/config.py` — Path resolution + config loading
- `docs/architecture/README.md` — Architecture documentation
