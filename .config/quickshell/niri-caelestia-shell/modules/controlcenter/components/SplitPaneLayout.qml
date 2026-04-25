pragma ComponentBehavior: Bound

import qs.components
import qs.components.effects
import qs.config
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    spacing: 0

    property Component leftContent: null
    property Component rightContent: null

    property real leftWidthRatio: 0.4
    property int leftMinimumWidth: 420
    property var leftLoaderProperties: ({})
    property var rightLoaderProperties: ({})

    property alias leftLoader: leftLoader
    property alias rightLoader: rightLoader

    Item {
        id: leftPane

        Layout.preferredWidth: Math.floor(parent.width * root.leftWidthRatio)
        Layout.minimumWidth: root.leftMinimumWidth
        Layout.fillHeight: true

        ClippingRectangle {
            id: leftClippingRect

            anchors.fill: parent
            anchors.margins: Appearance.padding.md
            anchors.leftMargin: 0
            anchors.rightMargin: Appearance.padding.md / 2

            radius: leftBorder.innerRadius
            color: "transparent"

            Loader {
                id: leftLoader

                anchors.fill: parent
                anchors.margins: Appearance.padding.xl + Appearance.padding.md
                anchors.leftMargin: Appearance.padding.xl
                anchors.rightMargin: Appearance.padding.xl + Appearance.padding.md / 2

                sourceComponent: root.leftContent

                Component.onCompleted: {
                    for (const key in root.leftLoaderProperties) {
                        leftLoader[key] = root.leftLoaderProperties[key];
                    }
                }
            }
        }

        InnerBorder {
            id: leftBorder

            leftThickness: 0
            rightThickness: Appearance.padding.md / 2
        }
    }

    Item {
        id: rightPane

        Layout.fillWidth: true
        Layout.fillHeight: true

        ClippingRectangle {
            id: rightClippingRect

            anchors.fill: parent
            anchors.margins: Appearance.padding.md
            anchors.leftMargin: 0
            anchors.rightMargin: Appearance.padding.md / 2

            radius: rightBorder.innerRadius
            color: "transparent"

            Loader {
                id: rightLoader

                anchors.fill: parent
                anchors.margins: Appearance.padding.xl * 2

                sourceComponent: root.rightContent

                Component.onCompleted: {
                    for (const key in root.rightLoaderProperties) {
                        rightLoader[key] = root.rightLoaderProperties[key];
                    }
                }
            }
        }

        InnerBorder {
            id: rightBorder

            leftThickness: Appearance.padding.md / 2
        }
    }
}
