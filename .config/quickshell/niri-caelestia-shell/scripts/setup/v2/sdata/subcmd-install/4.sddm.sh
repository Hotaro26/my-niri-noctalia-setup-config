# SDDM Setup for niri-caelestia-shell
echo -e "${STY_CYAN}Stage 4: SDDM Login Theme Setup${STY_RST}"

if [[ "$ask" != "false" ]]; then
  if ! tui_confirm "Would you like to install and configure the SDDM login theme?" "yes"; then
    echo -e "${STY_YELLOW}Skipping SDDM setup.${STY_RST}"
    return 0
  fi
fi

# 1. Detect and Disable other Display Managers
if command -v systemctl &>/dev/null; then
  echo -e "${STY_BLUE}Checking for active display managers...${STY_RST}"
  
  # List of common display managers to check
  DMS=("gdm" "lightdm" "ly" "lxdm" "slim" "greetd")
  
  for dm in "${DMS[@]}"; do
    if systemctl is-enabled "$dm" &>/dev/null; then
      echo -e "${STY_YELLOW}Detected active display manager: $dm${STY_RST}"
      if [[ "$ask" != "false" ]]; then
        if tui_confirm "Disable $dm to enable SDDM instead?" "yes"; then
          v sudo systemctl disable "$dm"
        fi
      else
        v sudo systemctl disable "$dm"
      fi
    fi
  done
fi

# 2. Ensure SDDM is installed and enabled
if ! command -v sddm &>/dev/null; then
  echo -e "${STY_BLUE}Installing SDDM...${STY_RST}"
  v sudo pacman -S --needed --noconfirm sddm
fi

# Enable SDDM (this will fail if another DM is still enabled and active)
echo -e "${STY_BLUE}Enabling SDDM service...${STY_RST}"
v sudo systemctl enable sddm

# 3. Run the theme setup script with automated input
SDDM_THEME_SRC="$REPO_ROOT/dotfiles/niri-caelestia-sddm"
if [[ -d "$SDDM_THEME_SRC" ]]; then
    echo -e "${STY_BLUE}Configuring niri-caelestia-sddm theme...${STY_RST}"
    
    # We navigate to the theme source and run its setup.
    # We pipe "1" to automatically select "Shell Integrate" mode.
    # We use sudo -E to preserve environment variables if needed.
    (
        cd "$SDDM_THEME_SRC"
        chmod +x setup.sh
        echo "1" | v ./setup.sh
    )
else
    echo -e "${STY_RED}Error: SDDM theme source not found at $SDDM_THEME_SRC${STY_RST}"
    return 1
fi

echo -e "${STY_GREEN}SDDM theme integrated successfully!${STY_RST}"
echo -e "  ${STY_DIM}Note: The theme will be active after your next reboot.${STY_RST}"
