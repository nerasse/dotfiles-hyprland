#!/usr/bin/env bash
# file_path: ~/.config/scripts/alttab/alttab.sh

# Couleurs Catppuccin Macchiato
# Base: #24273a, Mantle: #1e2030, Surface0: #363a4f
# Text: #cad3f5, Subtext1: #b8c0e0, Subtext0: #a5adcb
# Mauve: #c6a0f6, Pink: #f5bde6, Red: #ed8796
# Green: #a6da95, Blue: #8aadf4, Yellow: #eed49f

address=$(hyprctl -j clients | jq -r 'sort_by(.focusHistoryID) | .[] | select(.workspace.id >= 0) | "\(.address)\t\(.title)"' |
    fzf --color="bg:#24273a,bg+:#363a4f,fg:#cad3f5,fg+:#cad3f5" \
        --color="hl:#c6a0f6,hl+:#c6a0f6,info:#8aadf4,marker:#a6da95" \
        --color="prompt:#c6a0f6,spinner:#f5bde6,pointer:#c6a0f6" \
        --color="header:#ed8796,border:#5b6078,gutter:#24273a" \
        --border="rounded" \
        --border-label="   Alt+Tab Switcher " \
        --border-label-pos="2" \
        --margin="1" \
        --prompt="❯ " \
        --pointer="▶ " \
        --marker="● " \
        --cycle \
        --sync \
        --bind tab:down,shift-tab:up,start:down,double-click:ignore \
        --wrap \
        --delimiter=$'\t' \
        --with-nth=2 \
        --preview "$XDG_CONFIG_HOME/scripts/alttab/preview.sh {}" \
        --preview-window="down:80%:border-rounded" \
        --preview-label="   Preview " \
        --preview-label-pos="2" \
        --layout=reverse |
    awk -F"\t" '{print $1}')

if [ -n "$address" ] ; then
    hyprctl --batch -q "dispatch focuswindow address:$address;dispatch alterzorder top"
fi