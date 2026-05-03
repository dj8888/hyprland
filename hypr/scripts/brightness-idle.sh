#!/usr/bin/env sh

set -eu

STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/hypr"
# .cache is supposed to have temporary data. use .state for state or history ideally
STATE_FILE="$STATE_DIR/brightness-before-idle"
DIM_LEVEL="${DIM_LEVEL:-5}"
FALLBACK_RESTORE="${FALLBACK_RESTORE:-50}"

get_backlight_device() {
    for dev in /sys/class/backlight/*; do
        [ -d "$dev" ] && [ -r "$dev/brightness" ] && [ -r "$dev/max_brightness" ] && {
            printf '%s\n' "$dev"
            return 0
        }
    done
    return 1
}

get_current_brightness_percent() {
    dev="$(get_backlight_device)" || return 1
    current="$(cat "$dev/brightness")"
    max="$(cat "$dev/max_brightness")"
    [ "$max" -gt 0 ] || return 1
    # Round to nearest integer percent.
    printf '%s\n' $(( (current * 100 + max / 2) / max ))
}

save_current_percent() {
    mkdir -p "$STATE_DIR"
    percent="$(get_current_brightness_percent)" || return 1
    printf '%s\n' "$percent" > "$STATE_FILE"
}

dim() {
    save_current_percent || true
    swayosd-client --brightness "$DIM_LEVEL"
}

restore() {
    target="$FALLBACK_RESTORE"
    if [ -r "$STATE_FILE" ]; then
        saved="$(cat "$STATE_FILE" || true)"
        case "$saved" in
            ''|*[!0-9]*)
                ;;
            *)
                target="$saved"
                ;;
        esac
    fi
    swayosd-client --brightness "$target"
}

case "${1:-}" in
    dim)
        dim
        ;;
    restore)
        restore
        ;;
    *)
        echo "Usage: $0 {dim|restore}" >&2
        exit 1
        ;;
esac
