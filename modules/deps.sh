#!/bin/bash

install_matugen_swww() {
    # matugen e matugen-bin fornecem o mesmo binário — não instalar os dois.
    if pacman -Qs '^matugen-bin$' >/dev/null 2>&1; then
        echo "✅ matugen-bin já instalado (equivalente ao matugen)."
    elif pacman -Qs '^matugen$' >/dev/null 2>&1; then
        echo "✅ matugen já instalado."
    else
        "${AUR_CMD[@]}" matugen
    fi
    "${AUR_CMD[@]}" swww
}

install_dependencies() {
    echo "📥 Instalando dependências..."

    sudo pacman -Syu --noconfirm

    sudo pacman -S --noconfirm \
        hyprland waybar kitty rofi dunst \
        zsh git neovim \
        wl-clipboard grim slurp \
        pipewire wireplumber \
        woff2-font-awesome noto-fonts

    install_matugen_swww
}
