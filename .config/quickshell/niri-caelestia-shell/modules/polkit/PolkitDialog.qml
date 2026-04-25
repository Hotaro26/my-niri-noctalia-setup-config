pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.components.effects
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland

/**
 * PolkitDialog — authentication prompt overlay for niri-caelestia-shell.
 *
 * Shown as a full-screen layer-shell surface on the Overlay layer whenever
 * PolkitService.active is true.  The card design mirrors the lock screen's
 * Material Design 3 aesthetic.
 */
Variants {
    id: root
    model: Quickshell.screens

    PanelWindow {
        id: win
        required property var modelData

        screen: modelData

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "caelestia-polkit"
        WlrLayershell.keyboardFocus: PolkitService.active ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        WlrLayershell.exclusionMode: ExclusionMode.Ignore

        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true

        color: "transparent"

        // ── Visible only when a polkit request is in flight ───────────────────
        visible: PolkitService.active

        // ── Backdrop scrim ────────────────────────────────────────────────────
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.55)
            opacity: win.visible ? 1 : 0

            Behavior on opacity {
                Anim { duration: Appearance.anim.durations.normal }
            }
        }

        // ── Centred dialog card ───────────────────────────────────────────────
        Item {
            anchors.centerIn: parent
            implicitWidth: card.implicitWidth
            implicitHeight: card.implicitHeight
            width: implicitWidth
            height: implicitHeight

            // Animate card entry
            opacity: win.visible ? 1 : 0
            scale: win.visible ? 1 : 0.92

            Behavior on opacity {
                Anim { duration: Appearance.anim.durations.normal }
            }
            Behavior on scale {
                Anim {
                    duration: Appearance.anim.durations.expressiveDefaultSpatial
                    easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
                }
            }

            StyledRect {
                id: card

                // Width governed by notification panel width × 1.6 for readability
                implicitWidth: Math.min(480, win.screen?.width ?? 480)
                implicitHeight: cardLayout.implicitHeight + Appearance.padding.xl * 2

                radius: Appearance.rounding.large
                color: Colours.tPalette.m3surfaceContainer

                // ── Keyboard handling ──────────────────────────────────────
                focus: win.visible
                Keys.onReturnPressed: dialogContent.trySubmit()
                Keys.onEnterPressed:  dialogContent.trySubmit()
                Keys.onEscapePressed: PolkitService.cancel()

                // ── Card content layout ────────────────────────────────────
                ColumnLayout {
                    id: cardLayout

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: Appearance.padding.xl

                    spacing: Appearance.spacing.md

                    // Header — icon + title
                    RowLayout {
                        spacing: Appearance.spacing.md

                        StyledRect {
                            implicitWidth: headerIcon.font.pointSize + Appearance.padding.md * 2
                            implicitHeight: implicitWidth
                            radius: Appearance.rounding.full
                            color: Colours.palette.m3secondaryContainer

                            MaterialIcon {
                                id: headerIcon
                                anchors.centerIn: parent
                                text: "admin_panel_settings"
                                color: Colours.palette.m3onSecondaryContainer
                                font.pointSize: Appearance.font.size.titleMedium
                            }
                        }

                        ColumnLayout {
                            spacing: 2

                            StyledText {
                                text: qsTr("Authentication Required")
                                font.pointSize: Appearance.font.size.titleMedium
                                font.weight: Font.DemiBold
                                color: Colours.palette.m3onSurface
                            }

                            StyledText {
                                visible: PolkitService.subjectName.length > 0
                                text: PolkitService.subjectName
                                font.pointSize: Appearance.font.size.labelLarge
                                color: Colours.palette.m3onSurfaceVariant
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                    }

                    // Polkit message
                    Loader {
                        active: PolkitService.cleanMessage.length > 0
                        visible: active
                        Layout.fillWidth: true

                        sourceComponent: StyledRect {
                            implicitHeight: msgText.implicitHeight + Appearance.padding.sm * 2
                            radius: Appearance.rounding.small
                            color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 1)

                            StyledText {
                                id: msgText
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.margins: Appearance.padding.sm

                                text: PolkitService.cleanMessage
                                font.pointSize: Appearance.font.size.bodySmall
                                color: Colours.palette.m3onSurfaceVariant
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            }
                        }
                    }

                    // ── Input row ──────────────────────────────────────────
                    Item {
                        id: dialogContent

                        Layout.fillWidth: true
                        implicitHeight: inputBar.implicitHeight

                        // Helper called by Enter key or Authenticate button
                        function trySubmit(): void {
                            if (PolkitService.interactionAvailable && inputField.text.length > 0)
                                PolkitService.submit(inputField.text);
                        }

                        StyledRect {
                            id: inputBar
                            anchors.left: parent.left
                            anchors.right: parent.right
                            implicitHeight: inputRow.implicitHeight + Appearance.padding.sm * 2

                            color: Qt.alpha(Colours.palette.m3surfaceContainerHigh, 0.75)
                            radius: Appearance.rounding.full
                            border.width: inputField.hasFocus ? 2 : 0
                            border.color: PolkitService.submitting
                                ? Colours.palette.m3secondary
                                : Colours.palette.m3primary

                            CAnim { properties: "color,border.width,border.color" }

                            RowLayout {
                                id: inputRow

                                anchors.fill: parent
                                anchors.margins: Appearance.padding.sm
                                spacing: Appearance.spacing.md

                                // State icon / busy indicator
                                Item {
                                    implicitWidth: implicitHeight
                                    implicitHeight: stateIcon.implicitHeight + Appearance.padding.xs * 2

                                    MaterialIcon {
                                        id: stateIcon
                                        anchors.centerIn: parent
                                        animate: true
                                        text: PolkitService.submitting ? "hourglass_top" : "lock"
                                        color: PolkitService.submitting
                                            ? Colours.palette.m3secondary
                                            : Colours.palette.m3onSurfaceVariant
                                        font.pointSize: Appearance.font.size.bodyMedium
                                        opacity: PolkitService.submitting ? 0 : 1
                                        Behavior on opacity { Anim {} }
                                    }

                                    StyledBusyIndicator {
                                        anchors.fill: parent
                                        running: PolkitService.submitting
                                    }
                                }

                                // Password / visible input
                                StyledTextField {
                                    id: inputField

                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    placeholderText: PolkitService.cleanPrompt
                                    echoMode: PolkitService.responseVisible
                                        ? TextInput.Normal
                                        : TextInput.Password
                                    enabled: PolkitService.interactionAvailable && !PolkitService.submitting
                                    font.pointSize: Appearance.font.size.bodySmall

                                    Keys.onReturnPressed: dialogContent.trySubmit()
                                    Keys.onEnterPressed:  dialogContent.trySubmit()
                                    Keys.onEscapePressed: PolkitService.cancel()

                                    // Clear field on each new authentication flow
                                    Connections {
                                        target: PolkitService
                                        function onActiveChanged(): void {
                                            inputField.text = "";
                                            if (PolkitService.active)
                                                inputField.forceActiveFocus();
                                        }
                                        function onInteractionAvailableChanged(): void {
                                            if (PolkitService.interactionAvailable) {
                                                inputField.text = "";
                                                inputField.forceActiveFocus();
                                            }
                                        }
                                    }
                                }

                                // Submit arrow button
                                StyledRect {
                                    implicitWidth: implicitHeight
                                    implicitHeight: submitIcon.implicitHeight + Appearance.padding.sm * 2

                                    color: inputField.text.length > 0 && PolkitService.interactionAvailable
                                        ? Colours.palette.m3primary
                                        : Qt.alpha(Colours.palette.m3surfaceContainerHigh, 0.8)
                                    radius: Appearance.rounding.full

                                    CAnim { properties: "color" }

                                    StateLayer {
                                        color: inputField.text.length > 0 && PolkitService.interactionAvailable
                                            ? Colours.palette.m3onPrimary
                                            : Colours.palette.m3onSurface
                                        radius: Appearance.rounding.full

                                        function onClicked(): void {
                                            dialogContent.trySubmit();
                                        }
                                    }

                                    MaterialIcon {
                                        id: submitIcon
                                        anchors.centerIn: parent
                                        text: "arrow_forward"
                                        color: inputField.text.length > 0 && PolkitService.interactionAvailable
                                            ? Colours.palette.m3onPrimary
                                            : Colours.palette.m3onSurface
                                        font.pointSize: Appearance.font.size.bodyMedium
                                        font.weight: 500

                                        CAnim { properties: "color" }
                                    }
                                }
                            }
                        }
                    }

                    // ── Error / retry message ──────────────────────────────
                    Item {
                        Layout.fillWidth: true
                        implicitHeight: errorText.implicitHeight

                        StyledText {
                            id: errorText
                            anchors.left: parent.left
                            anchors.right: parent.right

                            visible: PolkitService.failedAttempts > 0 && PolkitService.active
                            opacity: PolkitService.failedAttempts > 0 && PolkitService.active ? 1 : 0
                            text: qsTr("Incorrect password. Please try again.")
                            color: Colours.palette.m3error
                            font.pointSize: Appearance.font.size.labelLarge
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                            Behavior on opacity { Anim {} }
                        }
                    }

                    // ── Action buttons ─────────────────────────────────────
                    RowLayout {
                        Layout.alignment: Qt.AlignRight
                        spacing: Appearance.spacing.md

                        // Cancel button
                        StyledRect {
                            implicitWidth: cancelText.implicitWidth + Appearance.padding.lg * 2
                            implicitHeight: cancelText.implicitHeight + Appearance.padding.sm * 2

                            radius: Appearance.rounding.full
                            color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 1)

                            StateLayer {
                                radius: Appearance.rounding.full
                                color: Colours.palette.m3onSurface

                                function onClicked(): void {
                                    PolkitService.cancel();
                                }
                            }

                            StyledText {
                                id: cancelText
                                anchors.centerIn: parent
                                text: qsTr("Cancel")
                                color: Colours.palette.m3onSurfaceVariant
                                font.pointSize: Appearance.font.size.labelLarge
                                font.weight: Font.Medium
                            }
                        }

                        // Authenticate button
                        StyledRect {
                            implicitWidth: authenticateText.implicitWidth + Appearance.padding.lg * 2
                            implicitHeight: authenticateText.implicitHeight + Appearance.padding.sm * 2

                            radius: Appearance.rounding.full
                            color: inputField.text.length > 0 && PolkitService.interactionAvailable
                                ? Colours.palette.m3primary
                                : Qt.alpha(Colours.palette.m3primary, 0.4)

                            CAnim { properties: "color" }

                            StateLayer {
                                radius: Appearance.rounding.full
                                color: Colours.palette.m3onPrimary
                                enabled: inputField.text.length > 0 && PolkitService.interactionAvailable

                                function onClicked(): void {
                                    dialogContent.trySubmit();
                                }
                            }

                            StyledText {
                                id: authenticateText
                                anchors.centerIn: parent
                                text: qsTr("Authenticate")
                                color: Colours.palette.m3onPrimary
                                font.pointSize: Appearance.font.size.labelLarge
                                font.weight: Font.Medium
                            }
                        }
                    }
                }
            }
        }
    }
}
