# Package installers for niri-caelestia-shell
install-python-packages(){
  echo -e "${STY_CYAN}Setting up Python 3.12 virtual environment...${STY_RST}"
  
  # Ensure uv is available
  if ! command -v uv &>/dev/null; then
    echo -e "${STY_BLUE}Installing uv...${STY_RST}"
    curl -LJs https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
  fi

  # Path from original script
  VENV_DIR="${XDG_STATE_HOME}/quickshell/.venv"
  mkdir -p "$VENV_DIR"

  # Create venv with specific version and prompt
  v uv venv --prompt caelestia "$VENV_DIR" -p 3.12
  
  # Install dependencies using the new requirements location
  source "$VENV_DIR/bin/activate"
  v uv pip install -r "$REPO_ROOT/scripts/setup/v2/sdata/uv/requirements.txt"
  deactivate
  
  echo -e "${STY_GREEN}Python environment ready.${STY_RST}"
}
