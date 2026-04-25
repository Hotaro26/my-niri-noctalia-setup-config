#!/bin/bash
pkill -9 -f "qs.*shell"
sed -i "s|noctalia-shell|niri-caelestia-shell|g" ~/.config/niri/config.kdl
killall mako
qs -c niri-caelestia-shell > /dev/null 2>&1 &
niri msg action load-config-file
