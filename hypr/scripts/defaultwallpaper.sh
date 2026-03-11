#!/bin/bash

source "$HOME/.config/hypr/scripts/wallpaper_common.sh"

read_state

if [[ "$MODE" == "live" ]]; then
    echo "Restoring live wallpaper: $LIVE_WALLPAPER"
    apply_live "$LIVE_WALLPAPER"
else
    echo "Restoring static wallpaper: $STATIC_WALLPAPER"
    apply_static "$STATIC_WALLPAPER"
fi
