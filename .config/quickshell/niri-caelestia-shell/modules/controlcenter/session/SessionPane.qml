pragma ComponentBehavior: Bound

import ".."
import "../components"
import qs.components
import qs.components.controls
import qs.components.effects
import qs.components.containers
import qs.services
import qs.config
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property Session session

    property bool enabled: Config.session.enabled ?? true
    property bool vimKeybinds: Config.session.vimKeybinds ?? false
    property int dragThreshold: Config.session.dragThreshold ?? 30
    property int buttonSize: Config.session.sizes.button ?? 80

    anchors.fill: parent

    function saveConfig() {
        Config.session.enabled = root.enabled;
        Config.session.vimKeybinds = root.vimKeybinds;
        Config.session.dragThreshold = root.dragThreshold;
        Config.session.sizes.button = root.buttonSize;
        Config.markDirty("session");
    }

    ClippingRectangle {
        id: sessionClippingRect
        anchors.fill: parent
        anchors.margins: Appearance.padding.md
        anchors.leftMargin: 0
        anchors.rightMargin: Appearance.padding.md

        radius: sessionBorder.innerRadius
        color: "transparent"

        Loader {
            id: sessionLoader
            anchors.fill: parent
            anchors.margins: Appearance.padding.xl + Appearance.padding.md
            anchors.leftMargin: Appearance.padding.xl
            anchors.rightMargin: Appearance.padding.xl

            sourceComponent: sessionContentComponent
        }
    }

    InnerBorder {
        id: sessionBorder
        leftThickness: 0
        rightThickness: Appearance.padding.md
    }

    Component {
        id: sessionContentComponent

        StyledFlickable {
            id: sessionFlickable
            flickableDirection: Flickable.VerticalFlick
            contentHeight: sessionLayout.height

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: sessionFlickable
            }

            ColumnLayout {
                id: sessionLayout
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: Appearance.spacing.lg

                RowLayout {
                    spacing: Appearance.spacing.md

                    StyledText {
                        text: qsTr("Session")
                        font.pointSize: Appearance.font.size.titleMedium
                        font.weight: 500
                    }
                }

                // General Section
                SectionContainer {
                    alignTop: true

                    StyledText {
                        text: qsTr("General")
                        font.pointSize: Appearance.font.size.bodyMedium
                    }

                    SwitchRow {
                        label: qsTr("Enabled")
                        checked: root.enabled
                        onToggled: checked => {
                            root.enabled = checked;
                            root.saveConfig();
                        }
                    }

                    SwitchRow {
                        label: qsTr("Vim keybinds")
                        checked: root.vimKeybinds
                        onToggled: checked => {
                            root.vimKeybinds = checked;
                            root.saveConfig();
                        }
                    }

                    SectionContainer {
                        contentSpacing: Appearance.spacing.lg

                        SliderInput {
                            Layout.fillWidth: true

                            label: qsTr("Drag threshold")
                            value: root.dragThreshold
                            from: 0
                            to: 100
                            suffix: "px"
                            validator: IntValidator { bottom: 0; top: 100 }
                            formatValueFunction: val => Math.round(val).toString()
                            parseValueFunction: text => parseInt(text)

                            onValueModified: newValue => {
                                root.dragThreshold = Math.round(newValue);
                                root.saveConfig();
                            }
                        }
                    }
                }

                // Sizing Section
                SectionContainer {
                    alignTop: true

                    StyledText {
                        text: qsTr("Sizing")
                        font.pointSize: Appearance.font.size.bodyMedium
                    }

                    SectionContainer {
                        contentSpacing: Appearance.spacing.lg

                        SliderInput {
                            Layout.fillWidth: true

                            label: qsTr("Button size")
                            value: root.buttonSize
                            from: 40
                            to: 160
                            stepSize: 5
                            suffix: "px"
                            validator: IntValidator { bottom: 40; top: 160 }
                            formatValueFunction: val => Math.round(val).toString()
                            parseValueFunction: text => parseInt(text)

                            onValueModified: newValue => {
                                root.buttonSize = Math.round(newValue);
                                root.saveConfig();
                            }
                        }
                    }
                }
            }
        }
    }
}
