import qs.config
import QtQuick
import QtQuick.Layouts
import "cards"

Item {
    id: root

    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    width: 300 // Standard utility width

    ColumnLayout {
        anchors.fill: parent
        spacing: Appearance.spacing.normal

        BlueLightFilter {}

        Item {
            Layout.fillHeight: true
        }
    }

    Behavior on implicitHeight {
        Anim {}
    }

    component Anim: NumberAnimation {
        duration: Appearance.anim.durations.expressiveDefaultSpatial
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
    }
}
