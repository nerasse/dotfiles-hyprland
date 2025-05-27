#!/usr/bin/env bash
# file_path: ~/.config/scripts/alttab/disabled.sh

# Envoyer Return au terminal alttab pour confirmer la sélection
hyprctl -q dispatch sendshortcut ,return,class:alttab

# Attendre un peu pour que la sélection soit traitée
sleep 0.05

# Fermer le terminal alttab
hyprctl -q dispatch closewindow class:alttab

# Réactiver les animations
hyprctl -q keyword animations:enabled true

# Réinitialiser le submap
hyprctl -q dispatch submap reset