import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

ShellRoot {
    PanelWindow {
        id: switcherWindow
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        implicitWidth: 400
        implicitHeight: 250
        color: "transparent"
        
        property int selectedIndex: 0 // 0 for Noctalia, 1 for Caelestia
        
        Rectangle {
            anchors.fill: parent
            color: "#1e1e2e"
            radius: 20
            border.color: "#89b4fa"
            border.width: 2
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Select Shell"
                    color: "white"
                    font.pixelSize: 24
                    font.bold: true
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20
                    ShellButton {
                        text: "Noctalia"
                        isActive: switcherWindow.selectedIndex === 0
                        onClicked: Quickshell.execDetached(["/home/hotaro/.local/bin/do-switch-noctalia.sh"])
                    }
                    ShellButton {
                        text: "Caelestia"
                        isActive: switcherWindow.selectedIndex === 1
                        onClicked: Quickshell.execDetached(["/home/hotaro/.local/bin/do-switch-caelestia.sh"])
                    }
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Arrows to Select • Enter to Confirm"
                    color: "#a6adc8"
                    font.pixelSize: 14
                }
            }
        }

        // --- Keyboard Controls ---
        Shortcut {
            sequence: "Left"
            onActivated: switcherWindow.selectedIndex = 0
        }
        Shortcut {
            sequence: "Right"
            onActivated: switcherWindow.selectedIndex = 1
        }
        Shortcut {
            sequence: "Up"
            onActivated: switcherWindow.selectedIndex = 0
        }
        Shortcut {
            sequence: "Down"
            onActivated: switcherWindow.selectedIndex = 1
        }
        Shortcut {
            sequence: "Return"
            onActivated: {
                if (switcherWindow.selectedIndex === 0) {
                    Quickshell.execDetached(["/home/hotaro/.local/bin/do-switch-noctalia.sh"]);
                } else {
                    Quickshell.execDetached(["/home/hotaro/.local/bin/do-switch-caelestia.sh"]);
                }
                Qt.quit();
            }
        }
        Shortcut {
            sequence: "Escape"
            onActivated: Qt.quit()
        }
    }
    
    component ShellButton: Rectangle {
        property string text: ""
        property bool isActive: false
        signal clicked()
        
        Layout.fillWidth: true
        Layout.preferredHeight: 100
        
        // Change color based on selection or mouse hover
        color: (isActive || mouseArea.containsMouse) ? "#313244" : "#181825"
        radius: 15
        border.color: (isActive || mouseArea.containsMouse) ? "#89b4fa" : "transparent"
        border.width: isActive ? 2 : 1
        
        Text {
            anchors.centerIn: parent
            text: parent.text
            color: "white"
            font.pixelSize: 18
            font.bold: parent.isActive
        }
        
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                parent.clicked();
                Qt.quit();
            }
        }
    }
}
