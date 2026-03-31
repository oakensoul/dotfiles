#!/usr/bin/env bash
#
# install-base.sh — Bootstrap base tools on a fresh macOS machine
# Installs: Xcode CLI tools, Homebrew, Brewfile.base, global runtimes, macOS defaults
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
# Xcode Command Line Tools
# ---------------------------------------------------------------------------
if xcode-select -p >/dev/null 2>&1; then
    skip "Xcode CLI tools already installed"
else
    info "Installing Xcode Command Line Tools..."
    xcode-select --install
    info "Waiting for Xcode CLI tools installation to complete..."
    until xcode-select -p >/dev/null 2>&1; do
        sleep 5
    done
fi

# ---------------------------------------------------------------------------
# Homebrew
# ---------------------------------------------------------------------------
if command -v brew >/dev/null 2>&1; then
    skip "Homebrew already installed"
else
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Load Homebrew into current session
    if [[ -d /opt/homebrew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -d /usr/local/Homebrew ]]; then
        eval "$(/usr/local/Homebrew/bin/brew shellenv)"
    fi
fi

# ---------------------------------------------------------------------------
# Brewfile.base
# ---------------------------------------------------------------------------
info "Installing base packages from Brewfile.base..."
brew bundle --file="$REPO_ROOT/brewfiles/Brewfile.base" --no-lock

# Brewfile.local (user extension hook)
if [[ -f "$REPO_ROOT/brewfiles/Brewfile.local" ]]; then
    info "Installing packages from Brewfile.local..."
    brew bundle --file="$REPO_ROOT/brewfiles/Brewfile.local" --no-lock
fi

# ---------------------------------------------------------------------------
# Global runtimes
# ---------------------------------------------------------------------------
info "Installing global runtimes..."
source "$REPO_ROOT/globals/globals.base.sh"

# ---------------------------------------------------------------------------
# macOS defaults
# ---------------------------------------------------------------------------
info "Applying macOS base defaults..."
source "$REPO_ROOT/macos/defaults-base.sh"

info "install-base.sh complete. Restart your terminal for all changes to take effect."
