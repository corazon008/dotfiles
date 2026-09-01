#!/usr/bin/env bash

# --------------------------------------------------------------
# Uninstall swww if exists. To be replaced with awww in the next steps
# --------------------------------------------------------------

if [[ $(_isInstalled "swww") == 0 ]]; then
    echo ":: swww is installed. Uninstalling swww to avoid conflicts with awww"
    sudo pacman -Rns --noconfirm swww
fi
