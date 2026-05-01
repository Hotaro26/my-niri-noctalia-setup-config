# My Niri + Noctalia + Caelestia Setup

This repository contains my personal Arch Linux desktop configuration, featuring a dual-shell setup (Noctalia and Caelestia) with a custom QML switcher.

## 🚀 Quick Start / Restore

Follow these steps to replicate this setup on a fresh Arch Linux installation.

### 1. Install Dependencies
First, install the base packages from the official repositories:
```bash
sudo pacman -S --needed - < pkglist-repo.txt
```

Then, install the AUR packages using your preferred helper (e.g., `yay`):
```bash
yay -S --needed - < pkglist-aur.txt
```

### 2. Restore Configurations
Copy the config files and scripts to your home directory:
```bash
cp -rv .config/* ~/.config/
cp -rv .local/bin/* ~/.local/bin/
chmod +x ~/.local/bin/*.sh
```

### 3. Build Caelestia Shell Components
The Caelestia shell requires a manual build of its C++ plugin:
```bash
cd ~/.config/quickshell/niri-caelestia-shell
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/
cmake --build build
sudo cmake --install build
./scripts/setup/v2/setup install --no-interaction
```

## 🎮 Features & Usage

### 🔄 The Shell Switcher
I've implemented a custom QML GUI to toggle between shells.
*   **Keybinding:** `Mod + Shift + S`
*   **Action:** A popup appears letting you choose between **Noctalia** and **Caelestia**.
*   **Cancel:** Press `ESC` to close without switching.

### 🌓 Night Light (Blue Light Filter)
I've integrated a custom Night Light feature into the Caelestia dashboard.
*   **Location:** Dashboard (`Mod + Comma`) -> **System** Tab.
*   **Controls:** Toggle ON/OFF and adjust temperature via the slider.
*   **Backend:** Powered by `hyprsunset`.

### ⌨️ Important Keybindings
*   `Mod + Space`: Smart Launcher (Opens the correct launcher for your active shell).
*   `Mod + Shift + L`: Lock Screen (Caelestia style).
*   `Mod + V`: Clipboard Manager.
*   `Mod + D`: Dashboard / Widgets.
*   `Mod + S`: Control Center.

## 📁 Repository Structure
*   `.config/niri`: Niri compositor settings.
*   `.config/noctalia`: Original Noctalia Shell configuration.
*   `.config/quickshell/niri-caelestia-shell`: The Caelestia Shell source and QML.
*   `.config/shell-switcher`: Source for the QML Switcher GUI.
*   `.local/bin`: Custom wrapper scripts for the "Smart" logic.
*   `pkglist-*.txt`: Snapshots of installed packages.


<img width="1920" height="1078" alt="image" src="https://github.com/user-attachments/assets/9e0ebfc1-8e96-45ed-8b25-778d0a117242" />

<img width="1920" height="1078" alt="image" src="https://github.com/user-attachments/assets/4f65f2f5-a7ce-48e1-9139-4335220a3ae2" />
