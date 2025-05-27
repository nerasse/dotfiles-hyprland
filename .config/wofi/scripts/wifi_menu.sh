#!/bin/bash
# filepath: ~/.config/wofi/scripts/wifi_menu.sh

# Function to show a loading indicator while a command executes
# Parameters:
#   $1 - Message to display during loading
#   $2 - Command to execute (as a string)
#   $3 - Title (optional)
show_with_loading() {
    local message="$1"
    local command_to_execute="$2" # Renamed to avoid conflict with 'command' builtin
    local title="${3:-Loading...}"
    
    # Show loading notification immediately
    local loading_id=$(notify-send "$title" "$message..." --print-id --urgency=low --icon=network-transmit-receive)
    
    # Execute the command and capture output
    local result=$(eval "$command_to_execute")
    local status=$?
    
    # Remove the loading notification
    if [[ -n "$loading_id" ]]; then
        # Attempt to close notification, but don't fail if it's already gone
        notify-send --replace-id="$loading_id" --close-notification &>/dev/null || true
    fi
    
    # Return the result and status
    echo "$result"
    return $status
}

# Function to get available WiFi networks
get_wifi_networks() {
    # Get a list of available networks, sorted by signal strength
    nmcli -f SSID,SIGNAL,SECURITY device wifi list | tail -n +2 | 
        sort -k2 -nr | awk '{print $1 " (" $2 "%) [" $3 "]"}' | 
        sed 's/  / /g' | uniq
}

# Function to get saved WiFi networks
get_saved_networks() {
    # Get a list of saved WiFi connections
    nmcli -t -f NAME,TYPE connection show | grep 'wireless' | cut -d ':' -f 1
}

# Function to check if WiFi is enabled
is_wifi_enabled() {
    nmcli radio wifi | grep -q "enabled"
    return $?
}

# Function to toggle WiFi state
toggle_wifi() {
    local current_state=$(nmcli radio wifi)
    
    if [[ "$current_state" == "enabled" ]]; then
        show_with_loading "Turning WiFi off" "nmcli radio wifi off" "WiFi"
        notify-send "WiFi Status" "WiFi has been disabled" --icon=network-wireless-disabled
    else
        show_with_loading "Turning WiFi on" "nmcli radio wifi on" "WiFi"
        notify-send "WiFi Status" "WiFi has been enabled" --icon=network-wireless
    fi
}

# Function to connect to a WiFi network
connect_to_network() {
    local selected_network="$1"
    local ssid=$(echo "$selected_network" | awk '{print $1}')
    
    # Check if network is already known
    if nmcli -t -f NAME connection show | grep -q "^$ssid$"; then
        show_with_loading "Connecting to $ssid" "nmcli connection up \"$ssid\"" "WiFi"
        
        if [ $? -eq 0 ]; then
            notify-send "WiFi" "Connected to $ssid" --icon=network-wireless
        else
            notify-send "WiFi Error" "Failed to connect to $ssid" --icon=dialog-error
        fi
    else
        # Network is not known, ask for password
        password=$(wofi --dmenu -p "Enter password for $ssid" -P -L 0)
        
        if [ -n "$password" ]; then
            show_with_loading "Connecting to $ssid" "nmcli device wifi connect \"$ssid\" password \"$password\"" "WiFi"
            
            if [ $? -eq 0 ]; then
                notify-send "WiFi" "Connected to $ssid" --icon=network-wireless
            else
                notify-send "WiFi Error" "Failed to connect to $ssid. Check password." --icon=dialog-error
            fi
        else
            notify-send "WiFi" "Connection cancelled" --icon=dialog-warning
        fi
    fi
}

# Function to show current connection status
show_wifi_status() {
    # Get connection info and detect WiFi interface name
    local status_line=$(nmcli -t -f DEVICE,STATE,CONNECTION device status | grep -E "^wlan|^wl")
    
    if [[ -z "$status_line" ]]; then
        # Create a message list for wofi
        echo -e "No WiFi adapter found or not active.\n  Back" | wofi --dmenu -i -p "WiFi Status"
        wifi_menu
        return
    fi
    
    local interface=$(echo "$status_line" | cut -d':' -f1)
    local state=$(echo "$status_line" | cut -d':' -f2)
    local connection=$(echo "$status_line" | cut -d':' -f3)
    
    local ip_address=$(ip -4 addr show dev "$interface" 2>/dev/null | grep -oP 'inet \K[\d.]+')
    
    local content=""
    
    if [[ "$state" == "connected" ]]; then
        local signal=$(nmcli -t -f IN-USE,SIGNAL device wifi list ifname "$interface" | grep "^\*:" | cut -d':' -f2)
        content+="Connected to: $connection\n"
        content+="Signal: $signal%\n"
        
        if [[ -n "$ip_address" ]]; then
            content+="IP Address: $ip_address\n"
        fi
    else
        content+="WiFi is $state on $interface\n"
    fi
    
    content+="  Back"
    selected_action=$(echo -e "$content" | wofi --dmenu -i -p "WiFi Status")
    
    if [[ "$selected_action" == "  Back" ]] || [[ -z "$selected_action" ]]; then
        wifi_menu
    fi
}

