pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string osName
    property string osPrettyName
    property string osId
    property list<string> osIdLike
    property string osLogo: `file://${Quickshell.shellDir}/assets/logo.svg`
    property bool isDefaultLogo: true

    property string uptime
    readonly property string user: Quickshell.env("USER")
    readonly property string wm: Quickshell.env("XDG_CURRENT_DESKTOP") || Quickshell.env("XDG_SESSION_DESKTOP")
    readonly property string shell: Quickshell.env("SHELL").split("/").pop()

    FileView {
        id: osRelease

        path: "/etc/os-release"
        onLoaded: {
            const lines = text().split("\n");

            const fd = key => lines.find(l => l.startsWith(`${key}=`))?.split("=")[1].replace(/"/g, "") ?? "";

            root.osName = fd("NAME");
            root.osPrettyName = fd("PRETTY_NAME");
            root.osId = fd("ID");
            root.osIdLike = fd("ID_LIKE").split(" ");

            const logo = Quickshell.iconPath(fd("LOGO"), true);
            if (logo) {
                root.osLogo = logo;
                root.isDefaultLogo = false;
            }
        }
    }

    // Read uptime once at startup and compute it from elapsed time thereafter
    property real _bootUptimeSecs: 0

    function formatUptime(totalSecs: real): string {
        const up = Math.floor(totalSecs);
        const days = Math.floor(up / 86400);
        const hours = Math.floor((up % 86400) / 3600);
        const minutes = Math.floor((up % 3600) / 60);

        let str = "";
        if (days > 0)
            str += `${days} day${days === 1 ? "" : "s"}`;
        if (hours > 0)
            str += `${str ? ", " : ""}${hours} hour${hours === 1 ? "" : "s"}`;
        if (minutes > 0 || !str)
            str += `${str ? ", " : ""}${minutes} minute${minutes === 1 ? "" : "s"}`;
        return str;
    }

    Timer {
        running: root._bootUptimeSecs > 0
        repeat: true
        interval: 60000
        onTriggered: {
            // Add elapsed minutes to initial reading
            root._bootUptimeSecs += 60;
            root.uptime = root.formatUptime(root._bootUptimeSecs);
        }
    }

    FileView {
        id: fileUptime

        path: "/proc/uptime"
        onLoaded: {
            root._bootUptimeSecs = parseFloat(text().split(" ")[0] ?? 0);
            root.uptime = root.formatUptime(root._bootUptimeSecs);
        }
    }
}
