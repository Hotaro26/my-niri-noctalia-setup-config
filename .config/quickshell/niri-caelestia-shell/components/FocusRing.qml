import qs.services
import qs.config
import QtQuick

Rectangle {
    id: root

    property Item target: parent
    property real offset: 2

    anchors.fill: target
    anchors.margins: -offset

    radius: (target?.radius ?? 0) + offset
    color: "transparent"
    border.width: 2
    border.color: Colours.palette.m3primary
    visible: target?.activeFocus ?? false
    opacity: visible ? 1 : 0

    Behavior on opacity {
        Anim {}
    }
}
