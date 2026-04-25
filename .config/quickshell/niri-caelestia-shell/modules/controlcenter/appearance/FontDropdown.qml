pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.components.containers
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property string label
    property string currentFont
    property var model: Fonts.families
    property bool expanded: false

    signal fontSelected(string fontName)

    spacing: Appearance.spacing.xs
    Layout.fillWidth: true

    // Header/Toggle Button
    StyledRect {
        id: header
        Layout.fillWidth: true
        implicitHeight: 56
        radius: Appearance.rounding.normal
        color: root.expanded ? Colours.palette.m3surfaceContainerHigh : Colours.palette.m3surfaceContainer
        border.width: 1
        border.color: root.expanded ? Colours.palette.m3primary : "transparent"

        Behavior on color { CAnim {} }
        Behavior on border.color { CAnim {} }

        StateLayer {
            function onClicked(): void {
                root.expanded = !root.expanded;
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: Appearance.padding.md
            spacing: Appearance.spacing.md

            ColumnLayout {
                spacing: 0

                StyledText {
                    text: root.label
                    font.pointSize: Appearance.font.size.labelMedium
                    color: Colours.palette.m3onSurfaceVariant
                    font.weight: 500
                }

                StyledText {
                    text: root.currentFont
                    font.pointSize: Appearance.font.size.bodyLarge
                    font.weight: 400
                    elide: Text.ElideRight
                    color: Colours.palette.m3onSurface
                }
            }

            Item {
                Layout.fillWidth: true
            }

            MaterialIcon {
                text: root.expanded ? "expand_less" : "expand_more"
                color: root.expanded ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.titleMedium
                
                Behavior on color { CAnim {} }
                Behavior on rotation { Anim {} }
            }
        }
    }

    // Dropdown Content
    StyledRect {
        id: dropdownContainer
        Layout.fillWidth: true
        implicitHeight: root.expanded ? 320 : 0
        visible: root.expanded || opacity > 0
        opacity: root.expanded ? 1 : 0
        radius: Appearance.rounding.normal
        color: Colours.palette.m3surfaceContainerHigh
        clip: true

        Behavior on implicitHeight {
            Anim { duration: Appearance.anim.durations.normal; easing.type: Easing.OutCubic }
        }
        Behavior on opacity {
            Anim { duration: Appearance.anim.durations.normal }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Appearance.padding.sm
            spacing: Appearance.spacing.sm

            // Search Bar
            StyledRect {
                Layout.fillWidth: true
                implicitHeight: 40
                radius: Appearance.rounding.small
                color: Colours.palette.m3surfaceContainerHighest
                border.width: 1
                border.color: searchField.hasFocus ? Colours.palette.m3primary : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Appearance.padding.md
                    anchors.rightMargin: Appearance.padding.sm
                    spacing: Appearance.spacing.sm

                    MaterialIcon {
                        text: "search"
                        font.pointSize: Appearance.font.size.bodyMedium
                        color: Colours.palette.m3onSurfaceVariant
                    }

                    StyledTextField {
                        id: searchField
                        Layout.fillWidth: true
                        placeholderText: qsTr("Search fonts...")
                        font.pointSize: Appearance.font.size.bodyMedium
                        
                        onTextChanged: {
                            fontList.positionViewAtBeginning();
                        }

                        onVisibleChanged: {
                            if (visible) searchField.forceActiveFocus();
                        }
                    }
                    
                    IconButton {
                        visible: searchField.text !== ""
                        icon: "close"
                        type: IconButton.Text
                        font.pointSize: Appearance.font.size.bodySmall
                        onClicked: searchField.text = ""
                    }
                }
            }

            // Font List
            StyledListView {
                id: fontList
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                property var filteredModel: {
                    if (!searchField.text) return root.model;
                    const query = searchField.text.toLowerCase();
                    return root.model.filter(font => font.toLowerCase().includes(query));
                }

                model: filteredModel
                spacing: Appearance.spacing.xs
                clip: true

                StyledScrollBar.vertical: StyledScrollBar {
                    flickable: fontList
                }

                delegate: StyledRect {
                    id: delegateRoot
                    required property string modelData
                    width: fontList.width
                    implicitHeight: 44
                    radius: Appearance.rounding.small
                    
                    readonly property bool isCurrent: modelData === root.currentFont
                    color: isCurrent ? Colours.palette.m3secondaryContainer : "transparent"

                    StateLayer {
                        function onClicked(): void {
                            root.fontSelected(modelData);
                            root.expanded = false;
                            searchField.text = "";
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Appearance.padding.md
                        anchors.rightMargin: Appearance.padding.md
                        spacing: Appearance.spacing.md

                        StyledText {
                            Layout.fillWidth: true
                            text: modelData
                            font.family: modelData
                            font.pointSize: Appearance.font.size.bodyMedium
                            color: isCurrent ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
                            elide: Text.ElideRight
                        }

                        MaterialIcon {
                            visible: isCurrent
                            text: "check"
                            font.pointSize: Appearance.font.size.bodyLarge
                            color: Colours.palette.m3onSecondaryContainer
                        }
                    }
                }
            }
        }
    }
}
