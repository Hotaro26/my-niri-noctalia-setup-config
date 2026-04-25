pragma ComponentBehavior: Bound

import ".."
import "../components"
import qs.components
import qs.components.controls
import qs.components.effects
import qs.components.containers
import qs.services
import qs.config
import qs.utils
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property Session session

    // General Settings
    property bool enabled: Config.dashboard.enabled ?? true
    property bool showOnHover: Config.dashboard.showOnHover ?? true
    property int updateInterval: Config.dashboard.updateInterval ?? 1000
    property int dragThreshold: Config.dashboard.dragThreshold ?? 50
    
    // Weather
    property string weatherLocation: Config.services.weatherLocation ?? ""
    property bool useFahrenheit: Config.services.useFahrenheit ?? false

    // Avatar
    property bool useWallpaperAvatar: Config.dashboard.useWallpaperAvatar ?? true

    // Performance Resources
    property bool showBattery: Config.dashboard.performance.showBattery ?? false
    property bool showGpu: Config.dashboard.performance.showGpu ?? true
    property bool showCpu: Config.dashboard.performance.showCpu ?? true
    property bool showMemory: Config.dashboard.performance.showMemory ?? true
    property bool showStorage: Config.dashboard.performance.showStorage ?? true 
    property bool showNetwork: Config.dashboard.performance.showNetwork ?? true

    anchors.fill: parent

    function saveConfig() {
        Config.dashboard.enabled = root.enabled;
        Config.dashboard.showOnHover = root.showOnHover;
        Config.dashboard.updateInterval = root.updateInterval;
        Config.dashboard.dragThreshold = root.dragThreshold;
        Config.services.weatherLocation = root.weatherLocation;
        Config.services.useFahrenheit = root.useFahrenheit;
        Config.dashboard.useWallpaperAvatar = root.useWallpaperAvatar;
        Config.dashboard.performance.showBattery = root.showBattery;
        Config.dashboard.performance.showGpu = root.showGpu;
        Config.dashboard.performance.showCpu = root.showCpu;
        Config.dashboard.performance.showMemory = root.showMemory;
        Config.dashboard.performance.showStorage = root.showStorage;
        Config.dashboard.performance.showNetwork = root.showNetwork;
        // Note: sizes properties are readonly and cannot be modified
        Config.markDirty("dashboard");
    }

    ClippingRectangle {
        id: dashboardClippingRect
        anchors.fill: parent
        anchors.margins: Appearance.padding.md
        anchors.leftMargin: 0
        anchors.rightMargin: Appearance.padding.md

        radius: dashboardBorder.innerRadius
        color: "transparent"

        Loader {
            id: dashboardLoader

            anchors.fill: parent
            anchors.margins: Appearance.padding.xl + Appearance.padding.md
            anchors.leftMargin: Appearance.padding.xl
            anchors.rightMargin: Appearance.padding.xl

            sourceComponent: dashboardContentComponent
        }
    }

    InnerBorder {
        id: dashboardBorder
        leftThickness: 0
        rightThickness: Appearance.padding.md
    }

    Component {
        id: dashboardContentComponent

        StyledFlickable {
            id: dashboardFlickable
            flickableDirection: Flickable.VerticalFlick
            contentHeight: dashboardLayout.height

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: dashboardFlickable
            }

            ColumnLayout {
                id: dashboardLayout
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top

                spacing: Appearance.spacing.lg

                RowLayout {
                    spacing: Appearance.spacing.md

                    StyledText {
                        text: qsTr("Dashboard")
                        font.pointSize: Appearance.font.size.titleMedium
                        font.weight: 500
                    }
                }

                // General Settings Section
                GeneralSection {
                    rootItem: root
                }

                // Weather Section
                WeatherSection {
                    rootItem: root
                }

                // Performance Resources Section
                PerformanceSection {
                    rootItem: root
                }
            }
        }
    }
}
