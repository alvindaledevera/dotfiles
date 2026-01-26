#!/bin/bash
set -e
set -u

# ------------------------------------------
# 1️⃣ Install packages from pkglist
# ------------------------------------------
PKG_LIST_FILE="./pkglist/pacman.txt"

if [ ! -f "$PKG_LIST_FILE" ]; then
    echo "Error: $PKG_LIST_FILE not found!"
    exit 1
fi

echo "Installing packages from $PKG_LIST_FILE..."
sudo pacman -Syu --needed - < "$PKG_LIST_FILE"

# ------------------------------------------
# 2️⃣ Install GNU Stow if missing
# ------------------------------------------
if ! command -v stow &> /dev/null; then
    echo "GNU Stow not found, installing..."
    sudo pacman -S --needed stow
fi

# ------------------------------------------
# 3️⃣ Stow all dotfiles (adopt existing configs) - loop version
# ------------------------------------------
DOTFILES_DIR="$(pwd)"
STOW_PACKAGES=("env" "gtk" "qt" "sway" "waybar" "kde" "scripts")

echo "Stowing all dotfiles (adopt existing configs)..."
cd "$DOTFILES_DIR"

for pkg in "${STOW_PACKAGES[@]}"; do
    echo "Stowing $pkg..."
    stow --adopt "$pkg"
done


# power menu
chmod +x ~/scripts/*
echo "Waybar powermenu.sh is now executable"


echo "✅ Installation complete!"
echo "Please log out and log back in to apply environment variables and dark theme."
