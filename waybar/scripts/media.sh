#!/bin/sh
# Drives waybar's custom/media module: polls the active MPRIS player via
# playerctld and emits JSON lines (return-type: json).
#
# - Only shows anything while a player is actually "Playing" (paused/stopped
#   clears the text so waybar hides the module via hide-empty-text).
# - Long titles scroll as a marquee instead of being cut off.
# - A tiny text equaliser (bar glyphs) animates in place of a CSS flash.

interval=0.3
width=28
sep="   •   "
seplen=${#sep}

frame=0
offset=0
prev_label=""

eq_frame() {
    case $(( frame % 4 )) in
        0) printf '%s' '▁▃▅▂' ;;
        1) printf '%s' '▃▅▂▇' ;;
        2) printf '%s' '▅▂▇▃' ;;
        3) printf '%s' '▂▇▃▅' ;;
    esac
}

while true; do
    line=$(playerctl -p playerctld metadata --format '{{status}}	{{artist}}	{{title}}' 2>/dev/null)
    status=$(printf '%s' "$line" | cut -f1)
    artist=$(printf '%s' "$line" | cut -f2)
    title=$(printf '%s' "$line" | cut -f3)

    if [ "$status" = "Playing" ]; then
        if [ -n "$artist" ]; then
            label="$artist - $title"
        else
            label="$title"
        fi

        if [ "$label" != "$prev_label" ]; then
            offset=0
            prev_label="$label"
        fi

        len=${#label}
        if [ "$len" -gt "$width" ]; then
            loop="${label}${sep}"
            looplen=$((len + seplen))
            doubled="${loop}${loop}"
            win="${doubled:$offset:$width}"
            offset=$(( (offset + 1) % looplen ))
        else
            win="$label"
        fi

        frame=$((frame + 1))
        jq -nc --arg text "$(eq_frame)  $win" --arg tooltip "$label" \
            '{text: $text, class: "playing", tooltip: $tooltip}'
    else
        prev_label=""
        offset=0
        frame=0
        jq -nc --arg status "${status:-Stopped}" '{text: "", class: $status, tooltip: ""}'
    fi

    sleep "$interval"
done
