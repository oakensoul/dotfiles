# 50-devbox.zsh — Developer tools overlay
# Installed to ~/.zshrc.d/ by Loadout install-devbox.sh

# ---------------------------------------------------------------------------
# Docker
# ---------------------------------------------------------------------------
if command -v docker >/dev/null 2>&1; then
    alias dk='docker'
    alias dkc='docker compose'
    alias dkps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
    alias dkprune='docker system prune -af'
fi

# ---------------------------------------------------------------------------
# GitHub CLI
# ---------------------------------------------------------------------------
if command -v gh >/dev/null 2>&1; then
    alias ghpr='gh pr create'
    alias ghprs='gh pr list'
    alias ghprv='gh pr view --web'
fi

# ---------------------------------------------------------------------------
# Node / npm
# ---------------------------------------------------------------------------
if command -v npm >/dev/null 2>&1; then
    alias ni='npm install'
    alias nr='npm run'
    alias nt='npm test'
    alias nrb='npm run build'
fi

# ---------------------------------------------------------------------------
# Lazygit
# ---------------------------------------------------------------------------
if command -v lazygit >/dev/null 2>&1; then
    alias lg='lazygit'
fi
