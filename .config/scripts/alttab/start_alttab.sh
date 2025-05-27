#!/bin/bash
# file_path: ~/.config/scripts/alttab/start_alttab.sh

echo "[$(date)] start_alttab.sh: SCRIPT STARTED" >> /tmp/alttab_debug.log

# S'assurer qu'aucun terminal alttab n'est déjà ouvert
hyprctl -q dispatch closewindow class:alttab

# Désactiver les animations
hyprctl -q keyword animations:enabled false

# Lancer le nouveau terminal alttab
hyprctl -q dispatch exec "footclient -a alttab $XDG_CONFIG_HOME/scripts/alttab/alttab.sh"

# Focus sur le terminal alttab
hyprctl -q dispatch focuswindow class:alttab

# Entrer dans le submap alttab
hyprctl -q dispatch submap alttab