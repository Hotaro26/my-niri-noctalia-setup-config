// PowerButton.qml

import QtQuick
import QtQuick.Controls

Item {
    id: root
    property string icon:             ""
    property string tooltip:          ""
    property bool   isDestructive:    false
    property color  colTextSecondary: "#c8c5d0"
    property color  colPrimary:       "#cbbdff"
    property string fontName:         "Material Symbols Rounded"

    signal clicked()

    implicitWidth: 36; implicitHeight: 36

    ToolTip.visible: ma.containsMouse
    ToolTip.text:    root.tooltip
    ToolTip.delay:   500

    Rectangle {
        anchors.centerIn: parent
        width: 30; height: 30; radius: 15
        color: ma.pressed        ? Qt.rgba(root.colPrimary.r, root.colPrimary.g, root.colPrimary.b, 0.28)
             : ma.containsMouse  ? Qt.rgba(root.colPrimary.r, root.colPrimary.g, root.colPrimary.b, 0.16)
             : "transparent"
        Behavior on color { ColorAnimation { duration: 100 } }

        Text {
            anchors.centerIn: parent
            text:  root.icon
            font { family: root.fontName; pixelSize: 18 }
            color: ma.containsMouse ? root.colPrimary : root.colTextSecondary
            Behavior on color { ColorAnimation { duration: 120 } }
        }
    }

    MouseArea {
        id: ma; anchors.fill: parent
        hoverEnabled: true; cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
