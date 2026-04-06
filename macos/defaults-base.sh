#!/usr/bin/env bash
#
# defaults-base.sh — macOS system defaults (base layer)
# Safe to re-run. Applies to all machine types.
#

# ---------------------------------------------------------------------------
# Dock
# ---------------------------------------------------------------------------
defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock tilesize -int 25
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -int 75
defaults write com.apple.dock autohide -bool false
defaults write com.apple.dock show-recents -bool false

# ---------------------------------------------------------------------------
# Keyboard
# ---------------------------------------------------------------------------
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# ---------------------------------------------------------------------------
# Finder
# ---------------------------------------------------------------------------
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# ---------------------------------------------------------------------------
# Screenshots
# ---------------------------------------------------------------------------
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Screenshots"
defaults write com.apple.screencapture disable-shadow -bool true

# ---------------------------------------------------------------------------
# Security
# ---------------------------------------------------------------------------
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# ---------------------------------------------------------------------------
# Apply changes
# ---------------------------------------------------------------------------
killall Dock Finder SystemUIServer 2>/dev/null || true
