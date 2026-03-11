#!/bin/bash

STATE_FILE="$HOME/.config/hypr/wallpaper_state"
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
PREVIOUS_WALLPAPER_LINK="$HOME/.config/hypr/previous_wallpaper"

DEFAULT_STATIC="/mnt/data/Wallpapers/ldrs01.png"
DEFAULT_LIVE="$HOME/Pictures/wallpapers/fireplace.gif"

LIVE_EXT_PATTERN="^(gif|mp4|webm|mkv|avi|mov)$"

detect_type() {
    local ext="${1##*.}"
    ext="${ext,,}"
    if [[ "$ext" =~ $LIVE_EXT_PATTERN ]]; then
        echo "live"
    else
        echo "static"
    fi
}

read_state() {
    MODE="static"
    STATIC_WALLPAPER="$DEFAULT_STATIC"
    LIVE_WALLPAPER="$DEFAULT_LIVE"
    [[ -f "$STATE_FILE" ]] && source "$STATE_FILE"
}

write_state() {
    cat > "$STATE_FILE" <<EOF
MODE=$MODE
STATIC_WALLPAPER=$STATIC_WALLPAPER
LIVE_WALLPAPER=$LIVE_WALLPAPER
EOF
}

apply_static() {
    local wallpaper="$1"

    pkill -x mpvpaper 2>/dev/null
    sleep 0.2

    if ! pgrep -x hyprpaper &>/dev/null; then
        hyprctl dispatch exec hyprpaper
        sleep 1
    fi

    hyprctl hyprpaper unload all
    hyprctl hyprpaper preload "$wallpaper"
    hyprctl hyprpaper wallpaper ",$wallpaper"

    rm -f "$PREVIOUS_WALLPAPER_LINK"
    ln -s "$wallpaper" "$PREVIOUS_WALLPAPER_LINK"
}

apply_live() {
    local wallpaper="$1"

    pkill -x hyprpaper 2>/dev/null
    pkill -x mpvpaper 2>/dev/null
    sleep 0.3

    local monitors
    monitors=$(hyprctl monitors -j | jq -r '.[].name')
    for mon in $monitors; do
        mpvpaper -o "no-audio loop hwdec=auto --panscan=1.0" "$mon" "$wallpaper" &
    done
}
