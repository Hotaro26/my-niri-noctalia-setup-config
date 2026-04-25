# Distro determination
OS_RELEASE_FILE=/etc/os-release
OS_DISTRO_ID=$(awk -F'=' '/^ID=/ { gsub("\"","",$2); print tolower($2) }' ${OS_RELEASE_FILE})
OS_DISTRO_ID_LIKE=$(awk -F'=' '/^ID_LIKE=/ { gsub("\"","",$2); print tolower($2) }' ${OS_RELEASE_FILE})

if [[ "$OS_DISTRO_ID" =~ ^(arch|endeavouros|cachyos)$ ]] || [[ "$OS_DISTRO_ID_LIKE" == "arch" ]]; then
  OS_GROUP_ID="arch"
  print_os_group_id_functions=(print_os_group_id)
else
  echo -e "${STY_RED}Unsupported distro: $OS_DISTRO_ID. This installer targets Arch.${STY_RST}"
  exit 1
fi

function print_os_group_id(){
  echo -e "${STY_CYAN}Detected: $OS_DISTRO_ID ($OS_GROUP_ID)${STY_RST}"
}
