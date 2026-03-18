#!/usr/bin/env bash
#
# statusline.sh — Claude Code custom status line
#
# Reads JSON from stdin, outputs a formatted single-line status.
# Format: repo | user | branch | S:n U:n ?:n | aida | model | ctx: N% | $X.XX
#
# Requires: jq (installed via brew if missing)
#

# Ensure jq is available
if ! command -v jq >/dev/null 2>&1; then
    echo "jq not found"
    exit 0
fi

# Read JSON from stdin
json="$(cat)"
if [[ -z "$json" ]]; then
    exit 0
fi

# ---------------------------------------------------------------------------
# Colors (ANSI)
# ---------------------------------------------------------------------------
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
WHITE='\033[37m'
MAGENTA='\033[35m'
RESET='\033[0m'

# ---------------------------------------------------------------------------
# Git: repo name and branch
# ---------------------------------------------------------------------------
# Get working directory from JSON (try both real and mock field paths)
cwd="$(echo "$json" | jq -r '.cwd // .workspace.current_dir // empty' 2>/dev/null)"

repo_name=""
git_username=""
branch=""
staged=0
unstaged=0
untracked=0

if [[ -n "$cwd" ]] && [[ -d "$cwd" ]]; then
    # Repo name: top-level dir basename, or cwd basename if not a repo
    repo_root="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)"
    if [[ -n "$repo_root" ]]; then
        repo_name="$(basename "$repo_root")"
        branch="$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)"
        git_username="$(git -C "$cwd" config user.username 2>/dev/null)"

        # Staged count
        staged="$(git -C "$cwd" diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')"
        # Unstaged count (tracked files only)
        unstaged="$(git -C "$cwd" diff --numstat 2>/dev/null | wc -l | tr -d ' ')"
        # Untracked count
        untracked="$(git -C "$cwd" ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')"
    else
        repo_name="$(basename "$cwd")"
    fi
else
    repo_name="unknown"
fi

# ---------------------------------------------------------------------------
# AIDA: check for project configuration
# ---------------------------------------------------------------------------
aida_status=""
project_dir="$(echo "$json" | jq -r '.workspace.project_dir // empty' 2>/dev/null)"
# Try project_dir first, fall back to git root, fall back to cwd
aida_check_dir="${project_dir:-${repo_root:-$cwd}}"
aida_config="$aida_check_dir/.claude/aida-project-context.yml"
aida_marketplace="$HOME/.claude/plugins/marketplaces/aida/.claude-plugin/marketplace.json"
if [[ -n "$aida_check_dir" ]] && [[ -f "$aida_config" ]]; then
    aida_ver="$(grep -m1 '^version:' "$aida_config" 2>/dev/null | sed 's/^version:[[:space:]]*//' | tr -d "\"'")"
    # Get installed plugin version for comparison
    aida_installed=""
    if [[ -f "$aida_marketplace" ]]; then
        aida_installed="$(jq -r '.plugins[] | select(.name=="aida-core") | .version // empty' "$aida_marketplace" 2>/dev/null)"
    fi
    if [[ -n "$aida_ver" ]]; then
        if [[ -n "$aida_installed" ]] && [[ "$aida_ver" != "$aida_installed" ]]; then
            # Version mismatch — yellow with installed version hint
            aida_status="${YELLOW}aida \xe2\x9a\xa0 ${aida_ver} \xe2\x86\x92 ${aida_installed}${RESET}"
        else
            aida_status="${GREEN}aida \xe2\x9c\x93 ${aida_ver}${RESET}"
        fi
    else
        aida_status="${GREEN}aida \xe2\x9c\x93${RESET}"
    fi
else
    aida_status="${RED}aida \xe2\x9c\x97${RESET}"
fi

# ---------------------------------------------------------------------------
# Model: shorten display name
# ---------------------------------------------------------------------------
model_display="$(echo "$json" | jq -r '.model.display_name // empty' 2>/dev/null)"
model_id="$(echo "$json" | jq -r '.model.id // empty' 2>/dev/null)"

# Shorten model: prefer id-based mapping, fall back to display name
model=""
case "$model_id" in
    *opus-4-6*)     model="opus-4.6" ;;
    *opus-4-5*)     model="opus-4.5" ;;
    *opus*)         model="opus" ;;
    *sonnet-4-6*)   model="sonnet-4.6" ;;
    *sonnet-4-5*)   model="sonnet-4.5" ;;
    *sonnet-4*)     model="sonnet-4" ;;
    *haiku-4-5*)    model="haiku-4.5" ;;
    *haiku*)        model="haiku" ;;
    *)
        # Fall back to display_name-based matching
        case "$model_display" in
            *opus*4.6*|*Opus*4.6*)     model="opus-4.6" ;;
            *opus*4.5*|*Opus*4.5*)     model="opus-4.5" ;;
            *[Oo]pus*)                 model="opus" ;;
            *sonnet*4.6*|*Sonnet*4.6*) model="sonnet-4.6" ;;
            *sonnet*4.5*|*Sonnet*4.5*) model="sonnet-4.5" ;;
            *sonnet*4*|*Sonnet*4*)     model="sonnet-4" ;;
            *haiku*4.5*|*Haiku*4.5*)   model="haiku-4.5" ;;
            *[Hh]aiku*)                model="haiku" ;;
            "")                        model="—" ;;
            *)                         model="$model_display" ;;
        esac
        ;;
esac

# ---------------------------------------------------------------------------
# Context window % used
# ---------------------------------------------------------------------------
ctx_pct="$(echo "$json" | jq -r '.context_window.used_percentage // empty' 2>/dev/null)"
ctx_pct="${ctx_pct:-0}"

if (( ctx_pct > 70 )); then
    ctx_color="$RED"
elif (( ctx_pct > 40 )); then
    ctx_color="$YELLOW"
else
    ctx_color="$GREEN"
fi

# ---------------------------------------------------------------------------
# Session cost
# ---------------------------------------------------------------------------
cost="$(echo "$json" | jq -r '.cost.total_cost_usd // .cost_usd.session // 0' 2>/dev/null)"
cost_fmt="$(printf '%.2f' "${cost:-0}")"

# ---------------------------------------------------------------------------
# Assemble output
# ---------------------------------------------------------------------------
parts=()

# Repo name — cyan
parts+=("${CYAN}${repo_name}${RESET}")

# GitHub username — magenta (omit if not set)
if [[ -n "$git_username" ]]; then
    parts+=("${MAGENTA}${git_username}${RESET}")
fi

# Branch — green (only if in a git repo)
if [[ -n "$branch" ]]; then
    parts+=("${GREEN}${branch}${RESET}")
fi

# Git status counts — yellow, only non-zero
git_counts=""
[[ "$staged" -gt 0 ]]    && git_counts+="S:${staged} "
[[ "$unstaged" -gt 0 ]]  && git_counts+="U:${unstaged} "
[[ "$untracked" -gt 0 ]] && git_counts+="?:${untracked} "
git_counts="${git_counts% }"
if [[ -n "$git_counts" ]]; then
    parts+=("${YELLOW}${git_counts}${RESET}")
fi

# AIDA status
parts+=("$aida_status")

# Model — white
parts+=("${WHITE}${model}${RESET}")

# Context — color coded
parts+=("${ctx_color}ctx: ${ctx_pct}%${RESET}")

# Cost — white
parts+=("${WHITE}\$${cost_fmt}${RESET}")

# Join with " | "
output=""
for i in "${!parts[@]}"; do
    if [[ "$i" -gt 0 ]]; then
        output+=" | "
    fi
    output+="${parts[$i]}"
done

printf '%b\n' "$output"
