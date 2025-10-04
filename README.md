# My Dotfiles

Personal configuration files and templates for macOS, featuring AIDE integration (Claude personal assistant system).

## Overview

**This is my PUBLIC DOTFILES repository** - configuration templates and base setups that others can learn from and adapt.

### The Three-Repo System

This is part of my complete development environment:

1. **`claude-personal-assistant`** - Public AIDE framework
    - Core system that powers my AI assistant
    - [github.com/you/claude-personal-assistant](https://github.com/you/claude-personal-assistant)

2. **`dotfiles`** (this repo) - Public configuration templates
    - Base shell configs, git setup, AIDE templates
    - Generic scripts and workflows
    - Safe to share publicly

3. **`dotfiles-private`** - Private configurations
    - My actual secrets and personal configs
    - Overrides these templates
    - Not publicly accessible

## Philosophy

These dotfiles serve as a **base layer** that can be extended with private configurations. Public configs use templates and source private overrides when available.

Managed with **GNU Stow** for clean, organized, symlink-based installation.

## Structure

```
dotfiles/
├── shell/
│   └── .zshrc              # Sources .zshrc.local for private configs
├── git/
│   └── .gitconfig          # Template with placeholders
├── aide/
│   ├── CLAUDE.md.template  # AIDE configuration template
│   └── .claude/
│       └── knowledge/
│           └── *.template  # Knowledge base templates
├── scripts/
│   └── bin/
│       └── *.sh           # Useful utility scripts
└── vim/
    └── .vimrc             # Vim configuration
```

## Quick Start

```bash
# Clone this repo
git clone https://github.com/you/dotfiles.git ~/dotfiles

# Install with Stow
cd ~/dotfiles
stow */

# Customize the templates
vim ~/.gitconfig  # Add your name/email
vim ~/CLAUDE.md   # Configure AIDE

# Create private overrides
echo "export API_KEY=secret" > ~/.zshrc.local
```

## Installation

### Prerequisites

```bash
# Install Stow
brew install stow

# Install AIDE framework
git clone https://github.com/you/claude-personal-assistant.git ~/.aide
cd ~/.aide && ./install.sh
```

### Install All Packages

```bash
cd ~/dotfiles
stow */
```

### Install Specific Packages

```bash
cd ~/dotfiles
stow shell    # Install shell configs
stow git      # Install git config
stow aide     # Install AIDE templates
stow scripts  # Install utility scripts
```

## Packages

### Shell
- `.zshrc` - Zsh configuration
- Sources `.zshrc.local` for private configurations
- Generic aliases and PATH setup

### Git
- `.gitconfig` - Git configuration template
- `.gitignore_global` - Global gitignore patterns
- Replace placeholders with your information

### AIDE
- `CLAUDE.md.template` - AIDE configuration template
- `.claude/` templates - Knowledge base structure
- Integrates with [claude-personal-assistant](https://github.com/you/claude-personal-assistant)

### Scripts
- `bin/` - Utility scripts
- Generic helpers and tools
- Nothing machine-specific

### Vim
- `.vimrc` - Vim configuration
- Basic setup, extend as needed

## Customization

### Private Overrides

Create a `~/.zshrc.local` file for private configurations:

```bash
# ~/.zshrc.local
export ANTHROPIC_API_KEY="your-key"
export WORK_EMAIL="you@company.com"

alias work='cd ~/Development/work'
```

This file is sourced by `.zshrc` but never committed.

### AIDE Setup

1. Install AIDE framework: `cd ~/.aide && ./install.sh`
2. Copy template: `cp ~/CLAUDE.md.template ~/CLAUDE.md`
3. Customize `~/CLAUDE.md` with your preferences
4. Populate `~/.claude/knowledge/` with your information

### Extending with Private Repo

Create a `dotfiles-private` repository that stows on top:

```bash
# Stow public first
cd ~/dotfiles && stow */

# Stow private second (overrides public)
cd ~/dotfiles-private && stow */
```

## Usage

### Update Configs

```bash
# Edit through symlinks
vim ~/.zshrc          # Edits ~/dotfiles/shell/.zshrc

# Commit changes
cd ~/dotfiles
git add shell/.zshrc
git commit -m "Updated shell config"
git push
```

### Add New Package

```bash
cd ~/dotfiles
mkdir newpackage
# Add files to newpackage/
stow newpackage
git add newpackage/
git commit -m "Added new package"
```

### Remove Package

```bash
cd ~/dotfiles
stow -D vim    # Remove symlinks
rm -rf vim/    # Remove package
```

## New Machine Setup

```bash
# 1. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install Stow
brew install stow git

# 3. Clone dotfiles
git clone https://github.com/you/dotfiles.git ~/dotfiles

# 4. Stow everything
cd ~/dotfiles && stow */

# 5. Install AIDE
git clone https://github.com/you/claude-personal-assistant.git ~/.aide
cd ~/.aide && ./install.sh

# 6. Customize
vim ~/.gitconfig  # Add your info
vim ~/CLAUDE.md   # Configure AIDE
```

## AIDE Integration

This dotfiles repo includes templates for AIDE (Claude personal assistant):

- `aide/CLAUDE.md.template` - Main configuration template
- `aide/.claude/` - Knowledge base structure
- Integrates with the [claude-personal-assistant](https://github.com/you/claude-personal-assistant) framework

After stowing, install AIDE and customize the templates.

## Requirements

- macOS (adaptable to Linux)
- GNU Stow
- Git
- Zsh (or adapt to Bash)

## License

MIT License - Feel free to use and adapt!

## Inspiration

- [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles)
- [holman/dotfiles](https://github.com/holman/dotfiles)
- [paulirish/dotfiles](https://github.com/paulirish/dotfiles)

## Links

- AIDE Framework: [claude-personal-assistant](https://github.com/you/claude-personal-assistant)
- My Blog: [your-blog.com](https://your-blog.com)
- Twitter: [@yourusername](https://twitter.com/yourusername)

---

**These are templates - customize for your own use!**