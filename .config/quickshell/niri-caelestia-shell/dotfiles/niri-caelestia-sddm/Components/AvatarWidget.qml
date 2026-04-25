// AvatarWidget.qml — circular avatar with primary ring

import QtQuick

Item {
    id: root
    property color colSurface:      "#131218"
    property color colPrimary:      "#cbbdff"
    property color colTextPrimary:  "#e4e1ec"
    property int   animDuration:    280

    implicitWidth:  84
    implicitHeight: 84

    // Outer glow ring
    Rectangle {
        anchors.centerIn: parent
        width: 94; height: 94; radius: 47
        color: "transparent"
        border { color: Qt.rgba(root.colPrimary.r, root.colPrimary.g, root.colPrimary.b, 0.18); width: 5 }
    }

    // Primary ring
    Rectangle {
        anchors.centerIn: parent
        width: 84; height: 84; radius: 42
        color: "transparent"
        border { color: Qt.rgba(root.colPrimary.r, root.colPrimary.g, root.colPrimary.b, 0.70); width: 2 }
    }

    // Avatar circle
    Rectangle {
        id: avatarCircle
        anchors.centerIn: parent
        width: 76; height: 76; radius: 38
        color: Qt.rgba(root.colSurface.r, root.colSurface.g, root.colSurface.b, 0.85)
        clip: true

        Image {
            id: avatarImg
            anchors.fill: parent
            source: {
                if (typeof userModel === "undefined") return ""
                var u = userModel.lastUser
                return (u && u !== "") ? ("file:///var/lib/AccountsService/icons/" + u) : ""
            }
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            visible: status === Image.Ready
        }

        // Fallback person icon
        Text {
            anchors.centerIn: parent
            visible: avatarImg.status !== Image.Ready
            text:  "\ue7fd"
            font { family: "Material Symbols Rounded"; pixelSize: 32 }
            color: Qt.rgba(root.colTextPrimary.r, root.colTextPrimary.g, root.colTextPrimary.b, 0.55)
        }
    }

    opacity: 0.0
    scale:   0.88
    Component.onCompleted: entryAnim.start()
    ParallelAnimation {
        id: entryAnim
        NumberAnimation { target: root; property: "opacity"; from: 0.0;  to: 1.0; duration: root.animDuration;        easing.type: Easing.OutCubic }
        NumberAnimation { target: root; property: "scale";   from: 0.88; to: 1.0; duration: root.animDuration * 1.4;  easing.type: Easing.OutBack  }
    }
}
