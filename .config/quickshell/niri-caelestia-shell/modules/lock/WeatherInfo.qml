pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import qs.utils
import QtQuick
import QtQuick.Layouts

// Weather widget — top slot of the left lock panel.
// Horizontal inset: padding.xl on each side, matching Media.qml / Resources.qml.
ColumnLayout {
    id: root

    required property int rootHeight

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: Appearance.padding.xl
    anchors.rightMargin: Appearance.padding.xl

    spacing: 0

    // ── Section label + current temp ───────────────────────────────────────────
    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: Appearance.padding.xl
        Layout.bottomMargin: Appearance.padding.xl
        spacing: Appearance.spacing.xs

        MaterialIcon {
            text: "partly_cloudy_day"
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.labelLarge
        }

        StyledText {
            text: qsTr("Weather")
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.labelLarge
            font.weight: Font.Medium
            font.family: Appearance.font.family.mono
        }

        Item { Layout.fillWidth: true }

        // Temperature is the primary data — larger and accented
        StyledText {
            animate: true
            text: Weather.temp
            color: Colours.palette.m3primary
            font.pointSize: Appearance.font.size.bodyLarge
            font.weight: Font.Bold
        }
    }

    // ── Current conditions row ─────────────────────────────────────────────────
    RowLayout {
        Layout.fillWidth: true
        Layout.bottomMargin: Appearance.padding.xl
        spacing: Appearance.spacing.sm

        MaterialIcon {
            text: Weather.icon || "cloud"
            color: Colours.palette.m3secondary
            font.pointSize: Appearance.font.size.bodyMedium
        }

        StyledText {
            Layout.fillWidth: true
            text: Weather.description
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.bodySmall
            font.family: Appearance.font.family.mono
            elide: Text.ElideRight
        }

        MaterialIcon {
            text: "water_drop"
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.labelMedium
            visible: Weather.humidity > 0
        }

        StyledText {
            text: Weather.humidity ? `${Weather.humidity}% humidity` : ""
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.bodySmall
            font.family: Appearance.font.family.mono
        }
    }

    // ── Hourly forecast ────────────────────────────────────────────────────────
    Loader {
        Layout.fillWidth: true
        Layout.bottomMargin: Appearance.padding.xl

        asynchronous: true
        active: (Weather.forecast?.length ?? 0) > 0
        visible: active

        sourceComponent: Item {
            implicitHeight: forecastRow.implicitHeight

            RowLayout {
                id: forecastRow
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Appearance.spacing.lg

                Repeater {
                    model: Weather.forecast.slice(0, 6)

                    ColumnLayout {
                        required property var modelData
                        spacing: Appearance.spacing.sm

                        MaterialIcon {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.icon || "cloud"
                            color: Colours.palette.m3onSurfaceVariant
                            font.pointSize: Appearance.font.size.bodyMedium
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: Config.services.useFahrenheit
                                ? `${modelData.maxTempF}°`
                                : `${modelData.maxTempC}°`
                            color: Colours.palette.m3onSurface
                            font.pointSize: Appearance.font.size.bodySmall
                            font.family: Appearance.font.family.mono
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: Qt.formatDate(new Date(modelData.date), "ddd")
                            color: Colours.palette.m3onSurfaceVariant
                            font.pointSize: Appearance.font.size.labelMedium
                            font.family: Appearance.font.family.mono
                        }
                    }
                }
            }
        }
    }

    Timer {
        running: true
        triggeredOnStart: true
        repeat: true
        interval: 900000
        onTriggered: Weather.reload()
    }
}
