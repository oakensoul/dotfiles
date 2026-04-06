---
name: merge-strategy
description: How loadout build merges dotfiles across 3 layers with per-file-type strategies
---

# Merge Strategy

## Layer Priority (lowest → highest)

1. **Public base**: `~/.dotfiles/dotfiles/base/` — universal defaults
2. **Private base**: `~/.dotfiles-private/dotfiles/base/` — shared private config (optional)
3. **Org overlays**: `~/.dotfiles-private/dotfiles/orgs/{org}/` — one per configured org, applied in order

Later layers override or extend earlier layers. The strategy depends on file type.

## Per-File Merge Strategies

| File Pattern | Strategy | Behavior |
|---|---|---|
| `.zshrc`, `.aliases`, `.zprofile`, `.zshenv` | **Concat** | Layers appended with separator comments between them |
| `.gitconfig` | **Git include** | Base written to dest; org configs merged → `~/.gitconfig.d/org.gitconfig`; included via `[include] path` |
| `*.json` | **Deep merge** | Recursive dict merge; later layers win on key conflicts; pretty-printed (indent=2) |
| `*.yaml`, `*.yml` | **Deep merge** | Recursive dict merge; later layers win on key conflicts |
| Everything else | **Replace** | Later layer file completely replaces earlier version |

## Shell Overlay System

`~/.zshrc.d/*.zsh` files are sourced in numeric order:

| Prefix | Source | Purpose |
|---|---|---|
| `10-*` | Org layer | Team/company shell extensions (convention enforced by `loadout build`) |
| `50-*` | Devbox layer | Developer tool aliases (convention enforced by `loadout build`) |
| `90-*` | Private layer | Personal overrides (convention enforced by `loadout build`) |

Loading order in `.zshrc`:
1. PATH setup (Homebrew auto-detect ARM vs Intel)
2. User bin directories
3. History config + completion
4. `~/.aliases`
5. Tool integrations (nvm, pyenv, zoxide, fzf)
6. Background git fetch hook
7. `~/.zshrc.d/*.zsh` (numeric-sorted)
8. `~/.zshrc.local` (final private overrides)

## Git Overlay System

- `~/.gitconfig` — base config (no `[user]` section), includes org config via `[include] path = ~/.gitconfig.d/org.gitconfig`
- `~/.gitconfig.d/org.gitconfig` — single merged file containing all org git configs
- `~/.gitconfig.local` — personal identity and final overrides (sourced last)

Identity is managed via conditional includes in the org config: `[includeIf "gitdir:~/Developer/{org}/"]`

## Atomic Build Process

1. Create temp directory in `~/.dotfiles/`
2. Build all merged files into temp dir
3. Atomic rename: temp → `~/.dotfiles/build/`
4. Backup existing files to `~/.dotfiles/backups/{filename}.{timestamp}`
5. Copy built files to `~/`
6. On failure, temp dir is cleaned up (no partial writes)

## Brewfile Assembly

Fragments concatenated in order:
1. `~/.dotfiles/brewfiles/Brewfile.base` (always)
2. `~/.dotfiles-private/brewfiles/Brewfile.private` (if exists)
3. `~/.dotfiles-private/brewfiles/orgs/Brewfile.{org}` (per configured org)

Result passed to `brew bundle --file=<temp> --no-lock`.

## Claude Code Config Assembly

| Source files | Target | Strategy |
|---|---|---|
| `mcp-shared.json` + `mcp-private.json` + `mcp-{org}.json` | `~/.claude/mcp.json` | Deep merge |
| `CLAUDE.md.template` + base CLAUDE.md + org CLAUDE.md | `~/.claude/CLAUDE.md` | Concatenation |
| `statusline.sh` | `~/.claude/statusline.sh` | Copy |
| `providers/*.sh` | `~/.claude/providers/` | Copy + chmod 755 |
