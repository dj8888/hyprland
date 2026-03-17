#!/usr/bin/env bash
# List all Hyprland windows in wofi (class, title, workspace), focus selected. Alt+Tab.

set -euo pipefail

# Show: "class | title (truncated) | ws:N" then address at end for parsing (no special chars)
list="$(
  hyprctl clients -j | jq -r '.[]
    | .title as $t
    | .title = (if ($t | length) > 50 then ($t[0:47] + "...") else $t end)
    | "\(.class) | \(.title) | ws:\(.workspace.name // "?") | \(.address)"'
)"

if [ -z "$list" ]; then
  exit 0
fi

chosen="$(echo "$list" | wofi -i --dmenu -p "Switch to window")" || exit 0

# Address is 0x + hex at end of line (avoids invisible chars / font issues)
addr="$(echo "$chosen" | grep -oE '0x[0-9a-f]+$' || true)"
[ -n "$addr" ] && hyprctl dispatch focuswindow "address:$addr"
