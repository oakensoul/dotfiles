#!/usr/bin/env bash
#
# display-watch.sh — Detect hardware model and display count, apply appropriate power profile
#
# Usage:
#   display-watch.sh --apply-once    # Detect and apply, then exit
#   display-watch.sh --daemon        # Poll every 30s, reapply on change
#
# Testable via environment variables:
#   HW_MODEL_CMD="echo MacBookPro18,1" DISPLAY_INFO_CMD="cat test-displays.txt" ./display-watch.sh --apply-once
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="$HOME/.loadout/logs/display-watch.log"

info()  { printf '\033[1;34m[INFO]\033[0m  %s\n' "$1"; }

get_hw_model() {
    ${HW_MODEL_CMD:-sysctl -n hw.model}
}

get_display_count() {
    local timeout_cmd=""
    if command -v timeout >/dev/null 2>&1; then
        timeout_cmd="timeout 10"
    elif command -v gtimeout >/dev/null 2>&1; then
        timeout_cmd="gtimeout 10"
    fi
    # shellcheck disable=SC2086
    ${timeout_cmd} ${DISPLAY_INFO_CMD:-system_profiler SPDisplaysDataType} 2>/dev/null | grep -c "Resolution:" || echo "0"
}

apply_profile() {
    local model="$1"
    local displays="$2"

    info "Hardware: $model, Displays: $displays"

    case "$model" in
        MacBook*)
            if [[ "$displays" -ge 2 ]]; then
                info "Applying laptop-connected profile (docked)"
                source "$SCRIPT_DIR/defaults-laptop-connected.sh"
            else
                info "Applying laptop-solo profile"
                source "$SCRIPT_DIR/defaults-laptop-solo.sh"
            fi
            ;;
        *)
            info "Applying desktop profile"
            source "$SCRIPT_DIR/defaults-desktop.sh"
            ;;
    esac
}

run_once() {
    local model displays
    model="$(get_hw_model)"
    displays="$(get_display_count)"
    apply_profile "$model" "$displays"
}

run_daemon() {
    mkdir -p "$(dirname "$LOG_FILE")"
    info "Starting display-watch daemon (logging to $LOG_FILE)"

    local last_count=""
    while true; do
        local model displays
        model="$(get_hw_model)"
        displays="$(get_display_count)"

        if [[ "$displays" != "$last_count" ]]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') Display count changed: ${last_count:-none} -> $displays" | tee -a "$LOG_FILE"
            apply_profile "$model" "$displays"
            last_count="$displays"
        fi

        sleep 30
    done
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
case "${1:-}" in
    --apply-once)
        run_once
        ;;
    --daemon)
        run_daemon
        ;;
    *)
        echo "Usage: display-watch.sh [--apply-once|--daemon]" >&2
        exit 1
        ;;
esac
