#!/bin/bash

install_aur_helper() {
    echo "📦 Verificando AUR helper..."

    if command -v yay &> /dev/null; then
        AUR_CMD=(yay -S --noconfirm)
        return
    fi

    echo "⚙️ Instalando yay..."

    sudo pacman -S --needed git base-devel --noconfirm

    YAY_DIR="${SCRIPT_DIR}/yay-build"
    rm -rf "$YAY_DIR"
    git clone https://aur.archlinux.org/yay.git "$YAY_DIR"
    ( cd "$YAY_DIR" && makepkg -si --noconfirm )
    rm -rf "$YAY_DIR"

    AUR_CMD=(yay -S --noconfirm)
}
