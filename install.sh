#!/bin/bash
set -e
set -u

# ------------------------------------------
# 1️⃣ Check if running as root for pacman
# ------------------------------------------
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root (or with sudo)"
    exit 1
fi

# ------------------------------------------
# 2️⃣ Install packages from pkglist
# ------------------------------------------
PKG_LIST_FILE="./pkglist/pacman.txt"

if [ ! -f "$PKG_LIST_FILE" ]; then
    echo "Error: $PKG_LIST_FILE not found!"
    exit 1
fi

echo "Installing packages from $PKG_LIST_FILE..."
pacman -Syu --needed - < "$PKG_LIST_FILE"

# ------------------------------------------
# 3️⃣ Install GNU Stow if missing
# ------------------------------------------
if ! command -v stow &> /dev/null; then
    echo "GNU Stow not found, installing..."
    pacman -S --needed stow
fi

# ------------------------------------------
# 4️⃣ Stow all dotfiles (adopt existing configs)
# ------------------------------------------
DOTFILES_DIR="$(pwd)"
echo "Stowing all dotfiles (adopt existing configs)..."
cd "$DOTFILES_DIR"
stow --adopt *

echo "✅ Installation complete!"
echo "Please log out and log back in to apply environment variables and dark theme."
