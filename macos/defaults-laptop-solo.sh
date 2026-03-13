#!/usr/bin/env bash
#
# defaults-laptop-solo.sh — Power management for laptops with no external display
# Battery-friendly sleep timers.
#

# Battery
sudo pmset -b sleep 15
sudo pmset -b displaysleep 5
sudo pmset -b disksleep 10

# AC Power
sudo pmset -c sleep 30
sudo pmset -c displaysleep 10
sudo pmset -c disksleep 15
