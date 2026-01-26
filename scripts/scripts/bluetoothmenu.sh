#!/usr/bin/env bash
# Check if wofi power menu is running
if pgrep -x wofi >/dev/null; then
    killall wofi   # close existing menu
    exit 0
fi

# Get list of available devices
devices=$(bluetoothctl devices | awk '{print $2 " - " substr($0, index($0,$3))}')

# Add options for power toggle
options="Toggle Power\n$devices"

# Show menu via Wofi
choice=$(echo -e "$options" | wofi --dmenu --prompt "Bluetooth")

# Handle selection
if [[ "$choice" == "Toggle Power" ]]; then
    # Check current power state
    STATE=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')
    if [ "$STATE" = "yes" ]; then
        bluetoothctl power off
    else
        bluetoothctl power on
    fi
elif [[ -n "$choice" ]]; then
    # Extract device MAC
    mac=$(echo $choice | awk '{print $1}')
    # Check if connected
    status=$(bluetoothctl info $mac | grep "Connected" | awk '{print $2}')
    if [[ "$status" == "yes" ]]; then
        bluetoothctl disconnect $mac
    else
        bluetoothctl connect $mac
    fi
fi
