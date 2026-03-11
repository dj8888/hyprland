#!/bin/bash

source "$HOME/.config/hypr/scripts/wallpaper_common.sh"

read_state

if [[ "$MODE" == "live" ]]; then
    echo "Switching to static wallpaper: $STATIC_WALLPAPER"
    apply_static "$STATIC_WALLPAPER"
    MODE="static"
else
    echo "Switching to live wallpaper: $LIVE_WALLPAPER"
    apply_live "$LIVE_WALLPAPER"
    MODE="live"
fi

write_state
