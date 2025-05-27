#!/bin/bash
# file_path: ~/.config/scripts/screenshot.sh

# Unified screenshot script for Hyprland
# Dependencies: grim, slurp, swappy, wl-clipboard, libnotify (for notify-send), zenity

MODE=$1
NOTIFICATION_TITLE="📸 ˚⋆｡˖ Screenshot"
ZENITY_TITLE="📸 ˚⋆｡˖ Screenshot Tool"

if [[ -z "$MODE" ]]; then
    echo "Error: No mode specified."
    echo "Usage: $0 [area_edit | area_clipboard | area_save | full_edit | full_clipboard]"
    exit 1
fi

case "$MODE" in
    area_edit)
        # Select an area and open in Swappy
        grim -g "$(slurp -d)" - | swappy -f -
        ;;
    area_clipboard)
        # Select an area and copy to clipboard
        SELECTION=$(slurp -d)
        if [ -z "$SELECTION" ]; then
            notify-send "$NOTIFICATION_TITLE" "Area selection cancelled."
            exit 0
        fi
        if grim -g "$SELECTION" - | wl-copy --type image/png; then
            notify-send "$NOTIFICATION_TITLE" "Selected area copied to clipboard."
        else
            notify-send -u critical "$NOTIFICATION_TITLE" "Failed to copy selected area to clipboard."
        fi
        ;;
    area_save)
        # Select an area, edit in Swappy, then choose save location
        SELECTION=$(slurp -d)
        if [ -z "$SELECTION" ]; then
            notify-send "$NOTIFICATION_TITLE" "Area selection cancelled."
            exit 0
        fi
        
        # Ask user where to save with zenity
        SAVE_PATH=$(zenity --file-selection \
            --save \
            --title="$ZENITY_TITLE - Where do you want to save the screenshot?" \
            --filename="Screenshot-$(date +%Y-%m-%d_%H-%M-%S).png" \
            --file-filter="PNG Images | *.png")
        
        # Cancel if user closes the dialog
        if [[ -z "$SAVE_PATH" ]]; then
            notify-send "$NOTIFICATION_TITLE" "Save cancelled: no path selected."
            exit 1
        fi

        sleep 0.1
        
        # Take screenshot, edit in Swappy, and save to chosen path
        if grim -g "$SELECTION" - | swappy -f - -o "$SAVE_PATH"; then
            notify-send "$NOTIFICATION_TITLE" "Screenshot edited and saved to: $SAVE_PATH"
        else
            notify-send -u critical "$NOTIFICATION_TITLE" "Failed to save screenshot."
        fi
        ;;
    full_clipboard)
        # Capture the entire screen and copy to clipboard
        if grim - | wl-copy --type image/png; then
            notify-send "$NOTIFICATION_TITLE" "Full screen copied to clipboard."
        else
            notify-send -u critical "$NOTIFICATION_TITLE" "Failed to copy full screen to clipboard."
        fi
        ;;
    full_edit)
        # Capture the entire screen and open in Swappy
        grim - | swappy -f -
        ;;
    *)
        echo "Error: Invalid mode '$MODE'."
        echo "Available modes: area_edit, area_clipboard, area_save, full_edit, full_clipboard"
        exit 1
        ;;
esac