// Settings.qml — user configuration for Caelestia SDDM
import QtQuick

QtObject {
    readonly property string wallpaperPath:   ""
    readonly property bool   blurWallpaper:   true
    readonly property int    blurRadius:      64
    readonly property real   dimOpacity:      0.20

    readonly property string clockFontFamily: "Rubik"
    readonly property string uiFontFamily:    "Rubik"
    readonly property string monoFontFamily:  "JetBrains Mono Nerd Font"

    readonly property bool   showAvatars:     true
    readonly property int    animDuration:    300
}
