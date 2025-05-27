#!/bin/bash
# filepath: ~/.config/wofi/scripts/hyprsunset_control_menu.sh

# Main HyprSunset menu function
hyprsunset_menu() {
    while true; do

        local options=""
        options+="🌙 Enable Blue-Light Filter (2500K)\n"  # Stays in menu
        options+="🌙 Disable Blue-Light Filter\n"         # Exits menu (NEW)
        options+="🔆 Set Gamma to 50%\n"                  # Stays in menu
        options+="🔆 ➕ Increase Gamma by 10%\n"             # Stays in menu
        options+="🔆 ➖ Decrease Gamma by 10%\n"             # Stays in menu
        options+="🔄 Reset Temperature & Gamma\n"       # Exits menu
        options+="  Back\n"                               # Exits menu
        options+="󰜺  Cancel"                               # Exits menu

        # Display Wofi menu
        local selected
        selected=$(echo -e "$options" | wofi --dmenu -i -p "HyprSunset Control")
        local wofi_exit_code=$? # Get Wofi's exit code

        # Process selection
        case "$selected" in
            "🌙 Enable Blue-Light Filter (2500K)")
                hyprctl hyprsunset temperature 2500
                notify-send "HyprSunset" "Blue-light filter enabled (2500K)." --icon=display-brightness # or weather-clear-night
                # Loop continues, menu reappears
                ;;
            "🌙 Disable Blue-Light Filter") # NEW OPTION
                hyprctl hyprsunset identity
                notify-send "HyprSunset" "Blue-light filter disabled (Temperature & Gamma reset)." --icon=display-brightness
                break # Exit while loop, script terminates
                ;;
            "🔆 Set Gamma to 50%")
                hyprctl hyprsunset gamma 50
                notify-send "HyprSunset" "Gamma set to 50%." --icon=display-brightness
                # Loop continues, menu reappears
                ;;
            "🔆 ➕ Increase Gamma by 10%")
                hyprctl hyprsunset gamma +10
                notify-send "HyprSunset" "Gamma increased by 10%." --icon=display-brightness
                # Loop continues, menu reappears
                ;;
            "🔆 ➖ Decrease Gamma by 10%")
                hyprctl hyprsunset gamma -10
                notify-send "HyprSunset" "Gamma decreased by 10%." --icon=display-brightness
                # Loop continues, menu reappears
                ;;
            "🔄 Reset Temperature & Gamma")
                hyprctl hyprsunset identity
                notify-send "HyprSunset" "Temperature and Gamma reset." --icon=display-brightness
                break # Exit while loop, script terminates
                ;;
            "  Back")
                # Execute the menu_launcher.sh script as requested
                ~/.config/wofi/scripts/menu_launcher.sh
                exit 0 # Exit this script completely
                ;;
            "󰜺  Cancel")
                # Do nothing, Wofi closes if user selects "Cancel"
                exit 0 # Exit this script completely
                ;;
            *)
                # Handle Escape key press or Wofi closure without selection
                if [[ -z "$selected" && $wofi_exit_code -ne 0 ]]; then
                    exit 0 # Exit cleanly on Escape
                elif [[ -z "$selected" ]]; then
                    exit 0 # Exit cleanly if Wofi returns empty string on Escape/Cancel
                fi
                exit 1 # Error or unhandled cancellation
                ;;
        esac
    done
}

# Run the main menu function
hyprsunset_menu