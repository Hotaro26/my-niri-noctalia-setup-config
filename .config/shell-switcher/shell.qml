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
                        onClicked: Quickshell.execDetached(["/home/hotaro/.local/bin/do-switch-noctalia.sh"])
                    }
                    ShellButton {
                        text: "Caelestia"
                        onClicked: Quickshell.execDetached(["/home/hotaro/.local/bin/do-switch-caelestia.sh"])
                    }
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Press ESC to Cancel"
                    color: "#a6adc8"
                    font.pixelSize: 14
                }
            }
        }
        Shortcut {
            sequence: "Escape"
            onActivated: Qt.quit()
        }
    }
    
    component ShellButton: Rectangle {
        property string text: ""
        signal clicked()
        Layout.fillWidth: true
        Layout.preferredHeight: 100
        color: mouseArea.containsMouse ? "#313244" : "#181825"
        radius: 15
        border.color: mouseArea.containsMouse ? "#89b4fa" : "transparent"
        border.width: 1
        Text {
            anchors.centerIn: parent
            text: parent.text
            color: "white"
            font.pixelSize: 18
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
