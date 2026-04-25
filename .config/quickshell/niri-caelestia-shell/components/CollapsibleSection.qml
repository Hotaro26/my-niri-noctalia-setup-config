import qs.services
import qs.config
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    default property alias contentComponent: contentLoader.sourceComponent

    property string title: qsTr("Dropdown Title")
    property string description: ""
    property bool expanded: false
    property bool showBackground: false
    property bool nested: false
    property color backgroundColor: expanded ? Colours.palette.m3surfaceContainerLow : "transparent"

    // Margin properties: if backgroundMargins >= 0, use it for all sides; otherwise, use individual margins
    property real backgroundMarginLeft: Appearance.padding.xs
    property real backgroundMarginRight: Appearance.padding.xs
    property real backgroundMarginTop: Appearance.padding.xs
    property real backgroundMarginBottom: 0
    property real backgroundMargins: -1 // -1 means "not set"

    signal collapsed

    // Header height constant
    Rectangle {
        id: backgroundRect

        Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true

        Layout.leftMargin: root.backgroundMargins >= 0 ? root.backgroundMargins : root.backgroundMarginLeft
        Layout.rightMargin: root.backgroundMargins >= 0 ? root.backgroundMargins : root.backgroundMarginRight
        Layout.topMargin: root.backgroundMargins >= 0 ? root.backgroundMargins : root.backgroundMarginTop
        Layout.bottomMargin: root.backgroundMargins >= 0 ? root.backgroundMargins : root.backgroundMarginBottom

        color: root.backgroundColor
        // color: "transparent"
        radius: Appearance.rounding.small

        // Height is header + description (if shown) + content (if expanded) + margins
        Layout.preferredHeight: headerRow.implicitHeight + Appearance.padding.xs * 2 + (root.expanded && root.description !== "" ? descriptionText.implicitHeight + descriptionText.Layout.topMargin + descriptionText.Layout.bottomMargin : 0) + (root.expanded ? contentWrapper.implicitHeight : 0) + (anchors.topMargin + anchors.bottomMargin)

        Behavior on Layout.preferredHeight {
            Anim {}
        }

        ColumnLayout {
            anchors.fill: parent

            // Header
            RowLayout {
                id: headerRow
                Layout.topMargin: Appearance.padding.xs
                Layout.leftMargin: Appearance.padding.xl
                Layout.rightMargin: Appearance.padding.xs
                Layout.bottomMargin: Appearance.padding.xs

                spacing: Appearance.spacing.lg
                implicitHeight: Appearance.spacing.lg + Appearance.padding.xs * 2

                StyledText {
                    Layout.fillWidth: true
                    text: root.title
                    elide: Text.ElideRight
                    font.pointSize: Appearance.font.size.bodySmall
                    font.family: Appearance.font.family.sans
                }

                StyledRect {
                    color: "transparent"

                    radius: Appearance.rounding.small

                    implicitWidth: expandIcon.implicitWidth + Appearance.padding.xs * 2
                    implicitHeight: expandIcon.implicitHeight + Appearance.padding.xs

                    StateLayer {
                        function onClicked(): void {
                            root.expanded = !root.expanded;
                        }
                    }

                    MaterialIcon {
                        id: expandIcon
                        anchors.centerIn: parent
                        animate: true
                        text: root.expanded ? "expand_less" : "expand_more"
                        color: root.expanded ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant

                        font.pointSize: Appearance.font.size.titleMedium
                    }
                }
            }

            // Description text (shown when expanded and description is set)
            StyledText {
                id: descriptionText
                Layout.fillWidth: true
                Layout.leftMargin: Appearance.padding.xl
                Layout.rightMargin: Appearance.padding.xs
                Layout.topMargin: root.description !== "" ? Appearance.spacing.md : 0
                Layout.bottomMargin: root.description !== "" ? Appearance.spacing.sm : 0
                visible: root.expanded && root.description !== ""
                text: root.description
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.labelLarge
                wrapMode: Text.Wrap
            }

            // Collapsible content
            WrapperItem {
                id: contentWrapper
                Layout.fillWidth: true
                Layout.leftMargin: Appearance.padding.sm
                Layout.rightMargin: Appearance.padding.sm

                // Animate height for smooth expand/collapse
                Layout.preferredHeight: root.expanded ? contentLoader.implicitHeight + topMargin + bottomMargin : 0
                clip: true

                // topMargin: Appearance.spacing.md
                // bottomMargin: Appearance.spacing.md
                bottomMargin: Appearance.padding.xl

                Loader {
                    id: contentLoader
                    Layout.fillWidth: true
                    active: root.expanded
                }

                Behavior on Layout.preferredHeight {
                    Anim {}
                }
            }
        }
    }

    function collapse(): void {
        if (expanded) {
            expanded = false;
        }
    }

    onExpandedChanged: {
        if (!expanded) {
            collapsed();
        }
    }
}
