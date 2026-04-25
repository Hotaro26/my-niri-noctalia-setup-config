#!/bin/bash
# Google Lens search: capture region screenshot and open in Google Lens
# Usage: region_search.sh <geometry> (e.g. "100,200 300x400")

GEOMETRY="$1"
if [ -z "$GEOMETRY" ]; then
    echo "Usage: region_search.sh <geometry>"
    exit 1
fi

TMPFILE=$(mktemp /tmp/lens-XXXXXX.png)

# Capture the region
grim -l 0 -g "$GEOMETRY" "$TMPFILE"

if [ ! -s "$TMPFILE" ]; then
    notify-send -a "Google Lens" "Screenshot failed" "Could not capture the selected region" -i dialog-error
    rm -f "$TMPFILE"
    exit 1
fi

# Upload to a temporary file host and open with Google Lens
# Try litterbox.catbox.moe (temporary file hosting, 1 hour expiry)
IMG_URL=$(curl -s \
    -F "reqtype=fileupload" \
    -F "time=1h" \
    -F "fileToUpload=@${TMPFILE}" \
    "https://litterbox.catbox.moe/resources/internals/api.php" \
    --max-time 15 2>/dev/null)

if [ -n "$IMG_URL" ] && [[ "$IMG_URL" == http* ]]; then
    xdg-open "https://lens.google.com/uploadbyurl?url=${IMG_URL}"
    rm -f "$TMPFILE"
    exit 0
fi

# Fallback: try catbox.moe (permanent hosting)
IMG_URL=$(curl -s \
    -F "reqtype=fileupload" \
    -F "fileToUpload=@${TMPFILE}" \
    "https://catbox.moe/user/api.php" \
    --max-time 15 2>/dev/null)

if [ -n "$IMG_URL" ] && [[ "$IMG_URL" == http* ]]; then
    xdg-open "https://lens.google.com/uploadbyurl?url=${IMG_URL}"
    rm -f "$TMPFILE"
    exit 0
fi

# Fallback 2: try 0x0.st
IMG_URL=$(curl -s \
    -F "file=@${TMPFILE}" \
    "https://0x0.st" \
    --max-time 15 2>/dev/null)

if [ -n "$IMG_URL" ] && [[ "$IMG_URL" == http* ]]; then
    xdg-open "https://lens.google.com/uploadbyurl?url=${IMG_URL}"
    rm -f "$TMPFILE"
    exit 0
fi

# All uploads failed
rm -f "$TMPFILE"
notify-send -a "Google Lens" "Upload failed" "Could not upload image to any host. Check your internet connection." -i dialog-error
