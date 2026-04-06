#!/usr/bin/env bash
#
# defaults-desktop.sh — Power management for desktops (Mac Mini, Mac Pro, iMac)
# Never sleep, display sleep after 10 minutes, no screensaver.
#

sudo pmset -a sleep 0
sudo pmset -a displaysleep 10
sudo pmset -a disksleep 0
defaults write com.apple.screensaver idleTime -int 0
