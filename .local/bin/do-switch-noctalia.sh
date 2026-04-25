#!/bin/bash
pkill -9 -f "qs.*shell"
sed -i "s|niri-caelestia-shell|noctalia-shell|g" ~/.config/niri/config.kdl
mako &
qs -c noctalia-shell > /dev/null 2>&1 &
niri msg action load-config-file
