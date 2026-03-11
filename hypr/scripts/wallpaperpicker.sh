#!/bin/bash

source "$HOME/.config/hypr/scripts/wallpaper_common.sh"

read_state

WALLPAPER_LIST=$(ls "$WALLPAPER_DIR")
CHOSEN=$(printf "SURPRISE ME!\n$WALLPAPER_LIST" | wofi -i --dmenu)

if [[ -z "$CHOSEN" ]]; then
    echo "No wallpaper selected."
    exit 1
fi

if [[ "$CHOSEN" == "SURPRISE ME!" ]]; then
    CHOSEN=$(shuf -n 1 <<< "$WALLPAPER_LIST")
fi

CHOSEN="$WALLPAPER_DIR/$CHOSEN"
TYPE=$(detect_type "$CHOSEN")
echo "Selected: $CHOSEN ($TYPE)"

if [[ "$TYPE" == "live" ]]; then
    apply_live "$CHOSEN"
    MODE="live"
    LIVE_WALLPAPER="$CHOSEN"
else
    apply_static "$CHOSEN"
    MODE="static"
    STATIC_WALLPAPER="$CHOSEN"
fi

write_state
