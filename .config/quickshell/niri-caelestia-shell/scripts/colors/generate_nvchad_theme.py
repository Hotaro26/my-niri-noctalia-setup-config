#!/usr/bin/env python3
"""
generate_nvchad_theme.py
────────────────────────────────────────────────────────────────────────────────
Reads Material You colors from matugen's generated colors.json and writes:

  ~/.config/nvim/lua/themes/niri-caelestia.lua
  ~/.config/nvim/lua/chadrc.lua  (patched to activate the theme)

Then reloads running Neovim instances via --server remote-send.

Root cause of previous "No such theme!" errors:
  Every base46 theme MUST end with:
    M = require("base46").override_theme(M, "theme-name")
  This is how base46's get_theme_tb() validates and registers the theme.
  Without it, pcall(require, "themes.name") succeeds but the returned table
  fails base46's internal checks → "No such theme!".

  Source: all real base46 themes e.g.
    github.com/NvChad/base46/blob/v3.0/lua/base46/themes/tokyonight.lua
    github.com/NvChad/base46/blob/v3.0/lua/base46/themes/aquarium.lua

Usage:
  python3 generate_nvchad_theme.py                     # dark (default)
  python3 generate_nvchad_theme.py --light             # light variant
  python3 generate_nvchad_theme.py --dry-run           # preview, no writes
  python3 generate_nvchad_theme.py --no-reload         # write, skip reload
  python3 generate_nvchad_theme.py --diag              # show path diagnostics
  python3 generate_nvchad_theme.py --colors ~/my.json  # custom source

Dependencies: stdlib only
────────────────────────────────────────────────────────────────────────────────
"""

import json
import os
import re
import subprocess
import sys
import argparse
import glob
import colorsys
from pathlib import Path

# ── Paths ──────────────────────────────────────────────────────────────────────
# CRITICAL: THEME_NAME must exactly match the filename (without .lua)
# base46 resolves: require("themes." .. name) → lua/themes/<name>.lua

THEME_NAME          = "niri-caelestia"
DEFAULT_COLORS_JSON = Path.home() / ".local/state/quickshell/user/generated/colors.json"
NVIM_CONFIG_DIR     = Path.home() / ".config/nvim"
NVIM_THEME_DIR      = NVIM_CONFIG_DIR / "lua" / "themes"
THEME_FILE          = NVIM_THEME_DIR / f"{THEME_NAME}.lua"
CHADRC_FILE         = NVIM_CONFIG_DIR / "lua" / "chadrc.lua"

# ── Color Utilities ────────────────────────────────────────────────────────────

def hex_to_rgb(h: str) -> tuple:
    h = h.lstrip("#")
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))

def rgb_to_hex(r, g, b) -> str:
    return "#{:02x}{:02x}{:02x}".format(
        max(0, min(255, round(float(r)))),
        max(0, min(255, round(float(g)))),
        max(0, min(255, round(float(b)))),
    )

def lighten(col: str, amt: float) -> str:
    r, g, b = hex_to_rgb(col)
    h, l, s = colorsys.rgb_to_hls(r/255, g/255, b/255)
    r2, g2, b2 = colorsys.hls_to_rgb(h, min(1.0, l + amt), s)
    return rgb_to_hex(r2*255, g2*255, b2*255)

def darken(col: str, amt: float) -> str:
    r, g, b = hex_to_rgb(col)
    h, l, s = colorsys.rgb_to_hls(r/255, g/255, b/255)
    r2, g2, b2 = colorsys.hls_to_rgb(h, max(0.0, l - amt), s)
    return rgb_to_hex(r2*255, g2*255, b2*255)

def mix(a: str, b: str, ratio: float = 0.5) -> str:
    ra, ga, ba = hex_to_rgb(a)
    rb, gb, bb = hex_to_rgb(b)
    return rgb_to_hex(
        ra + (rb - ra) * ratio,
        ga + (gb - ga) * ratio,
        ba + (bb - ba) * ratio,
    )

