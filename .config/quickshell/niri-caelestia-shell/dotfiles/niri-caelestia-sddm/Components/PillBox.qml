// PillBox.qml — reusable translucent pill container for bar items

import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property color colSurface
    property color colOutline
    property int   animDuration: 300

    implicitHeight: 36
    implicitWidth:  rowLayout.implicitWidth + 28

    radius: height / 2
    color: Qt.rgba(colSurface.r, colSurface.g, colSurface.b, 0.72)
    border {
        color: Qt.rgba(colOutline.r, colOutline.g, colOutline.b, 0.25)
        width: 1
    }

    // Public layout — callers add children to this
    property alias rowLayout: innerRow

    RowLayout {
        id: innerRow
        anchors {
            fill: parent
            leftMargin:  14
            rightMargin: 14
        }
        spacing: 8
    }

    Behavior on color        { ColorAnimation { duration: animDuration / 2 } }
    Behavior on border.color { ColorAnimation { duration: animDuration / 2 } }
}
