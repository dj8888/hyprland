#!/bin/bash

curr=$(asusctl profile -p | cut --delimiter " " --fields 4 | tr -d '\n')
echo "Current Profile: $curr"

if [ "$curr" = "Balanced" ]; then
  change_to="performance"
  # governor="performance"
elif [ "$curr" = "Performance" ]; then
  change_to="quiet"
else
  change_to="balanced"
  # governor="reset"
fi

echo "Changing to: ${change_to^}"
notify-send "Switching to profile:" "${change_to^}"

asusctl profile -P $change_to
#sudo auto-cpufreq --force $governor
