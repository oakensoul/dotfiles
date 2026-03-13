#!/usr/bin/env bash
#
# install-user.sh — Install base dotfiles to ~/
# Creates ~/.loadout/, backs up existing files, copies base configs
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

info()  { printf '\033[1;34m[INFO]\033[0m  %s\n' "$1"; }
skip()  { printf '\033[1;33m[SKIP]\033[0m  %s\n' "$1"; }
warn()  { printf '\033[1;33m[WARN]\033[0m  %s\n' "$1"; }

# ---------------------------------------------------------------------------
# Create ~/.loadout/ state directory
# ---------------------------------------------------------------------------
mkdir -p "$HOME/.loadout/backups"
mkdir -p "$HOME/.loadout/logs"
info "State directory: ~/.loadout/"

# ---------------------------------------------------------------------------
# Backup existing dotfiles
# ---------------------------------------------------------------------------
BACKUP_DIR="$HOME/.loadout/backups/$(date +%Y-%m-%d-%H%M%S)"
files_to_install=(
    ".zshrc"
    ".gitconfig"
    ".aliases"
)
needs_backup=false
for f in "${files_to_install[@]}"; do
    if [[ -f "$HOME/$f" ]]; then
        needs_backup=true
        break
    fi
done

if [[ "$needs_backup" == true ]]; then
    mkdir -p "$BACKUP_DIR"
    info "Backing up existing dotfiles to $BACKUP_DIR/"
    for f in "${files_to_install[@]}"; do
        if [[ -f "$HOME/$f" ]]; then
            cp "$HOME/$f" "$BACKUP_DIR/$f"
            info "  Backed up ~/$f"
        fi
    done
else
    skip "No existing dotfiles to back up"
fi

# ---------------------------------------------------------------------------
# Copy base dotfiles
# ---------------------------------------------------------------------------
info "Installing base dotfiles..."
for f in "${files_to_install[@]}"; do
    cp "$REPO_ROOT/dotfiles/base/$f" "$HOME/$f"
    info "  Installed ~/$f"
done

# ---------------------------------------------------------------------------
# Create overlay directories
# ---------------------------------------------------------------------------
mkdir -p "$HOME/.zshrc.d"
mkdir -p "$HOME/.gitconfig.d"
info "Created overlay directories: ~/.zshrc.d/, ~/.gitconfig.d/"

# ---------------------------------------------------------------------------
# Set zsh as default shell
# ---------------------------------------------------------------------------
if [[ "$SHELL" == */zsh ]]; then
    skip "zsh is already the default shell"
else
    info "Setting zsh as default shell..."
    chsh -s "$(command -v zsh)"
fi

# ---------------------------------------------------------------------------
# Reminder
# ---------------------------------------------------------------------------
echo ""
info "Base dotfiles installed. Next steps:"
info "  1. Create ~/.gitconfig.local with your [user] section:"
info "     git config --file ~/.gitconfig.local user.name \"Your Name\""
info "     git config --file ~/.gitconfig.local user.email \"your@email.com\""
info "  2. Source your new shell: source ~/.zshrc"
info "  3. (Optional) Run install-devbox.sh for developer tools"
