pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.components.images
import qs.services
import qs.config
import qs.utils
import QtQuick
import Quickshell.Io
import QtQuick.Layouts
import QtQuick.Effects

// Floating panel center content: clock + date + divider + avatar + input + status
ColumnLayout {
    id: root

    required property var lock

    readonly property list<string> timeComponents: Time.format(Config.services.useTwelveHourClock ? "hh:mm:A" : "hh:mm").split(":")
    readonly property real panelScale: Math.min(1, (lock.screen?.height ?? 1080) / 1080)

    spacing: 0

    // Top flex spacer (1 part) — upper breathing room
    Item {
        Layout.fillHeight: true
        Layout.preferredHeight: 1
    }

    // ── Clock ──────────────────────────────────────────────────────────────────
    Item {
        Layout.fillWidth: true
        implicitHeight: clockRow.implicitHeight

        RowLayout {
            id: clockRow
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Appearance.spacing.xs

            StyledText {
                text: root.timeComponents[0]
                color: Colours.palette.m3onSurface
                font.pointSize: Math.floor(Appearance.font.size.headlineLarge * 2.8 * root.panelScale)
                font.family: Appearance.font.family.clock
                font.weight: Font.Bold
            }

            // Blinking colon — synced to wall-clock seconds
            StyledText {
                id: colonText
                text: ":"
                color: Colours.palette.m3primary
                font.pointSize: Math.floor(Appearance.font.size.headlineLarge * 2.8 * root.panelScale)
                font.family: Appearance.font.family.clock
                font.weight: Font.Bold
                opacity: 1

                Connections {
                    target: Time
                    function onSecondsChanged(): void {
                        colonText.opacity = 1;
                        colonFadeOut.restart();
                    }
                }

                SequentialAnimation {
                    id: colonFadeOut
                    PauseAnimation { duration: 300 }
                    Anim { target: colonText; property: "opacity"; to: 0.25; duration: 300; easing.type: Easing.InOutSine }
                    PauseAnimation { duration: 100 }
                    Anim { target: colonText; property: "opacity"; to: 1; duration: 300; easing.type: Easing.InOutSine }
                }
            }

            StyledText {
                text: root.timeComponents[1]
                color: Colours.palette.m3onSurface
                font.pointSize: Math.floor(Appearance.font.size.headlineLarge * 2.8 * root.panelScale)
                font.family: Appearance.font.family.clock
                font.weight: Font.Bold
            }

            // AM/PM badge
            Loader {
                Layout.leftMargin: Appearance.spacing.sm
                Layout.alignment: Qt.AlignVCenter

                asynchronous: true
                active: Config.services.useTwelveHourClock
                visible: active

                sourceComponent: StyledRect {
                    implicitWidth: amPmLabel.implicitWidth + Appearance.padding.sm * 2
                    implicitHeight: amPmLabel.implicitHeight + Appearance.padding.xs

                    radius: Appearance.rounding.small
                    color: Qt.alpha(Colours.palette.m3secondaryContainer, 0.7)

                    StyledText {
                        id: amPmLabel
                        anchors.centerIn: parent
                        text: root.timeComponents[2] ?? ""
                        color: Colours.palette.m3onSecondaryContainer
                        font.pointSize: Math.floor(Appearance.font.size.labelLarge * root.panelScale)
                        font.family: Appearance.font.family.clock
                        font.weight: Font.DemiBold
                    }
                }
            }
        }
    }

    // Date
    StyledText {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: Appearance.spacing.xs

        text: Time.format("dddd, d MMMM yyyy")
        color: Colours.palette.m3onSurfaceVariant
        font.pointSize: Math.floor(Appearance.font.size.bodyMedium * root.panelScale)
        font.family: Appearance.font.family.mono
    }

    // Gradient divider — fades at edges for a refined look
    Rectangle {
        Layout.fillWidth: true
        Layout.topMargin: Appearance.spacing.md
        Layout.bottomMargin: Appearance.spacing.md
        Layout.leftMargin: Appearance.padding.xl
        Layout.rightMargin: Appearance.padding.xl
        height: 1
        color: "transparent"
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0;  color: "transparent" }
            GradientStop { position: 0.15; color: Qt.alpha(Colours.palette.m3outlineVariant, 0.6) }
            GradientStop { position: 0.85; color: Qt.alpha(Colours.palette.m3outlineVariant, 0.6) }
            GradientStop { position: 1.0;  color: "transparent" }
        }
    }

    // ── Avatar ─────────────────────────────────────────────────────────────────
    Item {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: Appearance.spacing.lg
        implicitWidth: avatarSize
        implicitHeight: avatarSize

        readonly property int avatarSize: Math.round(96 * root.panelScale)

        // Circular avatar background
        StyledRect {
            anchors.fill: parent
            radius: Appearance.rounding.full
            color: Qt.alpha(Colours.palette.m3secondaryContainer, 0.55)
        }

        // Accent ring
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            radius: Appearance.rounding.full
            color: "transparent"
            border.width: 2
            border.color: Qt.alpha(Colours.palette.m3primary, 0.45)
        }

        StyledClippingRect {
            anchors.fill: parent
            radius: Appearance.rounding.full
            color: "transparent"

            MaterialIcon {
                anchors.centerIn: parent
                text: "person"
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Math.floor(parent.width * 0.45)
            }

            CachingImage {
                id: pfp
                anchors.fill: parent
                path: `${Paths.home}/.face`
            }

            CachingImage {
                id: wallpaperFallback
                anchors.fill: parent
                path: Wallpapers.getColorSource(Wallpapers.current)
                visible: pfp.status !== Image.Ready && Config.dashboard.useWallpaperAvatar
            }
        }
    }

    // Username hint
    StyledText {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: Appearance.spacing.sm

        text: SysInfo.user
        color: Colours.palette.m3onSurfaceVariant
        font.pointSize: Math.floor(Appearance.font.size.bodyMedium * root.panelScale)
        font.weight: Font.Medium
    }

    // ── Password input ─────────────────────────────────────────────────────────

    // Input bar: fprint icon │ dots │ enter button
    StyledRect {
        id: inputBar
        Layout.fillWidth: true
        Layout.topMargin: Appearance.spacing.md
        Layout.leftMargin: Appearance.padding.lg
        Layout.rightMargin: Appearance.padding.lg
        implicitHeight: inputRow.implicitHeight + Appearance.padding.sm * 2

        color: Qt.alpha(Colours.palette.m3surfaceContainerHigh, 0.75)
        radius: Appearance.rounding.full
        border.width: activeFocus ? 2 : 0
        border.color: Colours.palette.m3primary

        CAnim { properties: "color,border.width" }

        // Keyboard focus receiver
        focus: true
        onActiveFocusChanged: {
            if (!activeFocus)
                forceActiveFocus();
        }

        Keys.onPressed: event => {
            if (root.lock.unlocking)
                return;

            if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return)
                inputField.placeholder.animate = false;

            root.lock.pam.handleKey(event);
        }

        StateLayer {
            hoverEnabled: false
            cursorShape: Qt.IBeamCursor
            function onClicked(): void {
                parent.forceActiveFocus();
            }
        }

        RowLayout {
            id: inputRow

            anchors.fill: parent
            anchors.margins: Appearance.padding.sm
            spacing: Appearance.spacing.md

            // Fprint / busy indicator
            Item {
                implicitWidth: implicitHeight
                implicitHeight: fprintIcon.implicitHeight + Appearance.padding.xs * 2

                MaterialIcon {
                    id: fprintIcon

                    anchors.centerIn: parent
                    animate: true
                    text: {
                        if (root.lock.pam.fprint.tries >= Config.lock.maxFprintTries)
                            return "fingerprint_off";
                        if (root.lock.pam.fprint.active)
                            return "fingerprint";
                        return "lock";
                    }
                    color: root.lock.pam.fprint.tries >= Config.lock.maxFprintTries
                        ? Colours.palette.m3error
                        : root.lock.pam.fprint.active
                            ? Colours.palette.m3secondary
                            : Colours.palette.m3onSurfaceVariant
                    opacity: root.lock.pam.passwd.active ? 0 : 1

                    Behavior on opacity { Anim {} }
                }

                StyledBusyIndicator {
                    anchors.fill: parent
                    running: root.lock.pam.passwd.active
                }
            }

            InputField {
                id: inputField
                Layout.fillWidth: true
                pam: root.lock.pam
            }

            // Enter / submit button
            StyledRect {
                implicitWidth: implicitHeight
                implicitHeight: enterIcon.implicitHeight + Appearance.padding.sm * 2

                color: root.lock.pam.buffer
                    ? Colours.palette.m3primary
                    : Qt.alpha(Colours.palette.m3surfaceContainerHigh, 0.8)
                radius: Appearance.rounding.full

                CAnim { properties: "color" }

                StateLayer {
                    color: root.lock.pam.buffer
                        ? Colours.palette.m3onPrimary
                        : Colours.palette.m3onSurface

                    function onClicked(): void {
                        root.lock.pam.passwd.start();
                    }
                }

                MaterialIcon {
                    id: enterIcon
                    anchors.centerIn: parent
                    text: "arrow_forward"
                    color: root.lock.pam.buffer
                        ? Colours.palette.m3onPrimary
                        : Colours.palette.m3onSurface
                    font.weight: 500

                    CAnim { properties: "color" }
                }
            }
        }
    }

    // ── Status messages ────────────────────────────────────────────────────────
    readonly property bool isCapsLock: Niri.capsLock

    Item {
        Layout.fillWidth: true
        Layout.topMargin: Appearance.spacing.sm
        Layout.bottomMargin: Appearance.spacing.sm
        Layout.leftMargin: Appearance.padding.lg
        Layout.rightMargin: Appearance.padding.lg

        implicitHeight: Math.max(stateMessage.implicitHeight, errorMessage.implicitHeight)

        Behavior on implicitHeight { Anim {} }

        // Caps lock / layout indicator
        StyledText {
            id: stateMessage

            readonly property string msg: {
                let layoutName = (Niri.kbLayoutFull ?? Niri.kbLayout);
                if (root.isCapsLock)
                    return qsTr("Caps lock ON · Layout: %1").arg(layoutName);
                if (Niri.kbLayout !== Niri.defaultKbLayout)
                    return qsTr("Layout: %1").arg(layoutName);
                return "";
            }

            property bool shouldBeVisible

            onMsgChanged: {
                if (msg) {
                    if (opacity > 0) {
                        animate = true;
                        text = msg;
                        animate = false;
                    } else {
                        text = msg;
                    }
                    shouldBeVisible = true;
                } else {
                    shouldBeVisible = false;
                }
            }

            anchors.left: parent.left
            anchors.right: parent.right

            opacity: shouldBeVisible && !errorMessage.msg ? 0.8 : 0
            color: Colours.palette.m3onSurfaceVariant
            animateProp: "opacity"

            font.pointSize: Math.floor(Appearance.font.size.labelLarge * root.panelScale)
            font.family: Appearance.font.family.mono
            horizontalAlignment: Qt.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

            Behavior on opacity { Anim {} }
        }

        // Auth error / PAM message
        StyledText {
            id: errorMessage

            readonly property Pam pam: root.lock.pam
            readonly property string msg: {
                if (pam.fprintState === "error")
                    return qsTr("Error: %1").arg(pam.fprint.message);
                if (pam.state === "error")
                    return qsTr("Error: %1").arg(pam.passwd.message);
                if (pam.lockMessage)
                    return pam.lockMessage;
                if (pam.state === "max" && pam.fprintState === "max")
                    return qsTr("Maximum attempts reached.");
                if (pam.state === "max")
                    return pam.fprint.available
                        ? qsTr("Max password attempts. Use fingerprint.")
                        : qsTr("Maximum password attempts reached.");
                if (pam.fprintState === "max")
                    return qsTr("Max fingerprint attempts. Use password.");
                if (pam.state === "fail")
                    return pam.fprint.available
                        ? qsTr("Wrong password. Try again or use fingerprint.")
                        : qsTr("Incorrect password. Please try again.");
                if (pam.fprintState === "fail")
                    return qsTr("Fingerprint not recognized (%1/%2).").arg(pam.fprint.tries).arg(Config.lock.maxFprintTries);
                return "";
            }

            anchors.left: parent.left
            anchors.right: parent.right

            opacity: 0
            color: Colours.palette.m3error

            font.pointSize: Math.floor(Appearance.font.size.labelLarge * root.panelScale)
            font.family: Appearance.font.family.mono
            horizontalAlignment: Qt.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

            onMsgChanged: {
                if (msg) {
                    if (opacity > 0) {
                        animate = true;
                        text = msg;
                        animate = false;
                        exitAnim.stop();
                        if (opacity < 1)
                            appearAnim.restart();
                        else
                            flashAnim.restart();
                    } else {
                        text = msg;
                        exitAnim.stop();
                        appearAnim.restart();
                    }
                } else {
                    appearAnim.stop();
                    flashAnim.stop();
                    exitAnim.start();
                }
            }

            Connections {
                target: root.lock.pam
                function onFlashMsg(): void {
                    exitAnim.stop();
                    if (errorMessage.opacity < 1)
                        appearAnim.restart();
                    else
                        flashAnim.restart();
                }
            }

            Anim {
                id: appearAnim
                target: errorMessage
                property: "opacity"
                to: 1
                onFinished: flashAnim.restart()
            }

            SequentialAnimation {
                id: flashAnim
                loops: 2
                FlashAnim { to: 0.35 }
                FlashAnim { to: 1 }
            }

            Anim {
                id: exitAnim
                target: errorMessage
                property: "opacity"
                to: 0
                duration: Appearance.anim.durations.large
            }
        }
    }

    component FlashAnim: NumberAnimation {
        target: errorMessage
        property: "opacity"
        duration: Appearance.anim.durations.small
        easing.type: Easing.Linear
    }

    // Bottom flex spacer (2 parts) — keeps status messages above the floor
    Item {
        Layout.fillHeight: true
        Layout.preferredHeight: 2
    }
}

