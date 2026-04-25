#!/bin/bash
# OCR: capture region screenshot, extract text with tesseract, copy to clipboard
# Usage: region_ocr.sh <geometry> (e.g. "100,200 300x400")

GEOMETRY="$1"
if [ -z "$GEOMETRY" ]; then
    echo "Usage: region_ocr.sh <geometry>"
    exit 1
fi

TMPFILE=$(mktemp /tmp/ocr-XXXXXX.png)
trap "rm -f '$TMPFILE'" EXIT

# Capture the region
grim -l 0 -g "$GEOMETRY" "$TMPFILE"

# OCR with tesseract and copy to clipboard
TEXT=$(tesseract "$TMPFILE" - 2>/dev/null)

if [ -n "$TEXT" ]; then
    echo -n "$TEXT" | wl-copy
    notify-send -a "OCR" "Text copied" "$TEXT" -i edit-copy
else
    notify-send -a "OCR" "No text found" "Could not extract text from the selected region" -i dialog-warning
fi