def luminance(col: str) -> float:
    def lin(c): return c/12.92 if c <= 0.04045 else ((c+0.055)/1.055)**2.4
    r, g, b = [lin(x/255) for x in hex_to_rgb(col)]
    return 0.2126*r + 0.7152*g + 0.0722*b

def contrast_ratio(a: str, b: str) -> float:
    la, lb = luminance(a) + 0.05, luminance(b) + 0.05
    return max(la, lb) / min(la, lb)

def ensure_contrast(fg: str, bg: str, min_ratio: float = 3.0) -> str:
    is_dark_bg = luminance(bg) < 0.5
    for _ in range(40):
        if contrast_ratio(fg, bg) >= min_ratio:
            break
        fg = lighten(fg, 0.03) if is_dark_bg else darken(fg, 0.03)
    return fg

# ── Palette Builder ────────────────────────────────────────────────────────────

def build_palette(c: dict, dark: bool) -> tuple:
    """
    Maps Material You roles → NvChad base46 base_16 + base_30.

    base_30 keys match exactly what base46 expects (from README + real themes):
      white darker_black black black2 one_bg one_bg2 one_bg3
      grey grey_fg grey_fg2 light_grey
      red baby_pink pink line green vibrant_green nord_blue blue seablue
      yellow sun purple dark_purple teal orange cyan
      statusline_bg lightbg pmenu_bg folder_bg
    Note: lightbg2 is NOT in the official base46 base_30 spec.
    """

    # Material You aliases
    bg           = c["background"]
    fg           = c["on_background"]
    surf_low     = c["surface_container_lowest"]
    surf_cont    = c["surface_container"]
    primary      = c["primary"]
    on_primary_c = c["on_primary_container"]
    secondary    = c["secondary"]
    on_second_c  = c["on_secondary_container"]
    tertiary     = c["tertiary"]
    tert_c       = c["tertiary_container"]
    on_tert_c    = c["on_tertiary_container"]
    error        = c["error"]
    on_error_c   = c["on_error_container"]
    outline      = c["outline"]
    outline_var  = c["outline_variant"]
    inv_surf     = c["inverse_surface"]
    on_surf_var  = c["on_surface_variant"]
    on_surf      = c["on_surface"]

    # ── base_16: Base16 spec ───────────────────────────────────────────────
    base_16 = {
        "base00": bg,            # Default Background
        "base01": surf_low,      # Lighter bg (status bars, line number bg)
        "base02": surf_cont,     # Selection Background
        "base03": outline_var,   # Comments, Invisibles
        "base04": on_surf_var,   # Dark Foreground (status bars)
        "base05": fg,            # Default Foreground, caret, delimiters
        "base06": on_surf,       # Light Foreground
        "base07": inv_surf,      # Light Background (rarely used)
        "base08": on_error_c,    # Variables, XML Tags          — red
        "base09": tertiary,      # Integers, Booleans           — orange
        "base0A": tert_c,        # Classes, Search Background   — yellow
        "base0B": secondary,     # Strings, Inherited Class     — green
        "base0C": on_second_c,   # Support, Escape Characters   — cyan
        "base0D": primary,       # Functions, Methods           — blue
        "base0E": on_tert_c,     # Keywords, Storage            — purple
        "base0F": error,         # Deprecated, Error            — dark red
    }

    # ── base_30: bg ramp (percentages from base46 README) ─────────────────
    if dark:
        darker_black = darken(bg,  0.06)          # 6% darker
        black        = bg
        black2       = lighten(bg, 0.06)          # 6% lighter
        one_bg       = lighten(bg, 0.10)          # 10% lighter
        one_bg2      = lighten(bg, 0.10 + 0.06)  # 6% lighter than one_bg
        one_bg3      = lighten(bg, 0.10 + 0.12)  # 6% lighter than one_bg2
        line         = lighten(bg, 0.15)          # 15% lighter
    else:
        darker_black = lighten(bg, 0.06)
        black        = bg
        black2       = darken(bg,  0.06)
        one_bg       = darken(bg,  0.10)
        one_bg2      = darken(bg,  0.10 + 0.06)
        one_bg3      = darken(bg,  0.10 + 0.12)
        line         = darken(bg,  0.15)

    # ── base_30: accent colors ─────────────────────────────────────────────
    red           = ensure_contrast(error,                           bg)
    baby_pink     = ensure_contrast(lighten(error, 0.18),            bg)
    pink          = ensure_contrast(on_error_c,                      bg)
    orange        = ensure_contrast(tertiary,                        bg)
    yellow        = ensure_contrast(
                        tert_c if dark else darken(tert_c, 0.30),    bg)
    green         = ensure_contrast(secondary,                       bg)
    vibrant_green = ensure_contrast(lighten(secondary, 0.10),        bg)
    blue          = ensure_contrast(primary,                         bg)
    seablue       = ensure_contrast(mix(primary, on_second_c, 0.45), bg)
    nord_blue     = ensure_contrast(mix(primary, on_primary_c, 0.3), bg)
    cyan          = ensure_contrast(on_second_c,                     bg)
    teal          = ensure_contrast(mix(secondary, primary, 0.4),    bg)
    purple        = ensure_contrast(on_tert_c,                       bg)
    dark_purple   = ensure_contrast(
                        tert_c if dark else darken(tert_c, 0.35),    bg)
    sun           = ensure_contrast(c.get("tertiary_fixed", tertiary), bg)

    # ── base_30: final table (keys must match base46 spec exactly) ────────
    base_30 = {
        "white":          fg,
        "darker_black":   darker_black,
        "black":          black,
        "black2":         black2,
        "one_bg":         one_bg,
        "one_bg2":        one_bg2,
        "one_bg3":        one_bg3,
        "grey":           outline,
        "grey_fg":        ensure_contrast(lighten(outline, 0.10), bg),
        "grey_fg2":       ensure_contrast(lighten(outline, 0.05), bg),
        "light_grey":     ensure_contrast(on_surf_var,            bg),
        "red":            red,
        "baby_pink":      baby_pink,
        "pink":           pink,
        "line":           line,
        "green":          green,
        "vibrant_green":  vibrant_green,
        "nord_blue":      nord_blue,
        "blue":           blue,
        "seablue":        seablue,
        "yellow":         yellow,
        "sun":            sun,
        "purple":         purple,
        "dark_purple":    dark_purple,
        "teal":           teal,
        "orange":         orange,
        "cyan":           cyan,
        "statusline_bg":  surf_low,
        "lightbg":        one_bg2,
        "pmenu_bg":       primary,
        "folder_bg":      primary,
    }

    return base_16, base_30