# Function to show available networks and connect to selected one
show_available_networks() {
    notify-send "WiFi" "Scanning for networks..." --urgency=low --icon=network-wireless-acquiring
    
    nmcli device wifi rescan &>/dev/null
    sleep 1 # Give it a moment to scan
    
    local networks=$(get_wifi_networks)
    
    if [[ -z "$networks" ]]; then
        echo -e "No WiFi networks found.\n  Back" | wofi --dmenu -i -p "Available Networks"
        wifi_menu
        return
    fi
    
    local options="$networks\n  Back"
    local selected=$(echo -e "$options" | wofi --dmenu -i -p "Available Networks")
    
    if [[ "$selected" == "  Back" ]] || [[ -z "$selected" ]]; then
        wifi_menu
        return
    fi
    
    if [[ -n "$selected" ]]; then
        connect_to_network "$selected"
    fi
}

# Function to manage saved networks
manage_saved_networks() {
    notify-send "WiFi" "Loading saved networks..." --urgency=low --icon=document-open-recent
    
    local saved_networks=$(get_saved_networks)
    
    if [[ -z "$saved_networks" ]]; then
         echo -e "No saved WiFi networks.\n  Back" | wofi --dmenu -i -p "Manage Saved Networks"
        wifi_menu
        return
    fi
    
    local options="$saved_networks\n  Back"
    local selected=$(echo -e "$options" | wofi --dmenu -i -p "Manage Saved Networks")

    if [[ "$selected" == "  Back" ]] || [[ -z "$selected" ]]; then
        wifi_menu
        return
    fi
    
    if [[ -n "$selected" ]]; then
        local network="$selected"
        local auto_connect=$(nmcli -t -g connection.autoconnect connection show "$network" 2>/dev/null)
        local auto_connect_option
        
        if [[ "$auto_connect" == "yes" ]]; then
            auto_connect_option="Disable Auto-Connect"
        else
            auto_connect_option="Enable Auto-Connect"
        fi
        
        local network_options_str="Connect to $network\n$auto_connect_option\nForget $network\n  Back"
        local action=$(echo -e "$network_options_str" | wofi --dmenu -i -p "$network")
        
        if [[ "$action" == "  Back" ]] || [[ -z "$action" ]]; then
            manage_saved_networks # Go back to saved networks list
            return
        fi
        
        case "$action" in
            "Connect to $network")
                show_with_loading "Connecting to $network" "nmcli connection up \"$network\"" "WiFi"
                [ $? -eq 0 ] && notify-send "WiFi" "Connected to $network" --icon=network-wireless || notify-send "WiFi Error" "Failed to connect to $network" --icon=dialog-error
                ;;
            "Enable Auto-Connect")
                show_with_loading "Enabling auto-connect for $network" "nmcli connection modify \"$network\" connection.autoconnect yes" "WiFi"
                [ $? -eq 0 ] && notify-send "WiFi" "Auto-connect enabled for $network" --icon=dialog-information || notify-send "WiFi Error" "Failed to enable auto-connect" --icon=dialog-error
                ;;
            "Disable Auto-Connect")
                show_with_loading "Disabling auto-connect for $network" "nmcli connection modify \"$network\" connection.autoconnect no" "WiFi"
                [ $? -eq 0 ] && notify-send "WiFi" "Auto-connect disabled for $network" --icon=dialog-information || notify-send "WiFi Error" "Failed to disable auto-connect" --icon=dialog-error
                ;;
            "Forget $network")
                local confirm_options="Yes\nNo\n  Back"
                local confirm=$(echo -e "$confirm_options" | wofi --dmenu -i -p "Forget $network?")
                
                if [[ "$confirm" == "Yes" ]]; then
                    show_with_loading "Forgetting network $network" "nmcli connection delete \"$network\"" "WiFi"
                    [ $? -eq 0 ] && notify-send "WiFi" "Network $network forgotten" --icon=dialog-information || notify-send "WiFi Error" "Failed to forget network" --icon=dialog-error
                elif [[ "$confirm" == "  Back" ]]; then
                    # This should take back to the specific network's options.
                    # For simplicity here, we'll just refresh manage_saved_networks if user backs out from confirm.
                    manage_saved_networks
                    return
                fi
                ;;
        esac
    fi
}

