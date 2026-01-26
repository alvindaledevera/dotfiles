#!/bin/bash

# Check if wofi power menu is running
if pgrep -x wofi >/dev/null; then
    killall wofi   # close existing menu
    exit 0
fi

choice=$(printf "⏻ Shutdown\n Reboot\n󰤄 Logout\n Lock" | \
  wofi --dmenu \
       --prompt "Power Menu" \
       --width 450 \
       --height 250 \
       --line-height 40 \
       --close-on-focus-loss)

case "$choice" in
  "⏻ Shutdown") systemctl poweroff ;;
  " Reboot") systemctl reboot ;;
  "󰤄 Logout") swaymsg exit ;;
  " Lock") swaylock ;;
esac