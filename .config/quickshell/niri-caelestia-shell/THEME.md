# Niri Caelestia Shell — Dynamic Color Theming

This guide provides a deep dive into the dynamic color generation system used in the Niri Caelestia Shell. This system implements a full **Material You (Material 3)** pipeline, ensuring that your entire desktop—from window borders to terminal escape sequences—stays in perfect sync with your wallpaper.

---

## 1. Architectural Overview

The system uses a multi-stage pipeline to generate and propagate colors:

1.  **Extraction**: When a wallpaper is set, `matugen` parses the image to extract a dominant color and generate a full Material 3 palette.
2.  **Template Processing**: Matugen uses templates in `~/.config/matugen/templates/` to generate configuration files for various toolkits (GTK, KDE, Niri, etc.).
3.  **Python Enhancement**: A dedicated Python script (`generate_colors_material.py`) further refines these colors for specific use cases like terminal harmonization and SCSS variable generation.
4.  **Live Application**: The `applycolor.sh` script pushes these changes to running applications using IPC (for Niri/Quickshell) and escape sequences (for terminals).

---

## 2. Dynamic Shader Animations

One of the most advanced features of this shell is the use of **shader-based window animations** in Niri. These are defined in `~/.config/niri/niri/animations.kdl` and use custom GLSL code:

*   **Window Open (Rise & Fade)**: A custom cubic curve shader that makes windows appear to rise 5% from below the bottom center while scaling from 95% to 100% and fading in.
*   **Window Close (Sink & Dissolve)**: Inverts the opening logic, pushing windows downward as they fade out and shrink back to 95%.
*   **Structural Snappiness**: Uses critically damped springs (`damping-ratio=1.0`) for workspace and column transitions, providing a zero-wobble, high-performance "QML-like" feel.

---

## 3. Targeted Applications & Toolkits

### GTK 3 & GTK 4
Colors are injected into `~/.config/gtk-3.0/gtk.css` and `~/.config/gtk-4.0/gtk.css`. This ensures that Adwaita and other GTK apps respect your wallpaper's accent colors.

### KDE & Qt (Kvantum)
*   **KDE Globals**: Matugen generates a `color.txt` which updates the global KDE color scheme.
*   **Darkly Style**: The shell uses the `Darkly` widget style for native Qt widgets.
*   **Kvantum**: Complex Qt apps use the `MaterialAdw` theme, which is a Kvantum port designed to match modern libadwaita visuals.

### Niri Compositor
The focus ring and layout accents are updated via `~/.config/niri/colors.kdl`. This file is an included part of the main Niri config and is updated every time the wallpaper changes.

### Login Screen (SDDM)
The `niri-caelestia-sddm` theme is integrated directly into the pipeline.
*   **Shell Integrate Mode**: In its default configuration, the SDDM theme reads the shell's current state from `~/.local/state/quickshell/user/generated/colors.json`, ensuring your login screen matches your desktop perfectly.

---

## 4. Setup & Prerequisites

### Required Packages (Arch Linux)
```bash
sudo pacman -S matugen python-pillow python-materialyoucolor jq socat
# AUR
yay -S darkly-bin adw-gtk-theme-git
```

### Matugen Configuration
The main configuration file is located at `~/.config/matugen/config.toml`. It defines "templates" which map source files to their target application configs.

**Example Template (MPV):**
```toml
[templates.mpv]
input_path = '~/.config/matugen/templates/mpv/mpv.conf'
output_path = '~/.config/mpv/script-opts/niri_caelestia.conf'
```

---

## 5. Usage & Manual Control

### Automatic (UI Triggered)
When you change your wallpaper through the Quickshell dashboard, the shell automatically invokes `scripts/colors/switchwall.sh`.

### Manual (CLI Triggered)
You can force a theme update or use specific modes from your terminal:

```bash
# Update everything based on an image
bash ~/.config/quickshell/niri-caelestia-shell/scripts/colors/switchwall.sh /path/to/image.jpg

# Use Light Mode
bash ~/.config/quickshell/niri-caelestia-shell/scripts/colors/switchwall.sh --mode light /path/to/image.jpg

# Generate Vibrant scheme variants
matugen image --type scheme-vibrant /path/to/image.jpg
```

---

## 6. Output Locations Reference

Generated state files are stored in `~/.local/state/quickshell/user/generated/`:

*   `colors.json`: The raw Material 3 color tokens.
*   `color.txt`: KDE color specification.
*   `terminal/sequences.txt`: ANSI escape sequences for live terminal colors.
*   `wallpaper/path.txt`: Contains the path to the current wallpaper.

---

## 7. Troubleshooting

### Colors not applying to Terminal?
Ensure your terminal (like Kitty) is configured to use the generated theme. In your `kitty.conf`, you should see:
`include ~/.local/state/quickshell/user/generated/terminal/kitty-theme.conf`

### GTK apps look inconsistent?
Make sure `gsettings` is pointing to the right theme. The shell environment forces:
`QT_STYLE_OVERRIDE "kvantum"` and `QT_QPA_PLATFORMTHEME "kde"`.

---

## Credits
*   **End4**: For the original `ii` shell implementation and inspiration for the color pipeline.
*   **Google Material Design**: For the Material 3 (M3) color science.
*   **InioX**: Creator of Matugen.
