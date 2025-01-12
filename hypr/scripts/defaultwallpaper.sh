#!/bin/bash
DEFAULTWALL="/mnt/data/Wallpapers/ldrs01.png"

# Previous wallpaper file path (modify if needed)
PREVIOUS_WALLPAPER_FILE="$HOME/.config/hypr/previous_wallpaper"

echo "$PREVIOUS_WALLPAPER_FILE"
# Check if previous wallpaper file exists
if [ -f "$PREVIOUS_WALLPAPER_FILE" ]; then
  echo "Previous wallpaper file found."
  # Read the previous wallpaper path from the file
  PREVIOUS_WALLPAPER=$(< "$PREVIOUS_WALLPAPER_FILE")
  
  # Check if the previous wallpaper file has a file path (handle potential removal)
  if [ -f "$PREVIOUS_WALLPAPER" ]; then
    WALLPAPER="$PREVIOUS_WALLPAPER"
    echo "Loading previous wallpaper: $WALLPAPER"
  else
    echo "Previous wallpaper file exists but the wallpaper itself is missing. Using default wallpaper."
    WALLPAPER="$DEFAULTWALL"
  fi
else
  # No previous wallpaper file found, use default
  WALLPAPER="$DEFAULTWALL"
  echo "No previous wallpaper file found. Using default wallpaper."
fi

hyprctl dispatch exec hyprpaper
sleep 0.5
hyprctl hyprpaper unload all
hyprctl hyprpaper preload "$WALLPAPER"
hyprctl hyprpaper wallpaper ",$WALLPAPER"
