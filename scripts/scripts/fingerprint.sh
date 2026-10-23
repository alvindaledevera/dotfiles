#!/usr/bin/env bash
set -e

# Safety: huwag payagan ma-run as root
if [ "$USER" = "root" ]; then
  echo "❌ Do not run this script as root"
  exit 1
fi

FINGERS=(
  left-thumb
  left-index-finger
  left-middle-finger
  left-ring-finger
  left-little-finger
  right-thumb
  right-index-finger
  right-middle-finger
  right-ring-finger
  right-little-finger
)

# Main menu: Enroll or Delete
ACTION=$(printf "Enroll Fingerprint\nDelete Fingerprint" | wofi --dmenu --prompt "Select action:")

if [ -z "$ACTION" ]; then
    echo "❌ No action selected"
    exit 1
fi

if [ "$ACTION" = "Enroll Fingerprint" ]; then
    # Show finger selection for enroll
    FINGER=$(printf '%s\n' "${FINGERS[@]}" | wofi --dmenu --prompt "Select finger to enroll:")
    if [ -z "$FINGER" ]; then
        echo "❌ No finger selected"
        exit 1
    fi
    echo
    echo "👉 Enrolling fingerprint: $FINGER"
    echo
    sudo fprintd-enroll "$USER" -f "$FINGER"
    echo
    echo "✅ Enrollment complete. Current fingerprints:"
    fprintd-list "$USER"

elif [ "$ACTION" = "Delete Fingerprint" ]; then
    echo "⚠️ Warning: fprintd version only supports deleting ALL fingerprints at once."
    echo "Do you want to continue? (yes/no or y/n)"

    read -r CONFIRM
    # Convert to lowercase
    CONFIRM=$(echo "$CONFIRM" | tr '[:upper:]' '[:lower:]')

    # Check valid responses
    if [[ "$CONFIRM" != "yes" && "$CONFIRM" != "y" ]]; then
        echo "❌ Delete cancelled."
        read -n 1 -s -r -p "Press any key to exit..."
        echo
        exit 0
    fi

    # Proceed to delete
    sudo fprintd-delete "$USER"

    echo
    echo "✅ All fingerprints deleted. Current fingerprints:"
    fprintd-list "$USER"
fi





# Wait for keypress before closing terminal
echo
read -n 1 -s -r -p "Press any key to exit..."
echo
