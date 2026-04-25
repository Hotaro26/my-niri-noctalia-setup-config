#!/bin/bash

# Detect which shell is running in the Niri config
CONFIG_FILE="$HOME/.config/niri/config.kdl"

if grep -q "niri-caelestia-shell" "$CONFIG_FILE"; then
    # Caelestia is active
    qs -c niri-caelestia-shell ipc call drawers toggle launcher
else
    # Noctalia is active
    qs -c noctalia-shell ipc call launcher toggle
fi
