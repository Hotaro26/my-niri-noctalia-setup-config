// BottomBar.qml — session | keyboard | power pills

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SddmComponents

Item {
    id: root

    property color  colSurface:       "#131218"
    property color  colTextPrimary:   "#e4e1ec"
    property color  colTextSecondary: "#c8c5d0"
    property color  colPrimary:       "#cbbdff"
    property color  colOutline:       "#928f9a"
    property color  colError:         "#ffb4ab"
    property string uiFontFamily:     "Rubik"
    property int    animDuration:     280

    implicitWidth:  parent.width
    implicitHeight: 44

    // ── shared pill style ─────────────────────────────────────────────────
    component Pill: Rectangle {
        height: 36
        radius: 18
        color:  Qt.rgba(root.colSurface.r, root.colSurface.g, root.colSurface.b, 0.72)
        border { color: Qt.rgba(root.colOutline.r, root.colOutline.g, root.colOutline.b, 0.28); width: 1 }
    }

    // ── Session ───────────────────────────────────────────────────────────
    Pill {
        anchors { left: parent.left; leftMargin: 32; verticalCenter: parent.verticalCenter }
        width: sessionRow.implicitWidth + 28

        RowLayout {
            id: sessionRow
            anchors { fill: parent; leftMargin: 14; rightMargin: 14 }
            spacing: 8

            ComboBox {
                id:           sessionCombo
                model:        sessionModel
                currentIndex: sessionModel.lastIndex
                textRole:     "name"
                implicitWidth: 148; implicitHeight: 32
                font { family: root.uiFontFamily; pixelSize: 13 }

                contentItem: Text {
                    leftPadding: 2; text: sessionCombo.displayText; font: sessionCombo.font
                    color: root.colTextPrimary; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight
                }
                background: Item {}

                delegate: ItemDelegate {
                    width: sessionCombo.width
                    contentItem: Text { text: model.name; font: sessionCombo.font; color: root.colTextPrimary; verticalAlignment: Text.AlignVCenter }
                    background: Rectangle {
                        color: hovered ? Qt.rgba(root.colPrimary.r, root.colPrimary.g, root.colPrimary.b, 0.15) : "transparent"
                        radius: 6
                    }
                }
                popup: Popup {
                    y: -height - 4; width: sessionCombo.width + 40; padding: 6
                    contentItem: ListView { implicitHeight: contentHeight; model: sessionCombo.delegateModel; clip: true }
                    background: Rectangle {
                        color: Qt.rgba(root.colSurface.r, root.colSurface.g, root.colSurface.b, 0.96)
                        radius: 12; border { color: Qt.rgba(root.colOutline.r, root.colOutline.g, root.colOutline.b, 0.3); width: 1 }
                    }
                }
                onCurrentIndexChanged: sessionModel.lastIndex = currentIndex
            }
        }
    }

    // ── Keyboard layout removed ──


    // ── Power ─────────────────────────────────────────────────────────────
    Pill {
        anchors { right: parent.right; rightMargin: 32; verticalCenter: parent.verticalCenter }
        width: powerRow.implicitWidth + 20

        RowLayout {
            id: powerRow
            anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
            spacing: 2

            PowerButton { icon: "\uef44"; tooltip: "Suspend";  colTextSecondary: root.colTextSecondary; colPrimary: root.colPrimary; onClicked: sddm.suspend() }
            PowerButton { icon: "\uf053"; tooltip: "Reboot";   colTextSecondary: root.colTextSecondary; colPrimary: root.colPrimary; onClicked: sddm.reboot() }
            PowerButton { icon: "\ue8ac"; tooltip: "Power Off"; colTextSecondary: root.colTextSecondary; colPrimary: root.colError;   isDestructive: true; onClicked: sddm.powerOff() }
        }
    }

    // Entry
    opacity: 0
    transform: Translate { id: barTranslate; y: 8 }
    Component.onCompleted: barEntryAnim.start()
    ParallelAnimation {
        id: barEntryAnim
        NumberAnimation { target: root;         property: "opacity"; from: 0;  to: 1;  duration: root.animDuration * 2; easing.type: Easing.OutCubic }
        NumberAnimation { target: barTranslate; property: "y";       from: 8;  to: 0;  duration: root.animDuration * 2; easing.type: Easing.OutCubic }
    }
}
