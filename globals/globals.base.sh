#!/usr/bin/env bash
#
# globals.base.sh — Install global language runtimes and tools
# Idempotent: safe to re-run.
#

set -euo pipefail

info()  { printf '\033[1;34m[INFO]\033[0m  %s\n' "$1"; }
skip()  { printf '\033[1;33m[SKIP]\033[0m  %s\n' "$1"; }
install_msg() { printf '\033[1;32m[INSTALL]\033[0m  %s\n' "$1"; }

# ---------------------------------------------------------------------------
# nvm + Node LTS
# ---------------------------------------------------------------------------
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    skip "nvm already installed at $NVM_DIR"
else
    install_msg "Installing nvm..."
    PROFILE=/dev/null bash -c 'curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash'
fi

# Source nvm for this session
# shellcheck source=/dev/null
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

if command -v nvm >/dev/null 2>&1; then
    if nvm ls --no-colors lts/* 2>/dev/null | grep -q "N/A"; then
        install_msg "Installing Node LTS..."
        nvm install --lts
        nvm alias default 'lts/*'
    else
        skip "Node LTS already installed"
    fi
else
    info "nvm not available in this session — restart shell and re-run"
fi

# ---------------------------------------------------------------------------
# pyenv + Python
# ---------------------------------------------------------------------------
if command -v pyenv >/dev/null 2>&1; then
    skip "pyenv already installed"
    eval "$(pyenv init -)"

    latest_python="$(pyenv install --list 2>/dev/null | grep -E '^\s+3\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')"
    if [[ -n "$latest_python" ]]; then
        if pyenv versions --bare | grep -qF "$latest_python"; then
            skip "Python $latest_python already installed"
        else
            install_msg "Installing Python $latest_python..."
            pyenv install "$latest_python"
        fi
        pyenv global "$latest_python"
    fi
else
    info "pyenv not found — install via Homebrew first (brew install pyenv)"
fi

# ---------------------------------------------------------------------------
# Claude Code
# ---------------------------------------------------------------------------
if command -v claude >/dev/null 2>&1; then
    skip "Claude Code already installed"
else
    install_msg "Installing Claude Code..."
    # Note: inspect installer for profile suppression options if it modifies shell configs
    curl -fsSL https://claude.ai/install.sh | bash
fi

info "globals.base.sh complete"
