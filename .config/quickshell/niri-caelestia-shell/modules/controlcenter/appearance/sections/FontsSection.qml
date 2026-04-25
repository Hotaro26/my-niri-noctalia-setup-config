pragma ComponentBehavior: Bound

import ".."
import "../../components"
import qs.components
import qs.components.controls
import qs.components.containers
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

CollapsibleSection {
    id: root

    required property var rootPane

    title: qsTr("Fonts")
    showBackground: true

    ColumnLayout {
        spacing: Appearance.spacing.lg
        Layout.fillWidth: true

        FontDropdown {
            Layout.fillWidth: true
            label: qsTr("Material font family")
            currentFont: rootPane.fontFamilyMaterial
            onFontSelected: fontName => {
                rootPane.fontFamilyMaterial = fontName;
                rootPane.saveConfig();
            }
        }

        FontDropdown {
            Layout.fillWidth: true
            label: qsTr("Monospace font family")
            currentFont: rootPane.fontFamilyMono
            onFontSelected: fontName => {
                rootPane.fontFamilyMono = fontName;
                rootPane.saveConfig();
            }
        }

        FontDropdown {
            Layout.fillWidth: true
            label: qsTr("Sans-serif font family")
            currentFont: rootPane.fontFamilySans
            onFontSelected: fontName => {
                rootPane.fontFamilySans = fontName;
                rootPane.saveConfig();
            }
        }

        SectionContainer {
            contentSpacing: Appearance.spacing.lg

            SliderInput {
                Layout.fillWidth: true

                label: qsTr("Font size scale")
                value: rootPane.fontSizeScale
                from: 0.7
                to: 1.5
                decimals: 2
                suffix: "×"
                validator: DoubleValidator {
                    bottom: 0.7
                    top: 1.5
                }

                onValueModified: newValue => {
                    rootPane.fontSizeScale = newValue;
                    rootPane.saveConfig();
                }
            }
        }
    }
}