# ── Lua Theme Generator ────────────────────────────────────────────────────────
# Template matches real base46 themes exactly:
#   github.com/NvChad/base46/blob/v3.0/lua/base46/themes/tokyonight.lua
#
# CRITICAL: The final line:
#   M = require("base46").override_theme(M, "name")
# is REQUIRED. Without it base46's get_theme_tb() rejects the theme with
# "No such theme!" even if the file exists and is valid Lua.

LUA_TEMPLATE = """\
-- AUTO-GENERATED — do not edit manually
-- Theme  : {theme_name}
-- Source : Material You (matugen) → colors.json
-- Mode   : {mode}

---@type Base46Table
local M = {{}}

M.base_30 = {{
{base_30}
}}

M.base_16 = {{
{base_16}
}}

M.type = "{mode}"

-- REQUIRED: base46 uses this to register and validate the theme.
-- Without this line, base46 throws "No such theme!" at compile time.
M = require("base46").override_theme(M, "{theme_name}")

return M
"""

def fmt_table(d: dict) -> str:
    w = max(len(k) for k in d)
    return "\n".join(f'  {k}{" "*(w-len(k))} = "{v}",' for k, v in d.items())

def generate_lua(b16: dict, b30: dict, dark: bool) -> str:
    return LUA_TEMPLATE.format(
        theme_name = THEME_NAME,
        base_16    = fmt_table(b16),
        base_30    = fmt_table(b30),
        mode       = "dark" if dark else "light",
    )

