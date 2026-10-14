#!/bin/sh
# Drives the small prev/playpause/next buttons next to the media.sh track
# label. Usage: media-ctl.sh prev|playpause|next
role="$1"
interval=1

# Font Awesome Free Solid glyphs, written as raw UTF-8 byte escapes since
# literal private-use-area characters get stripped by some editors/tools.
icon_prev=$(printf '\xef\x81\x88')      # f048 backward-step
icon_play=$(printf '\xef\x81\x8b')      # f04b play
icon_pause=$(printf '\xef\x81\x8c')     # f04c pause
icon_next=$(printf '\xef\x81\x91')      # f051 forward-step

while true; do
    status=$(playerctl -p playerctld status 2>/dev/null)
    if [ -n "$status" ]; then
        case "$role" in
            prev) text="$icon_prev" ;;
            next) text="$icon_next" ;;
            playpause)
                if [ "$status" = "Playing" ]; then
                    text="$icon_pause"
                else
                    text="$icon_play"
                fi
                ;;
        esac
        jq -nc --arg text "$text" --arg status "$status" \
            '{text: $text, class: $status, tooltip: ""}'
    else
        jq -nc '{text: "", class: "none", tooltip: ""}'
    fi
    sleep "$interval"
done
