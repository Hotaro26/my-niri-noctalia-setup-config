import qs.config
import qs.services
import QtQuick

ColorAnimation {
    duration: Colours.transitioning ? 150 : Appearance.anim.durations.normal
    easing.type: Easing.BezierSpline
    easing.bezierCurve: Appearance.anim.curves.standard
}