# ── chadrc.lua Auto-Patcher ────────────────────────────────────────────────────

CHADRC_MINIMAL = f"""\
-- Auto-generated by generate_nvchad_theme.py
local M = {{}}

M.base46 = {{
  theme        = "{THEME_NAME}",
  theme_toggle = {{ "{THEME_NAME}", "{THEME_NAME}" }},
}}

return M
"""

def patch_chadrc():
    if not CHADRC_FILE.exists():
        CHADRC_FILE.parent.mkdir(parents=True, exist_ok=True)
        CHADRC_FILE.write_text(CHADRC_MINIMAL)
        print(f'  ✓  Created chadrc.lua → theme = "{THEME_NAME}"')
        return

    content = CHADRC_FILE.read_text()

    if re.search(r'theme\s*=\s*["\']' + re.escape(THEME_NAME) + r'["\']', content):
        print(f'  ✓  chadrc.lua already uses "{THEME_NAME}"')
        return

    # Replace existing theme = "..." value
    new, n = re.subn(
        r'(theme\s*=\s*)["\'][^"\']*["\']',
        f'\\1"{THEME_NAME}"',
        content, count=1,
    )
    if n:
        CHADRC_FILE.write_text(new)
        print(f'  ✓  Patched chadrc.lua → theme = "{THEME_NAME}"')
        return

    # Has M.base46 block but no theme key
    if "M.base46" in content:
        new = content.replace(
            "M.base46 = {",
            f'M.base46 = {{\n  theme = "{THEME_NAME}",', 1)
        CHADRC_FILE.write_text(new)
        print(f'  ✓  Injected theme into M.base46 → "{THEME_NAME}"')
        return

    # Append before final return M
    block = (
        f'\nM.base46 = {{\n'
        f'  theme        = "{THEME_NAME}",\n'
        f'  theme_toggle = {{ "{THEME_NAME}", "{THEME_NAME}" }},\n'
        f'}}\n'
    )
    new = content.replace("return M", block + "\nreturn M", 1) if "return M" in content else content + block
    CHADRC_FILE.write_text(new)
    print(f'  ✓  Appended M.base46 to chadrc.lua → "{THEME_NAME}"')

# ── Neovim Reload ──────────────────────────────────────────────────────────────

def reload_nvim():
    uid = os.getuid()
    xdg = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{uid}")
    sockets = list(set(
        glob.glob(f"{xdg}/nvim.*") +
        glob.glob(f"/tmp/nvim{uid}*/*/nvim.*.0")
    ))

    if not sockets:
        print("  ⚠  No running Neovim instances found.")
        print("     Open Neovim — theme loads automatically on next start.")
        return

    # Bust Lua require cache for our theme, then recompile everything
    lua = (
        ':lua package.loaded["themes.' + THEME_NAME + '"] = nil; '
        'require("nvconfig").base46.theme = "' + THEME_NAME + '"; '
        'require("base46").load_all_highlights()<CR>'
    )
    for addr in sockets:
        try:
            r = subprocess.run(
                ["nvim", "--server", addr, "--remote-send", lua],
                capture_output=True, text=True, timeout=5,
            )
            if r.returncode == 0:
                print(f"  ✓  Reloaded: {addr}")
            else:
                print(f"  ✗  Failed [{addr}]: {(r.stderr or r.stdout).strip()}")
        except subprocess.TimeoutExpired:
            print(f"  ⚠  Timeout: {addr}")
        except FileNotFoundError:
            print("  ✗  'nvim' not in PATH.")
            break

