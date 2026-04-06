# ~/.zshrc — Loadout base shell configuration
# Managed by Loadout. Extend via ~/.zshrc.d/*.zsh and ~/.zshrc.local

# ---------------------------------------------------------------------------
# PATH
# ---------------------------------------------------------------------------
# Homebrew (auto-detect ARM vs Intel, skip if already configured e.g. devbox)
if [[ -z "$HOMEBREW_PREFIX" ]]; then
    if [[ -x "$HOME/.homebrew/bin/brew" ]]; then
        eval "$("$HOME/.homebrew/bin/brew" shellenv)"
    elif [[ -d /opt/homebrew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -d /usr/local/Homebrew ]]; then
        eval "$(/usr/local/Homebrew/bin/brew shellenv)"
    fi
fi

# User paths
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH"
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

# ---------------------------------------------------------------------------
# History
# ---------------------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_REDUCE_BLANKS

# ---------------------------------------------------------------------------
# Completion
# ---------------------------------------------------------------------------
fpath=($^fpath(-/N))  # strip non-existent dirs (avoids compinit insecure-files warning)
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

# ---------------------------------------------------------------------------
# nvm
# ---------------------------------------------------------------------------
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    source "$NVM_DIR/nvm.sh"
    [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
fi

# ---------------------------------------------------------------------------
# pyenv
# ---------------------------------------------------------------------------
if command -v pyenv >/dev/null 2>&1; then
    export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
    eval "$(pyenv init -)"
fi

# ---------------------------------------------------------------------------
# zoxide
# ---------------------------------------------------------------------------
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# ---------------------------------------------------------------------------
# fzf
# ---------------------------------------------------------------------------
if command -v fzf >/dev/null 2>&1; then
    # fzf 0.48+ uses built-in shell integration
    if [[ -n "$HOMEBREW_PREFIX" && -f "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh" ]]; then
        source "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
        source "$HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh"
    fi
fi

# ---------------------------------------------------------------------------
# Background git fetch check
# ---------------------------------------------------------------------------
__loadout_git_check() {
    local stamp_file="$HOME/.loadout/last-fetch"
    local now
    now="$(date +%s)"

    # Only run in a git repo
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return

    # Throttle: once per hour
    if [[ -f "$stamp_file" ]]; then
        local last
        last="$(cat "$stamp_file" 2>/dev/null)"
        if [[ -n "$last" ]] && (( now - last < 3600 )); then
            # Check if we already know we're behind
            local behind
            behind="$(git rev-list --count HEAD..@{u} 2>/dev/null)"
            if [[ -n "$behind" && "$behind" -gt 0 ]]; then
                printf '\033[1;33m[loadout]\033[0m %s is %d commit(s) behind upstream\n' \
                    "$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" "$behind"
            fi
            return
        fi
    fi

    # Background fetch
    {
        git fetch --quiet 2>/dev/null
        mkdir -p "$(dirname "$stamp_file")"
        date +%s > "$stamp_file"
    } &!

    # Check current state (from before fetch)
    local behind
    behind="$(git rev-list --count HEAD..@{u} 2>/dev/null)"
    if [[ -n "$behind" && "$behind" -gt 0 ]]; then
        printf '\033[1;33m[loadout]\033[0m %s is %d commit(s) behind upstream\n' \
            "$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" "$behind"
    fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd __loadout_git_check

# ---------------------------------------------------------------------------
# Terminal title — Org/repo (or Org/repo/worktree) when in git, else dirname
# ---------------------------------------------------------------------------
__set_terminal_title() {
    local title
    local git_root worktree_root remote_url slug

    git_root="$(git rev-parse --show-toplevel 2>/dev/null)"
    if [[ -n "$git_root" ]]; then
        # Extract org/repo from origin remote
        remote_url="$(git -C "$git_root" remote get-url origin 2>/dev/null)"
        slug="$(echo "$remote_url" | sed 's|.*github\.com[:/]\(.*\)\.git$|\1|; s|.*github\.com[:/]\(.*\)|\1|')"
        title="${slug:-${git_root:t}}"

        # Detect worktree: commondir differs from gitdir when in a linked worktree
        worktree_root="$(git rev-parse --git-common-dir 2>/dev/null)"
        local git_dir="$(git rev-parse --git-dir 2>/dev/null)"
        if [[ "$worktree_root" != "$git_dir" && "$worktree_root" != "." ]]; then
            title="${title}/${git_root:t}"
        fi
    else
        title="${PWD:t}"
    fi

    printf '\e]0;%s\a' "$title"
}
add-zsh-hook chpwd __set_terminal_title
__set_terminal_title  # set on shell start

# ---------------------------------------------------------------------------
# Overlay: ~/.zshrc.d/*.zsh (numeric-sorted)
# ---------------------------------------------------------------------------
if [[ -d "$HOME/.zshrc.d" ]]; then
    for f in "$HOME"/.zshrc.d/*.zsh(N); do
        source "$f"
    done
    unset f
fi

# ---------------------------------------------------------------------------
# Private overrides (last)
# ---------------------------------------------------------------------------
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
