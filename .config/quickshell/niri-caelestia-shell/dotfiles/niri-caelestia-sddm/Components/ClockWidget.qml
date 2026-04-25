// ClockWidget.qml — large Rubik clock matching Caelestia lockscreen

import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property color  colTextPrimary:   "#e4e1ec"
    property color  colTextSecondary: "#c8c5d0"
    property string clockFontFamily:  "Rubik"
    property string uiFontFamily:     "Rubik"

    implicitWidth:  col.implicitWidth
    implicitHeight: col.implicitHeight

    Timer {
        interval: 1000; repeat: true; running: true; triggeredOnStart: true
        onTriggered: {
            var now  = new Date()
            timeText.text = Qt.formatTime(now, "hh:mm")
            secsText.text = Qt.formatTime(now, "ss")
            dateText.text = Qt.formatDate(now, "dddd, MMMM d")
        }
    }

    ColumnLayout {
        id: col
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 8

        // ── Time row ──────────────────────────────────────────────────────
        // Use a plain Row — both texts share the same baseline naturally
        // because they sit in the same Row with verticalAlignment
        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: 2

            Text {
                id: timeText
                font { family: root.clockFontFamily; pixelSize: 96; weight: Font.Light; letterSpacing: -2 }
                color: root.colTextPrimary
                verticalAlignment: Text.AlignBottom
            }

            // Seconds — smaller, bottom-aligned inside the row
            Text {
                id: secsText
                font { family: root.clockFontFamily; pixelSize: 32; weight: Font.Light }
                color: Qt.rgba(root.colTextSecondary.r, root.colTextSecondary.g, root.colTextSecondary.b, 0.60)
                // align to bottom of time text
                anchors.bottom: timeText.bottom
                anchors.bottomMargin: 10
            }
        }

        // ── Date ──────────────────────────────────────────────────────────
        Text {
            id: dateText
            Layout.alignment: Qt.AlignHCenter
            font { family: root.uiFontFamily; pixelSize: 17; letterSpacing: 1.0 }
            color: Qt.rgba(root.colTextSecondary.r, root.colTextSecondary.g, root.colTextSecondary.b, 0.80)
        }
    }
}
