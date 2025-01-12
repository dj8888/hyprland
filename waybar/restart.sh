#!/bin/sh

killall waybar
pkill waybar
sleep 0.5

if [[ $USER = "devansh" ]]
then
    waybar -c ~/.config/waybar/config.jsonc & -s ~/.config/waybar/style.css
else
    waybar &
fi
