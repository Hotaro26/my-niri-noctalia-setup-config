import qs.components
import qs.services
import qs.config
import qs.modules.launcher.services
import QtQuick

Item {
    id: root

    required property Actions.Action modelData
    required property var list

    implicitHeight: Config.launcher.sizes.itemHeight

    anchors.left: parent?.left
    anchors.right: parent?.right

    StateLayer {
        radius: Appearance.rounding.small

        function onClicked(): void {
            root.modelData?.onClicked(root.list);
        }
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: Appearance.padding.lg
        anchors.rightMargin: Appearance.padding.lg
        anchors.margins: Appearance.padding.sm

        MaterialIcon {
            id: icon

            text: root.modelData?.icon ?? ""
            font.pointSize: Appearance.font.size.headlineLarge

            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            anchors.left: icon.right
            anchors.leftMargin: Appearance.spacing.lg
            anchors.verticalCenter: icon.verticalCenter

            implicitWidth: parent.width - icon.width
            implicitHeight: name.implicitHeight + desc.implicitHeight

            StyledText {
                id: name

                text: root.modelData?.name ?? ""
                font.pointSize: Appearance.font.size.bodyMedium
            }

            StyledText {
                id: desc

                text: root.modelData?.desc ?? ""
                font.pointSize: Appearance.font.size.labelLarge
                color: Colours.palette.m3outline

                elide: Text.ElideRight
                width: root.width - icon.width - Appearance.rounding.normal * 2

                anchors.top: name.bottom
            }
        }
    }
}
