pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property var families: []

    Process {
        id: fcList
        command: ["fc-list", ":", "family"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n");
                const familySet = new Set();
                for (const line of lines) {
                    if (line.trim() === "") continue;
                    // fc-list output is "Family Name:style=..."
                    // or just "Family Name"
                    const parts = line.split(":");
                    if (parts.length > 0) {
                        const familyNames = parts[0].split(",");
                        for (const name of familyNames) {
                            const trimmedName = name.trim();
                            if (trimmedName !== "") {
                                familySet.add(trimmedName);
                            }
                        }
                    }
                }
                const familyList = Array.from(familySet).sort();
                root.families = familyList;
                console.log("Fonts service: Loaded " + familyList.length + " fonts.");
            }
        }

        onExited: (exitCode) => {
            if (exitCode !== 0) {
                console.error("Fonts service: fc-list failed with exit code " + exitCode);
            }
        }
    }

    Component.onCompleted: {
        fcList.running = true;
    }
}
