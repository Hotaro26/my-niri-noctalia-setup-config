// SddmColors.qml — Matugen template
// Place in ~/.config/niri-caelestia-sddm/SddmColors.qml
// Matugen will fill in color placeholders and write Colors.qml

// {{image}}

import QtQuick

QtObject {
    // Material You color tokens (dark scheme)
    readonly property color background:        "{{colors.background.dark.hex}}"
    readonly property color colBackground:      "{{colors.on_background.dark.hex}}"
    readonly property color surface:           "{{colors.surface.dark.hex}}"
    readonly property color surfaceVariant:    "{{colors.surface_variant.dark.hex}}"
    readonly property color colSurface:         "{{colors.on_surface.dark.hex}}"
    readonly property color colSurfaceVariant:  "{{colors.on_surface_variant.dark.hex}}"
    readonly property color primary:           "{{colors.primary.dark.hex}}"
    readonly property color colPrimary:         "{{colors.on_primary.dark.hex}}"
    readonly property color primaryContainer:  "{{colors.primary_container.dark.hex}}"
    readonly property color secondary:         "{{colors.secondary.dark.hex}}"
    readonly property color colSecondary:       "{{colors.on_secondary.dark.hex}}"
    readonly property color outline:           "{{colors.outline.dark.hex}}"
    readonly property color outlineVariant:    "{{colors.outline_variant.dark.hex}}"
    readonly property color error:             "{{colors.error.dark.hex}}"
    readonly property color colError:           "{{colors.on_error.dark.hex}}"
    readonly property color tertiary:          "{{colors.tertiary.dark.hex}}"
    readonly property color colTertiary:        "{{colors.on_tertiary.dark.hex}}"
    
    // Convenience aliases
    readonly property color textPrimary:       "{{colors.on_surface.dark.hex}}"
    readonly property color textSecondary:     "{{colors.on_surface_variant.dark.hex}}"
}
