#!/bin/sh
# Toggle the wofi drun launcher: close it if open, otherwise open it.
if pgrep -x wofi >/dev/null; then
    pkill -x wofi
else
    wofi -i --show drun
fi
