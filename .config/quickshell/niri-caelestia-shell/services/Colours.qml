pragma Singleton
pragma ComponentBehavior: Bound

import qs.config
import qs.utils
import Caelestia
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool showPreview
    property bool transitioning
    property string scheme
    property string flavour
    readonly property bool light: showPreview ? previewLight : currentLight
    property bool currentLight
    property bool previewLight
    readonly property M3Palette palette: showPreview ? preview : current
    readonly property M3TPalette tPalette: M3TPalette {}
    readonly property M3Palette current: M3Palette {}
    readonly property M3Palette preview: M3Palette {}
    readonly property Transparency transparency: Transparency {}
    property real wallLuminance

    property bool _updatePending: false

    function requestUpdate() {
        if (!_updatePending) {
            _updatePending = true;
            _luminanceCache = {};
            _luminanceCacheSize = 0;
            Qt.callLater(() => {
                _updatePending = false;
                tPalette.updateAll();
            });
        }
    }

    // Invalidate luminance cache and schedule tPalette update when inputs change
    onShowPreviewChanged: requestUpdate()
    onWallLuminanceChanged: requestUpdate()
    onLightChanged: requestUpdate()

    Connections {
        target: root.transparency
        function onEnabledChanged(): void { root.requestUpdate(); }
        function onBaseChanged(): void { root.requestUpdate(); }
        function onLayersChanged(): void { root.requestUpdate(); }
    }

    Connections {
        target: root.palette
        function onM3primaryChanged(): void { root.requestUpdate(); }
        function onM3surfaceChanged(): void { root.requestUpdate(); }
        function onM3backgroundChanged(): void { root.requestUpdate(); }
        function onM3secondaryChanged(): void { root.requestUpdate(); }
        function onM3tertiaryChanged(): void { root.requestUpdate(); }
        function onM3errorChanged(): void { root.requestUpdate(); }
    }

    // Luminance cache to avoid redundant Math.pow() calls
    property var _luminanceCache: ({})
    property int _luminanceCacheSize: 0

    function getLuminance(c: color): real {
        if (c.r == 0 && c.g == 0 && c.b == 0)
            return 0;
        // Use color string as cache key
        const key = "" + c;
        if (key in _luminanceCache)
            return _luminanceCache[key];
        const val = Math.sqrt(0.299 * (c.r * c.r) + 0.587 * (c.g * c.g) + 0.114 * (c.b * c.b));
        // Limit cache size to prevent unbounded growth
        if (_luminanceCacheSize > 200) {
            _luminanceCache = {};
            _luminanceCacheSize = 0;
        }
        _luminanceCache[key] = val;
        _luminanceCacheSize++;
        return val;
    }

    function alterColour(c: color, a: real, layer: int): color {
        const luminance = getLuminance(c);

        const offset = (!light || layer == 1 ? 1 : -layer / 2) * (light ? 0.2 : 0.3) * (1 - transparency.base) * (1 + wallLuminance * (light ? (layer == 1 ? 3 : 1) : 2.5));
        const scale = (luminance + offset) / luminance;
        const r = Math.max(0, Math.min(1, c.r * scale));
        const g = Math.max(0, Math.min(1, c.g * scale));
        const b = Math.max(0, Math.min(1, c.b * scale));

        return Qt.rgba(r, g, b, a);
    }

    function layer(c: color, layer: var): color {
        if (!transparency.enabled)
            return c;

        return layer === 0 ? Qt.alpha(c, transparency.base) : alterColour(c, transparency.layers, layer ?? 1);
    }

    function on(c: color): color {
        if (c.hslLightness < 0.5)
            return Qt.hsla(c.hslHue, c.hslSaturation, 0.9, 1);
        return Qt.hsla(c.hslHue, c.hslSaturation, 0.1, 1);
    }

    function load(data: string, isPreview: bool): void {
        root.transitioning = true;
        const colours = isPreview ? preview : current;
        const scheme = JSON.parse(data);
        console.log("Colours.load called, isPreview:", isPreview, "scheme name:", scheme.name);

        if (!isPreview) {
            root.scheme = scheme.name;
            flavour = scheme.flavour;
            currentLight = scheme.mode === "light";
        } else {
            previewLight = scheme.mode === "light";
        }

        let loadedCount = 0;
        for (const [name, colour] of Object.entries(scheme.colours)) {
            const propName = name.startsWith("term") ? name : `m3${name}`;
            if (colours.hasOwnProperty(propName)) {
                colours[propName] = `#${colour}`;
                loadedCount++;
            }
        }
        console.log("Colours.load: loaded", loadedCount, "colors out of", Object.keys(scheme.colours).length);
        // Recompute tPalette after batch color changes
        requestUpdate();
        transitionTimer.restart();
    }

    Timer {
        id: transitionTimer
        interval: 200
        onTriggered: root.transitioning = false
    }

    // Set mode (light/dark) and save to state file
    function setMode(mode: string): void {
        schemeStateFile.setMode(mode);
    }

    // Save current scheme state to file
    function saveSchemeState(name: string, flavour: string, mode: string, variant: string, colours: var): void {
        const stateData = {
            name: name,
            flavour: flavour,
            mode: mode,
            variant: variant,
            colours: colours
        };

        // Ensure directory exists, then write via FileView
        const jsonContent = JSON.stringify(stateData, null, 2);
        ensureStateDirProcess._pendingContent = jsonContent;
        ensureStateDirProcess.running = true;
    }

    FileView {
        id: schemeStateFile

        path: `${Paths.state}/scheme.json`
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.load(text(), false)

        // Helper to update the mode while preserving other state
        function setMode(mode: string): void {
            let currentState = {
                name: "dynamic",
                flavour: "default",
                mode: mode,
                variant: "tonalspot",
                colours: {}
            };
            try {
                const t = text();
                if (t && t.trim().length > 0) {
                    const parsed = JSON.parse(t);
                    if (parsed && typeof parsed === 'object') {
                        currentState = parsed;
                        currentState.mode = mode;
                    }
                }
            } catch (e) {
                console.warn("Failed to parse existing mode state, using default dynamic scheme:", e);
            }

            root.saveSchemeState(
                currentState.name,
                currentState.flavour,
                mode,
                currentState.variant,
                currentState.colours || {}
            );
            // Update local state
            root.currentLight = (mode === "light");
        }
    }

    Process {
        id: ensureStateDirProcess

        property string _pendingContent

        command: ["mkdir", "-p", Paths.state]
        running: false

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0 && _pendingContent) {
                schemeStateFile.watchChanges = false;
                schemeStateFile.setText(_pendingContent);
                schemeStateFile.watchChanges = true;
            }
        }
    }

    Connections {
        target: Wallpapers

        function onCurrentChanged(): void {
            wallAnalyser.source = Wallpapers.current;

            // Regenerate dynamic scheme if currently active
            Schemes.regenerateDynamic();
        }
    }

    ImageAnalyser {
        id: wallAnalyser
        onLuminanceChanged: root.wallLuminance = luminance
    }

    component Transparency: QtObject {
        readonly property bool reduceTransparency: Appearance.transparency.reduceTransparency
        readonly property bool enabled: Appearance.transparency.enabled && !reduceTransparency
        readonly property real base: reduceTransparency ? 1.0 : Appearance.transparency.base - (root.light ? 0.1 : 0)
        readonly property real layers: reduceTransparency ? 1.0 : Appearance.transparency.layers
    }

    // Batched transparent palette — computed imperatively to avoid 54 reactive bindings
    component M3TPalette: QtObject {
        property color m3primary_paletteKeyColor
        property color m3secondary_paletteKeyColor
        property color m3tertiary_paletteKeyColor
        property color m3neutral_paletteKeyColor
        property color m3neutral_variant_paletteKeyColor
        property color m3background
        property color m3onBackground
        property color m3surface
        property color m3surfaceDim
        property color m3surfaceBright
        property color m3surfaceContainerLowest
        property color m3surfaceContainerLow
        property color m3surfaceContainer
        property color m3surfaceContainerHigh
        property color m3surfaceContainerHighest
        property color m3onSurface
        property color m3surfaceVariant
        property color m3onSurfaceVariant
        property color m3inverseSurface
        property color m3inverseOnSurface
        property color m3outline
        property color m3outlineVariant
        property color m3shadow
        property color m3scrim
        property color m3surfaceTint
        property color m3primary
        property color m3onPrimary
        property color m3primaryContainer
        property color m3onPrimaryContainer
        property color m3inversePrimary
        property color m3secondary
        property color m3onSecondary
        property color m3secondaryContainer
        property color m3onSecondaryContainer
        property color m3tertiary
        property color m3onTertiary
        property color m3tertiaryContainer
        property color m3onTertiaryContainer
        property color m3error
        property color m3onError
        property color m3errorContainer
        property color m3onErrorContainer
        property color m3primaryFixed
        property color m3primaryFixedDim
        property color m3onPrimaryFixed
        property color m3onPrimaryFixedVariant
        property color m3secondaryFixed
        property color m3secondaryFixedDim
        property color m3onSecondaryFixed
        property color m3onSecondaryFixedVariant
        property color m3tertiaryFixed
        property color m3tertiaryFixedDim
        property color m3onTertiaryFixed
        property color m3onTertiaryFixedVariant

        // Recompute all palette colors in one pass when inputs change
        function updateAll(): void {
            const p = root.palette;
            // Layer-0 colors (use base alpha)
            m3background = root.layer(p.m3background, 0);
            m3surface = root.layer(p.m3surface, 0);
            m3surfaceDim = root.layer(p.m3surfaceDim, 0);
            m3surfaceBright = root.layer(p.m3surfaceBright, 0);
            m3surfaceVariant = root.layer(p.m3surfaceVariant, 0);
            m3inverseSurface = root.layer(p.m3inverseSurface, 0);
            // Layer-1 colors (default layer)
            m3primary_paletteKeyColor = root.layer(p.m3primary_paletteKeyColor);
            m3secondary_paletteKeyColor = root.layer(p.m3secondary_paletteKeyColor);
            m3tertiary_paletteKeyColor = root.layer(p.m3tertiary_paletteKeyColor);
            m3neutral_paletteKeyColor = root.layer(p.m3neutral_paletteKeyColor);
            m3neutral_variant_paletteKeyColor = root.layer(p.m3neutral_variant_paletteKeyColor);
            m3onBackground = root.layer(p.m3onBackground);
            m3surfaceContainerLowest = root.layer(p.m3surfaceContainerLowest);
            m3surfaceContainerLow = root.layer(p.m3surfaceContainerLow);
            m3surfaceContainer = root.layer(p.m3surfaceContainer);
            m3surfaceContainerHigh = root.layer(p.m3surfaceContainerHigh);
            m3surfaceContainerHighest = root.layer(p.m3surfaceContainerHighest);
            m3onSurface = root.layer(p.m3onSurface);
            m3onSurfaceVariant = root.layer(p.m3onSurfaceVariant);
            m3inverseOnSurface = root.layer(p.m3inverseOnSurface);
            m3outline = root.layer(p.m3outline);
            m3outlineVariant = root.layer(p.m3outlineVariant);
            m3shadow = root.layer(p.m3shadow);
            m3scrim = root.layer(p.m3scrim);
            m3surfaceTint = root.layer(p.m3surfaceTint);
            m3primary = root.layer(p.m3primary);
            m3onPrimary = root.layer(p.m3onPrimary);
            m3primaryContainer = root.layer(p.m3primaryContainer);
            m3onPrimaryContainer = root.layer(p.m3onPrimaryContainer);
            m3inversePrimary = root.layer(p.m3inversePrimary);
            m3secondary = root.layer(p.m3secondary);
            m3onSecondary = root.layer(p.m3onSecondary);
            m3secondaryContainer = root.layer(p.m3secondaryContainer);
            m3onSecondaryContainer = root.layer(p.m3onSecondaryContainer);
            m3tertiary = root.layer(p.m3tertiary);
            m3onTertiary = root.layer(p.m3onTertiary);
            m3tertiaryContainer = root.layer(p.m3tertiaryContainer);
            m3onTertiaryContainer = root.layer(p.m3onTertiaryContainer);
            m3error = root.layer(p.m3error);
            m3onError = root.layer(p.m3onError);
            m3errorContainer = root.layer(p.m3errorContainer);
            m3onErrorContainer = root.layer(p.m3onErrorContainer);
            m3primaryFixed = root.layer(p.m3primaryFixed);
            m3primaryFixedDim = root.layer(p.m3primaryFixedDim);
            m3onPrimaryFixed = root.layer(p.m3onPrimaryFixed);
            m3onPrimaryFixedVariant = root.layer(p.m3onPrimaryFixedVariant);
            m3secondaryFixed = root.layer(p.m3secondaryFixed);
            m3secondaryFixedDim = root.layer(p.m3secondaryFixedDim);
            m3onSecondaryFixed = root.layer(p.m3onSecondaryFixed);
            m3onSecondaryFixedVariant = root.layer(p.m3onSecondaryFixedVariant);
            m3tertiaryFixed = root.layer(p.m3tertiaryFixed);
            m3tertiaryFixedDim = root.layer(p.m3tertiaryFixedDim);
            m3onTertiaryFixed = root.layer(p.m3onTertiaryFixed);
            m3onTertiaryFixedVariant = root.layer(p.m3onTertiaryFixedVariant);
        }
    }

    component M3Palette: QtObject {
        property color m3primary_paletteKeyColor: "#a26387"
        property color m3secondary_paletteKeyColor: "#8b6f7d"
        property color m3tertiary_paletteKeyColor: "#9c6c53"
        property color m3neutral_paletteKeyColor: "#7f7478"
        property color m3neutral_variant_paletteKeyColor: "#827379"
        property color m3background: "#181115"
        property color m3onBackground: "#eddfe4"
        property color m3surface: "#181115"
        property color m3surfaceDim: "#181115"
        property color m3surfaceBright: "#40373b"
        property color m3surfaceContainerLowest: "#130c10"
        property color m3surfaceContainerLow: "#211a1d"
        property color m3surfaceContainer: "#251e21"
        property color m3surfaceContainerHigh: "#30282b"
        property color m3surfaceContainerHighest: "#3b3236"
        property color m3onSurface: "#eddfe4"
        property color m3surfaceVariant: "#504349"
        property color m3onSurfaceVariant: "#d3c2c9"
        property color m3inverseSurface: "#eddfe4"
        property color m3inverseOnSurface: "#362e32"
        property color m3outline: "#9c8d93"
        property color m3outlineVariant: "#504349"
        property color m3shadow: "#000000"
        property color m3scrim: "#000000"
        property color m3surfaceTint: "#fbb1d8"
        property color m3primary: "#fbb1d8"
        property color m3onPrimary: "#511d3e"
        property color m3primaryContainer: "#6b3455"
        property color m3onPrimaryContainer: "#ffd8ea"
        property color m3inversePrimary: "#864b6e"
        property color m3secondary: "#dfbecd"
        property color m3onSecondary: "#402a36"
        property color m3secondaryContainer: "#5a424f"
        property color m3onSecondaryContainer: "#fcd9e9"
        property color m3tertiary: "#f3ba9c"
        property color m3onTertiary: "#4a2713"
        property color m3tertiaryContainer: "#b8856a"
        property color m3onTertiaryContainer: "#000000"
        property color m3error: "#ffb4ab"
        property color m3onError: "#690005"
        property color m3errorContainer: "#93000a"
        property color m3onErrorContainer: "#ffdad6"
        property color m3primaryFixed: "#ffd8ea"
        property color m3primaryFixedDim: "#fbb1d8"
        property color m3onPrimaryFixed: "#370728"
        property color m3onPrimaryFixedVariant: "#6b3455"
        property color m3secondaryFixed: "#fcd9e9"
        property color m3secondaryFixedDim: "#dfbecd"
        property color m3onSecondaryFixed: "#291520"
        property color m3onSecondaryFixedVariant: "#58404c"
        property color m3tertiaryFixed: "#ffdbca"
        property color m3tertiaryFixedDim: "#f3ba9c"
        property color m3onTertiaryFixed: "#311302"
        property color m3onTertiaryFixedVariant: "#653d27"
        property color term0: "#353434"
        property color term1: "#fe45a7"
        property color term2: "#ffbac0"
        property color term3: "#ffdee3"
        property color term4: "#b3a2d5"
        property color term5: "#e491bd"
        property color term6: "#ffba93"
        property color term7: "#edd2d5"
        property color term8: "#b29ea1"
        property color term9: "#ff7db7"
        property color term10: "#ffd2d5"
        property color term11: "#fff1f2"
        property color term12: "#babfdd"
        property color term13: "#f3a9cd"
        property color term14: "#ffd1c0"
        property color term15: "#ffffff"

        property color archBlue: "#1793D1"
        property color success: "#4CAF50"
        property color warning: "#FF9800"
        property color info: "#2196F3"
        property color error: "#F2B8B5"

        property color rosewater: "#B8C4FF"
        property color flamingo: "#DBB9F8"
        property color pink: "#F3B3E3"
        property color mauve: "#D0BDFE"
        property color red: "#F8B3D1"
        property color maroon: "#F6B2DA"
        property color peach: "#E4B7F4"
        property color yellow: "#C3C0FF"
        property color green: "#ADC6FF"
        property color teal: "#D4BBFC"
        property color sky: "#CBBEFF"
        property color sapphire: "#BDC2FF"
        property color blue: "#C7BFFF"
        property color lavender: "#EAB5ED"
    }
}
