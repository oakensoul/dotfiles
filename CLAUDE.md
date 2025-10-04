# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **public dotfiles repository** containing configuration templates and base setups for macOS. It is part of a three-repository system:

1. **`claude-personal-assistant`** - Public AIDE framework (core AI assistant system)
2. **`dotfiles`** (this repo) - Public configuration templates
3. **`dotfiles-private`** - Private configurations (not in this repo)

The repository uses **GNU Stow** for symlink-based installation, allowing packages to be selectively installed and easily managed.

## Architecture

### Stow Package System

The repository is organized as Stow packages - each subdirectory represents a package that can be independently installed:

- **shell/** - Zsh configuration (`.zshrc` sources `.zshrc.local` for private configs)
- **git/** - Git configuration template (`.gitconfig`, `.gitignore_global`)
- **aide/** - AIDE configuration templates (`CLAUDE.md.template`, `.claude/` templates)
- **scripts/** - Utility scripts in `bin/` subdirectory
- **vim/** - Vim configuration (`.vimrc`)

**Critical Design Pattern**: Public configs use templates and source private overrides when available. The `.zshrc` sources `.zshrc.local` for private configurations that should never be committed to this public repo.

### Installation Flow

1. User runs `stow <package>` from the repository root
2. Stow creates symlinks from `~/<file>` → `~/dotfiles/<package>/<file>`
3. Private configs from `dotfiles-private` can be stowed afterward to override public templates

## Common Commands

### Package Management

```bash
# Install all packages
cd ~/dotfiles && stow */

# Install specific package
stow shell    # Install shell configs only
stow git      # Install git config only

# Remove package
stow -D vim   # Remove vim symlinks
```

### Development Workflow

```bash
# Edit configs (edits through symlinks back to repo)
vim ~/.zshrc          # Edits ~/dotfiles/shell/.zshrc

# Commit changes
cd ~/dotfiles
git add <package>/<file>
git commit -m "Updated <package> config"
git push
```

### New Machine Setup

```bash
# 1. Install prerequisites
brew install stow git

# 2. Clone and install dotfiles
git clone <repo-url> ~/dotfiles
cd ~/dotfiles && stow */

# 3. Customize templates
vim ~/.gitconfig  # Replace placeholders
```

## Important Constraints

### Public vs Private

**NEVER commit to this repository**:
- API keys, tokens, or secrets
- Personal email addresses or identifiers
- Machine-specific paths or configurations
- Private aliases or workflows

**Use `.zshrc.local` or `dotfiles-private` repo instead** for sensitive/private configurations.

### Template Pattern

Files ending in `.template` are meant to be copied and customized:
- `CLAUDE.md.template` → copy to `~/CLAUDE.md` and customize
- `.claude/knowledge/*.template` → populate with personal information

### Stow Requirements

When creating new packages:
- Files must be inside a package directory (e.g., `newpackage/.config/tool/config`)
- Stow will recreate the directory structure from the package folder to `~/`
- Ensure no conflicts with existing files before stowing