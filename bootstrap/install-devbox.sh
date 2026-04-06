#!/usr/bin/env bash
#
# install-devbox.sh — Install developer tools and overlay
# Requires: install-base.sh has been run (Homebrew available)
#
# Manual alternative to `loadout init`. See docs/SETUP.md for the recommended
# automated approach.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

info()  { printf '\033[1;34m[INFO]\033[0m  %s\n' "$1"; }
skip()  { printf '\033[1;33m[SKIP]\033[0m  %s\n' "$1"; }

# ---------------------------------------------------------------------------
# Preflight: Homebrew must be available
# ---------------------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
    printf '\033[1;31m[ERROR]\033[0m Homebrew not found. Run install-base.sh first.\n' >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Brewfile.devbox
# ---------------------------------------------------------------------------
info "Installing devbox packages from Brewfile.devbox..."
brew bundle --file="$REPO_ROOT/brewfiles/Brewfile.devbox" --no-lock

# Brewfile.local (user extension hook)
if [[ -f "$REPO_ROOT/brewfiles/Brewfile.local" ]]; then
    info "Installing packages from Brewfile.local..."
    brew bundle --file="$REPO_ROOT/brewfiles/Brewfile.local" --no-lock
fi

# ---------------------------------------------------------------------------
# Global dev packages
# ---------------------------------------------------------------------------
info "Installing global dev packages..."
source "$REPO_ROOT/globals/globals.devbox.sh"

# ---------------------------------------------------------------------------
# Devbox shell overlay
# ---------------------------------------------------------------------------
mkdir -p "$HOME/.zshrc.d"
cp "$REPO_ROOT/dotfiles/devbox/50-devbox.zsh" "$HOME/.zshrc.d/50-devbox.zsh"
info "Installed ~/.zshrc.d/50-devbox.zsh"

# ---------------------------------------------------------------------------
# Display detection (apply once)
# ---------------------------------------------------------------------------
if [[ "$(uname)" == "Darwin" ]]; then
    info "Detecting display configuration..."
    source "$REPO_ROOT/macos/display-watch.sh" --apply-once
fi

info "install-devbox.sh complete. Restart your terminal for all changes to take effect."
