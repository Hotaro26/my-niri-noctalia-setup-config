pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Polkit
import QtQuick

/**
 * PolkitService — native polkit authentication agent for niri-caelestia-shell.
 *
 * Replaces the external polkit-kde-authentication-agent-1.
 * The service owns the PolkitAgent registration and exposes cleaned-up
 * properties consumed by PolkitDialog.
 */
Singleton {
    id: root

    // ── Public state ──────────────────────────────────────────────────────────

    property alias agent: polkitAgent
    property alias active: polkitAgent.isActive
    property alias flow: polkitAgent.flow

    /** Set to true when user input is expected (initial attempt or after failure). */
    property bool interactionAvailable: false

    /** Whether the user has just submitted (prevents double-submit). */
    property bool submitting: false

    /** Number of failed authentication attempts in the current flow. 0 on first open. */
    property int failedAttempts: 0

    // ── Cleaned-up text helpers ───────────────────────────────────────────────

    /**
     * The polkit message with trailing period stripped, for cleaner display.
     */
    readonly property string cleanMessage: {
        if (!root.flow) return "";
        const msg = root.flow.message ?? "";
        return msg.endsWith(".") ? msg.slice(0, -1) : msg;
    }

    /**
     * The input prompt label.  Falls back to "Password" for password fields,
     * "Input" for visible-response fields where no prompt string is supplied.
     */
    readonly property string cleanPrompt: {
        const raw = (root.flow?.inputPrompt ?? "").trim();
        const cleaned = raw.endsWith(":") ? raw.slice(0, -1) : raw;
        const usePassword = !(root.flow?.responseVisible ?? false);
        return cleaned || (usePassword ? qsTr("Password") : qsTr("Input"));
    }

    /**
     * Whether the user's response should be displayed in clear text.
     * False → render as password dots (default for sudo / pkexec).
     */
    readonly property bool responseVisible: root.flow?.responseVisible ?? false

    /**
     * Display-friendly name of the subject application.
     * Falls back to a generic label if the flow provides nothing.
     */
    readonly property string subjectName: root.flow?.subject ?? ""

    // ── Public functions ──────────────────────────────────────────────────────

    /** Cancel the current authentication request. */
    function cancel(): void {
        if (root.flow) {
            root.flow.cancelAuthenticationRequest();
            root.interactionAvailable = false;
            root.submitting = false;
        }
    }

    /**
     * Submit a response string and mark as submitting.
     * The PolkitAgent will call onAuthenticationFailed if wrong, at which
     * point interactionAvailable flips back to true so the user can retry.
     */
    function submit(response: string): void {
        if (!root.flow || !root.interactionAvailable) return;
        root.submitting = true;
        root.interactionAvailable = false;
        root.flow.submit(response);
    }

    // ── Internal connections ──────────────────────────────────────────────────

    Connections {
        target: root.flow

        function onAuthenticationFailed(): void {
            root.failedAttempts++;
            root.submitting = false;
            root.interactionAvailable = true;
        }
    }

    PolkitAgent {
        id: polkitAgent

        onAuthenticationRequestStarted: {
            root.failedAttempts = 0;
            root.submitting = false;
            root.interactionAvailable = true;
        }
    }
}
