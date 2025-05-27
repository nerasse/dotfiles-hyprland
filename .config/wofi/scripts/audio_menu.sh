#!/bin/bash
# filepath: ~/.config/wofi/scripts/audio_menu.sh

# Function to get audio output devices (sinks)
get_audio_sinks() {
    pactl list short sinks | awk '{print $2}'
}

# Function to get audio input devices (sources)
get_audio_sources() {
    pactl list short sources | awk '{print $2}' | grep -v ".monitor"
}

# Function to get the default sink
get_default_sink() {
    pactl info | grep "Default Sink" | cut -d: -f2 | xargs
}

# Function to get the default source
get_default_source() {
    pactl info | grep "Default Source" | cut -d: -f2 | xargs
}

# Function to set the default sink
set_default_sink() {
    local sink="$1"
    pactl set-default-sink "$sink"
    notify-send "Audio" "Default output changed to $sink" --icon=audio-speakers
}

# Function to set the default source
set_default_source() {
    local source="$1"
    pactl set-default-source "$source"
    notify-send "Audio" "Default input changed to $source" --icon=audio-input-microphone
}

# Function to adjust volume
adjust_volume() {
    local device="$1"
    local type="$2"  # sink or source
    
    # Show volume options
    local options="Set to 100%\nSet to 75%\nSet to 50%\nSet to 25%\nIncrease by 5%\nDecrease by 5%\n  Back"
    
    local selected=$(echo -e "$options" | wofi --dmenu -i -p "Volume for $device")
    
    local command=""
    case "$selected" in
        "Set to 100%")
            command="pactl set-$type-volume $device 100%"
            ;;
        "Set to 75%")
            command="pactl set-$type-volume $device 75%"
            ;;
        "Set to 50%")
            command="pactl set-$type-volume $device 50%"
            ;;
        "Set to 25%")
            command="pactl set-$type-volume $device 25%"
            ;;
        "Increase by 5%")
            command="pactl set-$type-volume $device +5%"
            ;;
        "Decrease by 5%")
            command="pactl set-$type-volume $device -5%"
            ;;
        "  Back")
            if [[ "$type" == "sink" ]]; then
                manage_audio_output
            else
                manage_audio_input
            fi
            return
            ;;
    esac
    
    # Execute the command
    if [[ -n "$command" ]]; then
        eval "$command"
        notify-send "Audio" "Volume for $device adjusted" --icon=audio-volume-high
    fi
}

# Function to toggle mute
toggle_mute() {
    local device="$1"
    local type="$2"  # sink or source
    
    pactl set-$type-mute "$device" toggle
    
    # Check if now muted
    local muted=$(pactl list $type"s" | grep -A 15 "Name: $device" | grep "Mute:" | awk '{print $2}')
    
    if [[ "$muted" == "yes" ]]; then
        notify-send "Audio" "$device is now muted" --icon=audio-volume-muted
    else
        notify-send "Audio" "$device is now unmuted" --icon=audio-volume-high
    fi
}

# Function to manage audio output
manage_audio_output() {
    # Get current default sink
    local default_sink=$(get_default_sink)
    
    # Get all sinks
    local sinks=$(get_audio_sinks)
    
    if [[ -z "$sinks" ]]; then
        notify-send "Audio" "No audio output devices found" --icon=dialog-error
        return
    fi
    
    # Prepare menu options
    local options=""
    options+="Default Output: $default_sink\n"
    options+="Adjust Volume for $default_sink\n"
    options+="Toggle Mute for $default_sink\n"
    options+="Change Default Output\n"
    options+="  Back"
    
    # Show menu
    local selected=$(echo -e "$options" | wofi --dmenu -i -p "Audio Output")
    
    # Process selection
    if [[ "$selected" == "Adjust Volume for $default_sink" ]]; then
        adjust_volume "$default_sink" "sink"
    elif [[ "$selected" == "Toggle Mute for $default_sink" ]]; then
        toggle_mute "$default_sink" "sink"
    elif [[ "$selected" == "Change Default Output" ]]; then
        # Create menu options with all sinks
        local sink_options=""
        for sink in $sinks; do
            sink_options+="$sink\n"
        done
        sink_options+="  Back"
        
        # Show sink selection menu
        local selected_sink=$(echo -e "$sink_options" | wofi --dmenu -i -p "Select Output Device")
        
        if [[ "$selected_sink" != "  Back" && -n "$selected_sink" ]]; then
            set_default_sink "$selected_sink"
        fi
        
        # Return to output management
        manage_audio_output
    elif [[ "$selected" == "  Back" ]]; then
        audio_menu
    fi
}

# Function to manage audio input
manage_audio_input() {
    # Get current default source
    local default_source=$(get_default_source)
    
    # Get all sources (excluding monitor sources)
    local sources=$(get_audio_sources)
    
    if [[ -z "$sources" ]]; then
        notify-send "Audio" "No audio input devices found" --icon=dialog-error
        return
    fi
    
    # Prepare menu options
    local options=""
    options+="Default Input: $default_source\n"
    options+="Adjust Volume for $default_source\n"
    options+="Toggle Mute for $default_source\n"
    options+="Change Default Input\n"
    options+="  Back"
    
    # Show menu
    local selected=$(echo -e "$options" | wofi --dmenu -i -p "Audio Input")
    
    # Process selection
    if [[ "$selected" == "Adjust Volume for $default_source" ]]; then
        adjust_volume "$default_source" "source"
    elif [[ "$selected" == "Toggle Mute for $default_source" ]]; then
        toggle_mute "$default_source" "source"
    elif [[ "$selected" == "Change Default Input" ]]; then
        # Create menu options with all sources
        local source_options=""
        for source in $sources; do
            source_options+="$source\n"
        done
        source_options+="  Back"
        
        # Show source selection menu
        local selected_source=$(echo -e "$source_options" | wofi --dmenu -i -p "Select Input Device")
        
        if [[ "$selected_source" != "  Back" && -n "$selected_source" ]]; then
            set_default_source "$selected_source"
        fi
        
        # Return to input management
        manage_audio_input
    elif [[ "$selected" == "  Back" ]]; then
        audio_menu
    fi
}

# Main audio menu function
audio_menu() {
    local options="Manage Audio Output\nManage Audio Input\n  Back"
    
    local selected=$(echo -e "$options" | wofi --dmenu -i -p "Audio Menu")
    
    case "$selected" in
        "Manage Audio Output")
            manage_audio_output ;;
        "Manage Audio Input")
            manage_audio_input ;;
        "  Back")
            ~/.config/wofi/scripts/menu_launcher.sh ;;
    esac
}

# Run the audio menu
audio_menu