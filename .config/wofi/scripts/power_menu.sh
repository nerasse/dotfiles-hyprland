#!/bin/sh
# filepath: ~/.config/wofi/scripts/power_menu.sh

chosen=$(printf " Power Off\n Restart\n󰒲 Hibernate\n Lock\n Log Out\n Sleep\n  Back\n󰜺 Cancel" | wofi --dmenu -p "Power Menu:")

case "$chosen" in

  " Power Off")
    systemctl poweroff ;;

  " Restart")
    systemctl reboot ;;

  "󰒲 Hibernate")
    systemctl hibernate ;;

  " Lock")
    ~/.config/hypr/scripts/hyprlock-custom.sh ;;

  " Log Out")
    hyprctl dispatch exit ;;

  " Sleep")
    systemctl suspend ;;

  "  Back")
    ~/.config/wofi/scripts/menu_launcher.sh ;;
    
  "󰜺 Cancel")
    exit 0 ;;
  *)
    exit 0 ;;
esac