# Function to restart NetworkManager service
restart_network_manager() {
    show_with_loading "Restarting NetworkManager" "sudo systemctl restart NetworkManager.service" "Network Services"
    
    if [ $? -eq 0 ]; then
        notify-send "Network Services" "NetworkManager has been restarted successfully" --icon=dialog-information
        sleep 2
    else
        notify-send "Network Error" "Failed to restart NetworkManager. Sudo privileges might be required." --icon=dialog-error
    fi
}

# Function to disable WiFi power saving
disable_wifi_power_save() {
    # Get the first WiFi interface reported by NetworkManager (e.g., wlan0, wlp3s0)
    local interface=$(nmcli -t -f DEVICE,TYPE device | grep ':wifi$' | cut -d':' -f1 | head -n1)

    if [[ -n "$interface" ]]; then
        show_with_loading "Disabling power saving for $interface" "sudo iw dev \"$interface\" set power_save off" "WiFi Power Save"
        local status=$?
        
        if [ $status -eq 0 ]; then
            notify-send "WiFi Power Save" "Power saving disabled for $interface." --icon=dialog-information
        else
            notify-send "WiFi Power Save Error" "Failed to disable power saving for $interface. Ensure 'iw' is installed and sudo privileges are correct." --icon=dialog-error
        fi
    else
        notify-send "WiFi Power Save Error" "No WiFi interface found." --icon=dialog-error
    fi
}


# Main function for WiFi menu
wifi_menu() {
    local menu_options_array=()
    
    if is_wifi_enabled; then
        menu_options_array+=("Turn WiFi Off")
        menu_options_array+=("Show Status")
        menu_options_array+=("Available Networks")
        menu_options_array+=("Saved Networks")
        menu_options_array+=("Disable WiFi Power Save") # New option
        
        local current_connection=$(nmcli -t -f NAME,DEVICE,TYPE connection show --active 2>/dev/null | 
                                  grep -v ':lo:' | 
                                  grep -E ':wlan|:wl' | 
                                  cut -d':' -f1 | 
                                  head -1)
        
        if [[ -n "$current_connection" ]]; then
            menu_options_array+=("Disconnect from $current_connection")
        fi
        menu_options_array+=("Restart NetworkManager")
    else
        menu_options_array+=("Turn WiFi On")
        menu_options_array+=("Restart NetworkManager")
    fi

    menu_options_array+=("  Back")
    menu_options_array+=("󰜺  Cancel")
    
    local options_string=""
    printf -v options_string '%s\n' "${menu_options_array[@]}"
    options_string=${options_string%?} # Remove trailing newline

    local selected=$(echo -e "$options_string" | wofi --dmenu -i -p "WiFi")
    
    # Process selection
    if [[ -z "$selected" ]]; then # User pressed Esc or closed wofi
        exit 0
    fi

    if [[ "$selected" == "Turn WiFi Off" ]]; then
        toggle_wifi
    elif [[ "$selected" == "Turn WiFi On" ]]; then
        toggle_wifi
        sleep 1
    elif [[ "$selected" == "Show Status" ]]; then
        show_wifi_status
        return # show_wifi_status handles its own loop back to wifi_menu
    elif [[ "$selected" == "Available Networks" ]]; then
        show_available_networks
        # If 'Back' or cancelled in show_available_networks, it calls wifi_menu.
        # If a network is chosen, flow continues here.
    elif [[ "$selected" == "Saved Networks" ]]; then
        manage_saved_networks
        # Similar logic to show_available_networks for looping
    elif [[ "$selected" == "Disable WiFi Power Save" ]]; then
        disable_wifi_power_save
    elif [[ "$selected" == "Restart NetworkManager" ]]; then
        restart_network_manager
    elif [[ "$selected" == "Disconnect from "* ]]; then # MODIFIED LINE
        local conn_name=$(echo "$selected" | sed 's/Disconnect from //') # More robust way to get conn_name
        show_with_loading "Disconnecting from $conn_name" "nmcli connection down \"$conn_name\"" "WiFi"
        if [ $? -eq 0 ]; then
            notify-send "WiFi" "Disconnected from $conn_name" --icon=network-wireless-disconnected
        else
            notify-send "WiFi Error" "Failed to disconnect from $conn_name" --icon=dialog-error
        fi
    elif [[ "$selected" == "  Back" ]]; then
        ~/.config/wofi/scripts/menu_launcher.sh
    elif [[ "$selected" == "󰜺  Cancel" ]]; then
        exit 0; return
    fi
    
    # After an action, unless the function handled its own loop (like show_status)
    # or exited, show the menu again.
    wifi_menu
}

# Run the WiFi menu
wifi_menu