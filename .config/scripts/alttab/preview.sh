# file_path: ~/.config/scripts/alttab/preview.sh

#!/usr/bin/env bash
line="$1"

IFS=$'\t' read -r addr _ <<< "$line"
dim=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}

# need https://github.com/eriedaberrie/grim-hyprland at ~/builds/grim-hyprland and build it
~/builds/grim-hyprland/build/grim -t png -l 0 -w "$addr" ~/.config/scripts/alttab/preview.png
chafa --animate false -s "$dim" "$XDG_CONFIG_HOME/scripts/alttab/preview.png"