#!/usr/bin/env bash

TIMEOUT=15

CACHE="/tmp/bt_devices"

# close wofi if already open
pgrep -x wofi >/dev/null && killall wofi && exit 0

# --- check / enable bluetooth ---
state=$(bluetoothctl show | awk '/PowerState/ {print $2}')

case "$state" in
    off)
        bluetoothctl power on >/dev/null
        ;;
    off-blocked)
        rfkill unblock bluetooth
        for ((i=1; i<=TIMEOUT; i++)); do
            new_state=$(bluetoothctl show | awk '/PowerState/ {print $2}')
            [[ "$new_state" == "on" ]] && break
            sleep 1
        done
        [[ "$new_state" != "on" ]] && exit 1
        ;;
esac

# --- scan devices (same logic as fzf script) ---
bluetoothctl -t "$TIMEOUT" scan on >/dev/null

# --- collect discovered + paired devices ---
bluetoothctl devices | sed 's/^Device //' > "$CACHE"

[[ ! -s "$CACHE" ]] && exit 1

# --- wofi menu ---
choice=$(cat "$CACHE" | wofi --dmenu --prompt "Bluetooth")

[[ -z "$choice" ]] && exit 0

ADDRESS=$(echo "$choice" | awk '{print $1}')

# --- check connection state ---
info=$(bluetoothctl info "$ADDRESS")
connected=$(echo "$info" | awk '/Connected/ {print $2}')
paired=$(echo "$info" | awk '/Paired/ {print $2}')

# already connected → disconnect
if [[ "$connected" == "yes" ]]; then
    bluetoothctl disconnect "$ADDRESS"
    exit 0
fi

# pair if needed
if [[ "$paired" == "no" ]]; then
    timeout "$TIMEOUT" bluetoothctl pair "$ADDRESS" || exit 1
    bluetoothctl trust "$ADDRESS"
fi

# connect
timeout "$TIMEOUT" bluetoothctl connect "$ADDRESS"