# ── Diagnostics ────────────────────────────────────────────────────────────────

def print_diagnostics():
    print("\n  Diagnostics:")
    print(f"    Theme name      : {THEME_NAME}")
    print(f"    Theme file      : {THEME_FILE}")
    print(f"    File exists     : {THEME_FILE.exists()}")
    print(f"    Lua require     : require(\"themes.{THEME_NAME}\")")
    print(f"    override_theme  : M = require(\"base46\").override_theme(M, \"{THEME_NAME}\")")
    print(f"    Nvim config dir : {NVIM_CONFIG_DIR}")
    print(f"    chadrc.lua      : {CHADRC_FILE} ({'exists' if CHADRC_FILE.exists() else 'MISSING'})")
    if CHADRC_FILE.exists():
        m = re.search(r'theme\s*=\s*["\']([^"\']*)["\']', CHADRC_FILE.read_text())
        print(f"    Active theme    : {m.group(1) if m else '(not set)'}")
    if THEME_FILE.exists():
        content = THEME_FILE.read_text()
        has_override = f'override_theme(M, "{THEME_NAME}")' in content
        print(f"    Has override    : {'✓  YES' if has_override else '✗  NO  ← this causes No such theme!'}")
    print()

# ── Main ───────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description=f"Generate NvChad '{THEME_NAME}' theme from matugen colors.json",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("--colors", "-c", type=Path, default=DEFAULT_COLORS_JSON)
    parser.add_argument("--dark",  dest="mode", action="store_const", const="dark", default="dark")
    parser.add_argument("--light", dest="mode", action="store_const", const="light")
    parser.add_argument("--dry-run",   action="store_true")
    parser.add_argument("--no-reload", action="store_true")
    parser.add_argument("--diag",      action="store_true")
    args = parser.parse_args()
    dark = (args.mode == "dark")

    print(f"\n  NvChad theme generator — {THEME_NAME}")
    print(  "  " + "─" * 54)

    if args.diag:
        print_diagnostics()
        return

    # 1 ── Load colors.json ────────────────────────────────────────────────
    colors_path = args.colors.expanduser().resolve()
    if not colors_path.exists():
        print(f"\n  ✗  Not found: {colors_path}", file=sys.stderr)
        sys.exit(1)

    print(f"  [1/4] Reading  : {colors_path}")
    with open(colors_path) as f:
        raw = json.load(f)

    colors = {}
    for k, v in raw.items():
        v = str(v).strip()
        colors[k] = (v if v.startswith("#") else "#" + v).lower()

    # 2 ── Build palette ───────────────────────────────────────────────────
    print(f"  [2/4] Building : {'dark' if dark else 'light'} palette …")
    try:
        b16, b30 = build_palette(colors, dark)
    except KeyError as e:
        print(f"\n  ✗  Missing key in colors.json: {e}", file=sys.stderr)
        sys.exit(1)

    # 3 ── Generate Lua ────────────────────────────────────────────────────
    lua = generate_lua(b16, b30, dark)

    if args.dry_run:
        print(f"\n  [dry-run] Would write → {THEME_FILE}\n")
        print("─" * 78)
        print(lua)
        print("─" * 78)
        print_diagnostics()
        return

    # 4 ── Write + patch chadrc ────────────────────────────────────────────
    print(f"  [3/4] Writing  : {THEME_FILE}")
    NVIM_THEME_DIR.mkdir(parents=True, exist_ok=True)
    THEME_FILE.write_text(lua)
    print(f"        Patching : {CHADRC_FILE}")
    patch_chadrc()

    # 5 ── Reload Neovim ───────────────────────────────────────────────────
    if not args.no_reload:
        print(f"  [4/4] Reloading Neovim …")
        reload_nvim()
    else:
        print(f"  [4/4] Skipped (--no-reload)")

    print(f"\n  ✓  Done — \"{THEME_NAME}\" is active!\n")


if __name__ == "__main__":
    main()
