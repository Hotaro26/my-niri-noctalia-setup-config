import Quickshell.Io
import QtQuick

JsonObject {
    property string weatherLocation: "" // A lat,long pair or city name or empty for autodetection, e.g. "37.8267,-122.4233" or "Mohali"
    property bool useFahrenheit: [Locale.ImperialUSSystem, Locale.ImperialSystem].includes(Qt.locale().measurementSystem)
    property bool useTwelveHourClock: Qt.locale().timeFormat(Locale.ShortFormat).toLowerCase().includes("a")
    property string gpuType: ""
    property int visualiserBars: 24
    property real audioIncrement: 0.1
    property bool smartScheme: true
    property string defaultPlayer: "Spotify"
    property list<var> playerAliases: [
        {
            "from": "com.github.th_ch.youtube_music",
            "to": "YT Music"
        }
    ]
    
    // Toast notifications configuration
    property Toasts toasts: Toasts {}

    property SunsetService sunsetService: SunsetService {}

    component SunsetService: JsonObject {
        property bool manualEnabled: false
        property int temperature: 4500
        property string preferredBackend: ""
    }
    
    component Toasts: JsonObject {
        property bool configLoaded: true      // Show notification when config is reloaded
        property bool configError: true       // Show notification on config errors
    }
}
