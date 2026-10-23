#!/usr/bin/env bash
set -e

# Backup function
backup_file() {
    local FILE="$1"
    if [[ -f "$FILE" ]]; then
        sudo cp "$FILE" "$FILE.bak.$(date +%Y%m%d%H%M%S)"
        echo "Backup created: $FILE.bak"
    fi
}

# 1️⃣ Add pam_fprintd.so to /etc/pam.d/ly
LY_FILE="/etc/pam.d/ly"
echo "Adding 'auth sufficient pam_fprintd.so' to $LY_FILE"
backup_file "$LY_FILE"
sudo sed -i '1i auth    sufficient    pam_fprintd.so' "$LY_FILE"

# 2️⃣ Add pam_fprintd.so to /etc/pam.d/sudo
SUDO_FILE="/etc/pam.d/sudo"
echo "Adding 'auth sufficient pam_fprintd.so' to $SUDO_FILE"
backup_file "$SUDO_FILE"
sudo sed -i '1i auth    sufficient    pam_fprintd.so' "$SUDO_FILE"

# 3️⃣ Comment out all lines in /etc/pam.d/swaylock and add minimal config
SWAYLOCK_FILE="/etc/pam.d/swaylock"
echo "Commenting out all lines in $SWAYLOCK_FILE and adding new swaylock PAM config"
backup_file "$SWAYLOCK_FILE"
sudo sed -i 's/^/#/' "$SWAYLOCK_FILE"
sudo bash -c "echo -e '\nauth sufficient pam_unix.so try_first_pass likeauth nullok\nauth sufficient pam_fprintd.so' >> '$SWAYLOCK_FILE'"

echo "✅ All PAM modifications applied successfully."
echo "You may be prompted for your password for sudo operations."
