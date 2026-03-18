#!/usr/bin/env bash
#
# defaults-laptop-connected.sh — Power management for docked laptops (external display)
# No sleep on AC (desktop-like behavior), battery still conserves.
#

# Battery (still conserve)
sudo pmset -b sleep 15
sudo pmset -b displaysleep 5
sudo pmset -b disksleep 10

# AC Power (docked: never sleep)
sudo pmset -c sleep 0
sudo pmset -c displaysleep 10
sudo pmset -c disksleep 0
