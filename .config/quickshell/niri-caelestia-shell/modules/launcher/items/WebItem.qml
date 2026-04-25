import qs.components
import qs.services
import qs.config
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property var list
    readonly property string query: list.search.text.slice(`${Config.launcher.actionPrefix}web `.length).trim()
    readonly property bool isUrl: {
        const q = query.toLowerCase();
        return q.includes(".") && !q.includes(" ");
    }
    readonly property string url: {
        if (!query) return "";
        if (isUrl) {
            if (query.startsWith("http://") || query.startsWith("https://"))
                return query;
            return "https://" + query;
        }
        return "https://www.google.com/search?q=" + encodeURIComponent(query);
    }

    function onClicked(): void {
        if (!query) return;
        Quickshell.execDetached(["xdg-open", url]);
        root.list.visibilities.launcher = false;
    }

    implicitHeight: Config.launcher.sizes.itemHeight

    anchors.left: parent?.left
    anchors.right: parent?.right

    StateLayer {
        radius: Appearance.rounding.full

        function onClicked(): void {
            root.onClicked();
        }
    }

    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: Appearance.padding.lg

        spacing: Appearance.spacing.lg

        MaterialIcon {
            text: root.isUrl ? "open_in_browser" : "search"
            font.pointSize: Appearance.font.size.headlineLarge
            Layout.alignment: Qt.AlignVCenter
        }

        StyledText {
            id: result

            color: {
                if (!root.query)
                    return Colours.palette.m3onSurfaceVariant;
                return Colours.palette.m3onSurface;
            }

            text: {
                if (!root.query)
                    return qsTr("Type a URL or search query");
                if (root.isUrl)
                    return qsTr("Open %1").arg(root.url);
                return qsTr("Search \"%1\"").arg(root.query);
            }
            elide: Text.ElideRight

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }

        StyledRect {
            color: Colours.palette.m3tertiary
            radius: Appearance.rounding.normal
            clip: true

            implicitWidth: icon.implicitWidth + Appearance.padding.md * 2
            implicitHeight: Math.max(icon.implicitHeight) + Appearance.padding.xs * 2

            Layout.alignment: Qt.AlignVCenter

            StateLayer {
                color: Colours.palette.m3onTertiary

                function onClicked(): void {
                    root.onClicked();
                }
            }

            MaterialIcon {
                id: icon

                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Appearance.padding.md

                text: root.isUrl ? "open_in_new" : "search"
                color: Colours.palette.m3onTertiary
                font.pointSize: Appearance.font.size.titleMedium
            }
        }
    }
}
