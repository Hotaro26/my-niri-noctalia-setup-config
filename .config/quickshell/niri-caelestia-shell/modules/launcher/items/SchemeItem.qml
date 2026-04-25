import qs.components
import qs.services
import qs.config
import QtQuick

Item {
    id: root

    required property Schemes.Scheme modelData
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

        StyledRect {
            id: preview

            anchors.verticalCenter: parent.verticalCenter

            border.width: 1
            border.color: Qt.alpha(`#${root.modelData?.colours?.outline}`, 0.5)

            color: `#${root.modelData?.colours?.surface}`
            radius: Appearance.rounding.small
            implicitWidth: parent.height * 0.8
            implicitHeight: parent.height * 0.8

            Item {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right

                implicitWidth: parent.implicitWidth / 2
                clip: true

                StyledRect {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right

                    implicitWidth: preview.implicitWidth
                    color: `#${root.modelData?.colours?.primary}`
                    radius: Appearance.rounding.small
                }
            }
        }

        Column {
            anchors.left: preview.right
            anchors.leftMargin: Appearance.spacing.lg
            anchors.verticalCenter: parent.verticalCenter

            width: parent.width - preview.width - anchors.leftMargin - (current.active ? current.width + Appearance.spacing.lg : 0)
            spacing: 0

            StyledText {
                text: root.modelData?.flavour ?? ""
                font.pointSize: Appearance.font.size.bodyMedium
            }

            StyledText {
                text: root.modelData?.name ?? ""
                font.pointSize: Appearance.font.size.labelLarge
                color: Colours.palette.m3outline

                elide: Text.ElideRight
                anchors.left: parent.left
                anchors.right: parent.right
            }
        }

        Loader {
            id: current

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            active: `${root.modelData?.name} ${root.modelData?.flavour}` === Schemes.currentScheme
            asynchronous: true

            sourceComponent: MaterialIcon {
                text: "check"
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.titleMedium
            }
        }
    }
}
