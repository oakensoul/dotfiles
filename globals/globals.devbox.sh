#!/usr/bin/env bash
#
# globals.devbox.sh — Install global dev packages (npm, pip)
# Idempotent: safe to re-run.
#

set -euo pipefail

info()  { printf '\033[1;34m[INFO]\033[0m  %s\n' "$1"; }
skip()  { printf '\033[1;33m[SKIP]\033[0m  %s\n' "$1"; }
install_msg() { printf '\033[1;32m[INSTALL]\033[0m  %s\n' "$1"; }

# ---------------------------------------------------------------------------
# Global npm packages
# ---------------------------------------------------------------------------
if command -v npm >/dev/null 2>&1; then
    npm_globals=(
        typescript
        ts-node
        prettier
        eslint
    )
    for pkg in "${npm_globals[@]}"; do
        if npm list -g "$pkg" >/dev/null 2>&1; then
            skip "npm: $pkg already installed"
        else
            install_msg "npm: installing $pkg..."
            npm install -g "$pkg"
        fi
    done
else
    info "npm not found — run globals.base.sh first"
fi

# ---------------------------------------------------------------------------
# Global pip packages
# ---------------------------------------------------------------------------
if command -v pip3 >/dev/null 2>&1; then
    pip_globals=(
        black
        ruff
        mypy
    )
    for pkg in "${pip_globals[@]}"; do
        if pip3 show "$pkg" >/dev/null 2>&1; then
            skip "pip: $pkg already installed"
        else
            install_msg "pip: installing $pkg..."
            pip3 install "$pkg"
        fi
    done
else
    info "pip3 not found — run globals.base.sh first"
fi

info "globals.devbox.sh complete"
