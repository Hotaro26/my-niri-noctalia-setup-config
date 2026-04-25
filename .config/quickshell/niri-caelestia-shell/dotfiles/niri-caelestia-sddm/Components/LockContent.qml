// LockContent.qml — clock → avatar → username → password pill
// Qt6 compatible, no QtGraphicalEffects.

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SddmComponents

Item {
    id: root

    // Colors (all safe non-"on" names)
    property color colSurface:       "#131218"
    property color colSurfaceVariant:"#46464f"
    property color colTextPrimary:   "#e4e1ec"
    property color colTextSecondary: "#c8c5d0"
    property color colPrimary:       "#cbbdff"
    property color colPrimaryText:   "#2b0082"
    property color colOutline:       "#928f9a"
    property color colError:         "#ffb4ab"

    property string clockFontFamily: "Rubik"
    property string uiFontFamily:    "Rubik"
    property string monoFontFamily:  "JetBrains Mono Nerd Font"
    property bool   showAvatars:     true
    property int    animDuration:    280
    property bool   authFailed:      false

    implicitWidth:  contentCol.implicitWidth
    implicitHeight: contentCol.implicitHeight

    Connections {
        target: sddm
        function onLoginFailed() {
            root.authFailed = true
            shakeAnim.start()
            passwordField.clear()
            passwordField.forceActiveFocus()
            failTimer.restart()
        }
        function onLoginSucceeded() { root.authFailed = false }
    }

    Timer {
        id: failTimer; interval: 2500
        onTriggered: root.authFailed = false
    }

    SequentialAnimation {
        id: shakeAnim
        NumberAnimation { target: pillContainer; property: "x"; to:  10; duration: 45 }
        NumberAnimation { target: pillContainer; property: "x"; to: -10; duration: 45 }
        NumberAnimation { target: pillContainer; property: "x"; to:   7; duration: 45 }
        NumberAnimation { target: pillContainer; property: "x"; to:  -7; duration: 45 }
        NumberAnimation { target: pillContainer; property: "x"; to:   3; duration: 45 }
        NumberAnimation { target: pillContainer; property: "x"; to:   0; duration: 45 }
    }

    ColumnLayout {
        id: contentCol
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 0

        // ── Clock ──────────────────────────────────────────────────────────
        ClockWidget {
            Layout.alignment:    Qt.AlignHCenter
            Layout.bottomMargin: 44
            colTextPrimary:   root.colTextPrimary
            colTextSecondary: root.colTextSecondary
            clockFontFamily:  root.clockFontFamily
            uiFontFamily:     root.uiFontFamily
        }

        // ── Avatar ─────────────────────────────────────────────────────────
        AvatarWidget {
            Layout.alignment:    Qt.AlignHCenter
            Layout.bottomMargin: 20
            visible:      root.showAvatars
            colSurface:   root.colSurface
            colPrimary:   root.colPrimary
            colTextPrimary: root.colTextPrimary
            animDuration: root.animDuration
        }

        // ── Username ───────────────────────────────────────────────────────
        Text {
            Layout.alignment:    Qt.AlignHCenter
            Layout.bottomMargin: 22
            text:  (typeof userModel !== "undefined" && userModel.lastUser !== "")
                        ? userModel.lastUser : "user"
            color: root.colTextPrimary
            font { family: root.uiFontFamily; pixelSize: 22; weight: Font.Medium; letterSpacing: 0.5 }
        }

        // ── Password pill ──────────────────────────────────────────────────
        Item {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth:  pillContainer.width
            implicitHeight: pillContainer.height

            // Focus glow ring (pure Rectangle, no GraphicalEffects)
            Rectangle {
                anchors.fill:    pillContainer
                anchors.margins: -5
                radius:          pillContainer.radius + 5
                color:           "transparent"
                border.width:    5
                border.color:    Qt.rgba(root.colPrimary.r, root.colPrimary.g, root.colPrimary.b,
                                         passwordField.activeFocus ? 0.30 : 0.0)
                Behavior on border.color { ColorAnimation { duration: root.animDuration } }
            }

            Rectangle {
                id:      pillContainer
                width:   320
                height:  52
                radius:  26

                color: root.authFailed
                    ? Qt.rgba(root.colError.r, root.colError.g, root.colError.b, 0.14)
                    : passwordField.activeFocus
                        ? Qt.rgba(root.colSurface.r, root.colSurface.g, root.colSurface.b, 0.90)
                        : Qt.rgba(root.colSurface.r, root.colSurface.g, root.colSurface.b, 0.68)

                border.color: root.authFailed
                    ? Qt.rgba(root.colError.r, root.colError.g, root.colError.b, 0.80)
                    : passwordField.activeFocus
                        ? Qt.rgba(root.colPrimary.r, root.colPrimary.g, root.colPrimary.b, 0.85)
                        : Qt.rgba(root.colOutline.r, root.colOutline.g, root.colOutline.b, 0.35)
                border.width: 1.5

                Behavior on color        { ColorAnimation { duration: root.animDuration / 2 } }
                Behavior on border.color { ColorAnimation { duration: root.animDuration / 2 } }

                RowLayout {
                    anchors { fill: parent; leftMargin: 18; rightMargin: 8 }
                    spacing: 8

                    // Icon (uses text fallback if Material Symbols not installed)
                    Text {
                        text:  root.authFailed ? "\ue000" : "\ue897"
                        font { family: "Material Symbols Rounded"; pixelSize: 20 }
                        color: root.authFailed ? root.colError
                             : passwordField.activeFocus ? root.colPrimary
                             : root.colTextSecondary
                        Behavior on color { ColorAnimation { duration: root.animDuration / 2 } }
                    }

                    TextField {
                        id: passwordField
                        Layout.fillWidth: true
                        echoMode:          TextInput.Password
                        passwordCharacter: "●"
                        placeholderText:   root.authFailed ? "Try again…" : "Password"
                        font { family: root.uiFontFamily; pixelSize: 15 }
                        color:                root.authFailed ? root.colError : root.colTextPrimary
                        placeholderTextColor: root.authFailed
                            ? Qt.rgba(root.colError.r,   root.colError.g,   root.colError.b,   0.55)
                            : Qt.rgba(root.colTextSecondary.r, root.colTextSecondary.g, root.colTextSecondary.b, 0.65)
                        selectionColor: Qt.rgba(root.colPrimary.r, root.colPrimary.g, root.colPrimary.b, 0.4)
                        background: Item {}
                        Keys.onReturnPressed: doLogin()
                        Keys.onEnterPressed:  doLogin()
                        Component.onCompleted: forceActiveFocus()
                        Behavior on color { ColorAnimation { duration: root.animDuration / 2 } }
                    }

                    // Unlock button
                    Rectangle {
                        width: 36; height: 36; radius: 18
                        color: unlockMouse.pressed       ? Qt.darker(root.colPrimary, 1.3)
                             : unlockMouse.containsMouse ? root.colPrimary
                             : Qt.rgba(root.colPrimary.r, root.colPrimary.g, root.colPrimary.b, 0.85)
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text {
                            anchors.centerIn: parent
                            text:  "\ue5c8"
                            font { family: "Material Symbols Rounded"; pixelSize: 22; weight: Font.Bold }
                            color: root.colPrimaryText
                        }

                        MouseArea {
                            id: unlockMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    doLogin()
                        }
                    }
                }
            }
        }

        // Error text
        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 10
            text:    "Wrong password"
            color:   root.colError
            font { family: root.uiFontFamily; pixelSize: 13 }
            opacity: root.authFailed ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: root.animDuration; easing.type: Easing.OutCubic } }
        }
    }

    function doLogin() {
        if (passwordField.text.length === 0) return
        var u = (typeof userModel !== "undefined" && userModel.lastUser !== "")
            ? userModel.lastUser : "user"
        sddm.login(u, passwordField.text, sessionModel.lastIndex)
    }
}
