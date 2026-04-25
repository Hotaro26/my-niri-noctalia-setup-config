pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import qs.modules.controlcenter
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property ShellScreen screen
    required property Session session
    required property bool initialOpeningComplete

    implicitWidth: navFlickable.implicitWidth + Appearance.padding.xl * 2
    implicitHeight: parent ? parent.height : 400

    Flickable {
        id: navFlickable

        anchors.fill: parent
        anchors.leftMargin: Appearance.padding.xl
        anchors.rightMargin: Appearance.padding.xl
        anchors.topMargin: Appearance.padding.lg
        anchors.bottomMargin: Appearance.padding.lg

        contentHeight: layout.implicitHeight
        contentWidth: layout.implicitWidth
        flickableDirection: Flickable.VerticalFlick
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        implicitWidth: layout.implicitWidth

        ColumnLayout {
            id: layout

            spacing: 2

            Loader {
                Layout.bottomMargin: Appearance.spacing.xs
                active: !root.session.floating
                visible: active

                sourceComponent: StyledRect {
                    implicitWidth: floatRow.implicitWidth + Appearance.padding.xl * 2
                    implicitHeight: floatRow.implicitHeight + Appearance.padding.md * 2

                    color: Colours.palette.m3primaryContainer
                    radius: Appearance.rounding.small

                    StateLayer {
                        color: Colours.palette.m3onPrimaryContainer

                        function onClicked(): void {
                            root.session.root.close();
                            WindowFactory.create(null, {
                                active: root.session.active,
                                navExpanded: root.session.navExpanded
                            });
                        }
                    }

                    RowLayout {
                        id: floatRow

                        anchors.centerIn: parent
                        spacing: Appearance.spacing.sm

                        MaterialIcon {
                            text: "open_in_new"
                            color: Colours.palette.m3onPrimaryContainer
                            font.pointSize: Appearance.font.size.bodyLarge
                        }

                        StyledText {
                            text: qsTr("Float window")
                            color: Colours.palette.m3onPrimaryContainer
                            font.pointSize: Appearance.font.size.bodySmall
                        }
                    }
                }
            }

            Loader {
                active: !root.session.floating
                visible: active
                Layout.fillWidth: true
                Layout.topMargin: Appearance.spacing.xs
                Layout.bottomMargin: Appearance.spacing.sm

                sourceComponent: Rectangle {
                    implicitHeight: 1
                    color: Qt.alpha(Colours.palette.m3outlineVariant, 0.4)
                }
            }

            Repeater {
                model: PaneRegistry.count

                ColumnLayout {
                    id: navDelegate

                    required property int index
                    spacing: 0

                    Loader {
                        active: navDelegate.index > 0 && PaneRegistry.isFirstInCategory(navDelegate.index)
                        visible: active
                        Layout.fillWidth: true
                        Layout.leftMargin: Appearance.padding.md
                        Layout.rightMargin: Appearance.padding.md
                        Layout.topMargin: Appearance.spacing.sm
                        Layout.bottomMargin: Appearance.spacing.sm

                        sourceComponent: Rectangle {
                            implicitHeight: 1
                            color: Qt.alpha(Colours.palette.m3outlineVariant, 0.4)
                        }
                    }

                    NavItem {
                        icon: PaneRegistry.getByIndex(navDelegate.index).icon
                        label: PaneRegistry.getByIndex(navDelegate.index).label
                    }
                }
            }
        }
    }

    component NavItem: Item {
        id: item

        required property string icon
        required property string label
        readonly property bool active: root.session.active === label

        implicitWidth: background.implicitWidth
        implicitHeight: background.implicitHeight

        StyledRect {
            id: background

            anchors.left: parent.left
            anchors.right: parent.right

            radius: Appearance.rounding.full
            color: Qt.alpha(Colours.palette.m3secondaryContainer, item.active ? 1 : 0)

            implicitWidth: itemIcon.implicitWidth + itemIcon.anchors.leftMargin + itemLabel.anchors.leftMargin + itemLabel.implicitWidth + Appearance.padding.xl
            implicitHeight: Math.max(itemIcon.implicitHeight, itemLabel.implicitHeight) + Appearance.padding.md * 2

            Behavior on color {
                CAnim {}
            }

            StateLayer {
                color: item.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface

                function onClicked(): void {
                    if (!root.initialOpeningComplete)
                        return;
                    root.session.active = item.label;
                }
            }

            MaterialIcon {
                id: itemIcon

                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: Appearance.padding.xl

                text: item.icon
                color: item.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.bodyLarge
                fill: item.active ? 1 : 0

                Behavior on fill {
                    Anim {}
                }

                Behavior on color {
                    CAnim {}
                }
            }

            StyledText {
                id: itemLabel

                anchors.left: itemIcon.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: Appearance.spacing.lg

                text: item.label
                color: item.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.bodySmall
                font.weight: item.active ? Font.DemiBold : Font.Normal
                font.capitalization: Font.Capitalize

                Behavior on color {
                    CAnim {}
                }
            }
        }
    }
}
