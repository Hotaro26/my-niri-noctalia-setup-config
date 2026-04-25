# System setup for niri-caelestia-shell
echo -e "${STY_CYAN}Configuring system settings and directories...${STY_RST}"

# 1. Precise Directory Structure
echo -e "${STY_BLUE}Creating required state directories...${STY_RST}"
mkdir -p "${XDG_STATE_HOME}/quickshell/user/generated/terminal"
mkdir -p "${XDG_STATE_HOME}/quickshell/user/generated/wallpaper"
mkdir -p "${XDG_CONFIG_HOME}/environment.d"
mkdir -p "${XDG_CONFIG_HOME}/Kvantum"
mkdir -p "${XDG_BIN_HOME}"

# 2. Python Venv Setup
showfun install-python-packages
v install-python-packages

# 3. Environment Variable Deployment
echo -e "${STY_BLUE}Configuring environment variables across shells...${STY_RST}"
VENV_PATH="${XDG_STATE_HOME}/quickshell/.venv"
ENV_LINE="export CAELESTIA_VIRTUAL_ENV=\"$VENV_PATH\""

# Bash configuration
if [[ -f "$HOME/.bashrc" ]]; then
  if ! grep -q 'CAELESTIA_VIRTUAL_ENV' "$HOME/.bashrc"; then
    echo -e "\n# niri-caelestia-shell Python venv\n$ENV_LINE" >> "$HOME/.bashrc"
    echo -e "  ${STY_DIM}Updated ~/.bashrc${STY_RST}"
  fi
fi

# Zsh configuration
if [[ -f "$HOME/.zshrc" ]]; then
  if ! grep -q 'CAELESTIA_VIRTUAL_ENV' "$HOME/.zrc"; then
    echo -e "\n# niri-caelestia-shell Python venv\n$ENV_LINE" >> "$HOME/.zshrc"
    echo -e "  ${STY_DIM}Updated ~/.zshrc${STY_RST}"
  fi
fi

# Fish configuration
mkdir -p "${XDG_CONFIG_HOME}/fish/conf.d"
echo "set -gx CAELESTIA_VIRTUAL_ENV \"$VENV_PATH\"" > "${XDG_CONFIG_HOME}/fish/conf.d/caelestia.fish"
echo -e "  ${STY_DIM}Updated Fish conf.d${STY_RST}"

# Systemd user session environment
echo "CAELESTIA_VIRTUAL_ENV=$VENV_PATH" > "${XDG_CONFIG_HOME}/environment.d/caelestia.conf"
echo -e "  ${STY_DIM}Updated environment.d${STY_RST}"

# 4. Hardware Groups
echo -e "${STY_BLUE}Setting up user groups (video, i2c, input)...${STY_RST}"
if [[ -z $(getent group i2c) ]]; then sudo groupadd i2c; fi
sudo usermod -aG video,i2c,input "$(whoami)"

# 5. Systemd Services
if command -v systemctl &>/dev/null; then
  echo -e "${STY_BLUE}Enabling background services...${STY_RST}"
  echo "i2c-dev" | sudo tee /etc/modules-load.d/i2c-dev.conf > /dev/null
  if [[ -f /usr/lib/systemd/system/ydotool.service ]]; then
    sudo ln -sf /usr/lib/systemd/{system,user}/ydotool.service
    systemctl --user daemon-reload
    systemctl --user enable ydotool --now || true
  fi
  sudo systemctl enable bluetooth --now || true
fi

# 6. UI & Desktop Defaults
echo -e "${STY_BLUE}Setting UI preferences...${STY_RST}"
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || true
kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle Darkly || true
gsettings set org.gnome.desktop.interface font-name 'Google Sans Flex 11' || true
