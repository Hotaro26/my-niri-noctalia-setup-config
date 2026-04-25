# niri-caelestia-sddm

An SDDM theme that matches the **niri-caelestia-shell** lockscreen — so your login screen and desktop lockscreen look identical.

Built with Qt QML. Color theming via [Matugen](https://github.com/InioX/matugen) (same pipeline your shell already uses).

---

## What it looks like

The design directly mirrors the Caelestia lockscreen:

- **Large clock** — Rubik Light, `hh:mm` with dimmed seconds
- **Date line** — subtle, letter-spaced
- **Avatar circle** — 76px, reads from `/var/lib/AccountsService/icons/<user>`, Material You primary-color ring + glow
- **Username** — medium weight, centered
- **Password pill** — translucent `surface` container, primary-color border on focus, arrow-forward unlock button, shake + error color on wrong password
- **Bottom bar** — session picker · keyboard layout selector · suspend / reboot / power-off — all in matching translucent pills
- **Entry animation** — fade-in + upward slide, matching shell drawer animations

Colors are the same Material You dark tokens Matugen generates for your shell — `primary`, `surface`, `onSurface`, etc.

---

## Dependencies

```bash
yay -S --needed sddm qt6-svg qt6-multimedia-ffmpeg
```

Fonts used (already in your shell setup):
- `ttf-rubik` or `rubik` — clock + UI text
- `ttf-jetbrains-mono-nerd` — mono
- `ttf-material-symbols-variable-git` — icons

---

## Installation

```bash
git clone https://github.com/yourname/niri-caelestia-sddm
cd niri-caelestia-sddm
./setup.sh
```

The script detects whether you have Matugen and walks you through the right mode.

### Manual install

```bash
# 1. Copy theme
sudo mkdir -p /usr/share/sddm/themes/niri-caelestia-sddm
sudo cp -r . /usr/share/sddm/themes/niri-caelestia-sddm/

# 2. Copy config files
mkdir -p ~/.config/niri-caelestia-sddm
cp Matugen/SddmColors.qml ~/.config/niri-caelestia-sddm/
cp Matugen/Colors.qml     ~/.config/niri-caelestia-sddm/
cp Matugen/sddm-theme-apply.sh ~/.config/niri-caelestia-sddm/
cp Components/Settings.qml    ~/.config/niri-caelestia-sddm/
chmod +x ~/.config/niri-caelestia-sddm/sddm-theme-apply.sh

# 3. Configure /etc/sddm.conf
sudo tee /etc/sddm.conf << CONF
[Theme]
Current=niri-caelestia-sddm
CONF

# 4. Apply initial colors
sudo ~/.config/niri-caelestia-sddm/sddm-theme-apply.sh
```

---

## Matugen integration

Add to `~/.config/matugen/config.toml`:

```toml
[templates.niri-caelestia-sddm]
input_path  = '~/.config/niri-caelestia-sddm/SddmColors.qml'
output_path = '~/.config/niri-caelestia-sddm/Colors.qml'
post_hook   = 'sudo ~/.config/niri-caelestia-sddm/sddm-theme-apply.sh &'
```

Now whenever your shell regenerates colors (wallpaper change), SDDM colors update automatically too.

For the passwordless sudo:
```bash
echo "$USER ALL=(ALL) NOPASSWD: $HOME/.config/niri-caelestia-sddm/sddm-theme-apply.sh" \
    | sudo tee /etc/sudoers.d/caelestia-sddm-$USER
sudo chmod 0440 /etc/sudoers.d/caelestia-sddm-$USER
```

---

## Customization

Edit `~/.config/niri-caelestia-sddm/Settings.qml`:

```qml
readonly property string wallpaperPath: "/home/user/Pictures/Wallpapers/wall.jpg"
readonly property bool   blurWallpaper: true
readonly property int    blurRadius:    55
readonly property real   dimOpacity:    0.4
readonly property bool   showAvatars:   true
readonly property int    animDuration:  280
```

Then apply:
```bash
sudo ~/.config/niri-caelestia-sddm/sddm-theme-apply.sh
```

---

## Testing

```bash
./test.sh
# or
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/niri-caelestia-sddm
```

---

## File structure

```
niri-caelestia-sddm/
├── Main.qml                    ← entry point
├── metadata.desktop
├── theme.conf
├── setup.sh                    ← interactive installer
├── test.sh
├── Components/
│   ├── LockContent.qml         ← clock → avatar → user → password
│   ├── ClockWidget.qml         ← large Rubik clock
│   ├── AvatarWidget.qml        ← avatar circle with primary ring
│   ├── BottomBar.qml           ← session / kb / power pills
│   ├── PowerButton.qml         ← icon action button
│   ├── PillBox.qml             ← reusable pill container
│   ├── Colors.qml              ← ← REPLACED by Matugen on wallpaper change
│   └── Settings.qml            ← ← REPLACED by apply script
├── Backgrounds/
│   └── wallpaper.jpg           ← ← REPLACED by apply script
├── Matugen/
│   ├── SddmColors.qml          ← Matugen input template
│   ├── Colors.qml              ← default palette (fallback)
│   ├── matugen-config.toml     ← snippet to add to your matugen config
│   └── sddm-theme-apply.sh     ← copy to ~/.config/niri-caelestia-sddm/
├── noMatugen/
│   ├── Colors.qml              ← same default palette
│   ├── Settings.qml            ← same Settings template
│   └── sddm-theme-apply.sh
└── fonts/
    └── caelestia-sddm-fonts/   ← bundled font files (optional)
```

---

## Credits

- [niri-caelestia-shell](https://github.com/AyushKr2003/niri-caelestia-shell) — the shell this theme matches
- [Caelestia Shell](https://github.com/caelestia-dots/shell) — original lockscreen design
- [ii-sddm-theme](https://github.com/3d3f/ii-sddm-theme) — architecture reference
- [Matugen](https://github.com/InioX/matugen) — Material You color generation
- [Quickshell](https://quickshell.org) — powers the shell itself
