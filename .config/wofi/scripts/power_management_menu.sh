#!/bin/sh
# filepath: ~/.config/wofi/scripts/power_management_menu.sh

chosen=$(printf "🎮 Gaming Mode (NVIDIA + Performance)\n💻 Power Desktop (AMD + Performance)\n🚀 Hybrid Performance (Hybrid + Performance)\n󰾲  GPU Balanced (NVIDIA + Balanced)\n⚖️ Perfectly Balanced (Hybrid + Balanced)\n📊 GPU Eco (AMD + Balanced)\n🍃 Full Eco Mode (AMD + Power Saver)\n  Back\n󰜺 Cancel" | wofi --dmenu -p "Power Management:")

case "$chosen" in
  "🎮 Gaming Mode (NVIDIA + Performance)")
    powerprofilesctl set performance
    optimus-manager --switch nvidia
    notify-send "Power Mode" "Gaming Mode: NVIDIA GPU + Performance Profile" ;;
    
  "💻 Power Desktop (AMD + Performance)")
    powerprofilesctl set performance
    optimus-manager --switch integrated
    notify-send "Power Mode" "Power Desktop: AMD GPU + Performance Profile" ;;

  "🚀 Hybrid Performance (Hybrid + Performance)")
    powerprofilesctl set performance
    optimus-manager --switch hybrid
    notify-send "Power Mode" "Hybrid Performance: Hybrid GPU + Performance Profile" ;;
    
  "󰾲  GPU Balanced (NVIDIA + Balanced)")
    powerprofilesctl set balanced
    optimus-manager --switch nvidia
    notify-send "Power Mode" "GPU Balanced: NVIDIA GPU + Balanced Profile" ;;
    
  "⚖️ Perfectly Balanced (Hybrid + Balanced)")
    powerprofilesctl set balanced
    optimus-manager --switch hybrid
    notify-send "Power Mode" "Perfectly Balanced: Hybrid GPU + Balanced Profile" ;;
    
  "📊 GPU Eco (AMD + Balanced)")
    powerprofilesctl set balanced
    optimus-manager --switch integrated
    notify-send "Power Mode" "GPU Eco: AMD GPU + Balanced Profile" ;;
    
  "🍃 Full Eco Mode (AMD + Power Saver)")
    powerprofilesctl set power-saver
    optimus-manager --switch integrated
    notify-send "Power Mode" "Full Eco Mode: AMD GPU + Power Saver Profile" ;;

  "  Back")
    ~/.config/wofi/scripts/menu_launcher.sh ;;
    
  "󰜺 Cancel")
    exit 0 ;;
    
  *)
    exit 0 ;;
esac