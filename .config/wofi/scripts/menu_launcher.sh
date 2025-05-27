#!/bin/sh
# filepath: ~/.config/wofi/scripts/menu_launcher.sh

# Icons:
#   Power Profile Management (Bolt)
#   Audio Settings (Audio icon)
#   WiFi Settings (WiFi icon)
# 🌅  HyprSunset Control (Sunset/Sunrise icon - new)
#   Power Menu (Power icon)
# 󰜺  Cancel (Cancel icon)

chosen=$(printf "  Power Profile Management\n  Audio Settings\n  WiFi Settings\n  HyprSunset Control\n󰔎  GTK Theme\n  Power Menu\n󰜺  Cancel" | wofi --dmenu -p "Select Menu:")

case "$chosen" in
  "  Power Profile Management")
    ~/.config/wofi/scripts/power_management_menu.sh ;;
  "  Audio Settings")
    ~/.config/wofi/scripts/audio_menu.sh ;;
  "  WiFi Settings")
    ~/.config/wofi/scripts/wifi_menu.sh ;;
  "  HyprSunset Control")
    ~/.config/wofi/scripts/hyprsunset_menu.sh ;;
  "󰔎  GTK Theme")
    nwg-look ;;
  "  Power Menu")
    ~/.config/wofi/scripts/power_menu.sh ;;
  "󰜺  Cancel")
    exit 0 ;;
  *) # Handles Escape key or closing Wofi without selection
    exit 0 ;;
esac