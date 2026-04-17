#!/bin/bash

install_dependencies() {
    echo "📥 Instalando dependências..."

    sudo pacman -Syu --noconfirm

    sudo pacman -S --noconfirm \
        hyprland waybar kitty rofi dunst \
        zsh git neovim \
        wl-clipboard grim slurp \
        pipewire wireplumber \
        ttf-font-awesome noto-fonts

    "${AUR_CMD[@]}" matugen swww
}
