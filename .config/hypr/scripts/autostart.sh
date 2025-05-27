#!/bin/bash

# Mettre à jour l'environnement d'activation D-Bus
systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DBUS_SESSION_BUS_ADDRESS
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DBUS_SESSION_BUS_ADDRESS

# Pour définir un premier fond d'écran aléatoire au démarrage
# ~/.config/scripts/random_wallpaper_swww.sh & 

# notif
mako &

waybar &

# network manager
nm-applet --indicator &

# bt
blueman-applet &

# smart borders
~/.config/hypr/scripts/smart_borders.sh &

# agent LXQt
/usr/bin/lxqt-policykit-agent &

# enable power management
systemctl --user start power-profiles-daemon.service

# xsettingsd themes
xsettingsd &

# Store text data
wl-paste --type text --watch cliphist store &
# Store image data
wl-paste --type image --watch cliphist store &

foot --server &

# idle time out
hypridle

nextcloud &