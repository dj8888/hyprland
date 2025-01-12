#!/bin/bash

# Path to your wallpaper directory
WALLPAPER_DIR="/mnt/data/Wallpapers/" 

# Pipe files in wofi to choose one
CHOOSEN=$(ls "$WALLPAPER_DIR" | wofi --dmenu)

# Quit if nothing is choosen
if [ -z "$CHOOSEN" ]; then
    echo "No wallpaper selected."
    exit 1
fi

CHOOSEN="$WALLPAPER_DIR$CHOOSEN" #Full path to file
echo "$CHOOSEN"

if ! hyprctl hyprpaper preload "$WALLPAPER_DIR/temp.jpg" &> /dev/null; then
  echo "Hyprpaper might not be running. Starting hyprpaper..."
  hyprctl dispatch exec hyprpaper
  sleep 0.5
fi

hyprctl hyprpaper unload all
hyprctl hyprpaper preload "$CHOOSEN"
hyprctl hyprpaper wallpaper ",$CHOOSEN"

PREVIOUS_WALLPAPER_FILE="$HOME/.config/hypr/previous_wallpaper"
echo "Updating previous wallpaper..."
echo "$CHOOSEN" > "$PREVIOUS_WALLPAPER_FILE"
