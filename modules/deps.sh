#!/bin/bash

install_matugen_wallpaper() {
    # matugen e matugen-bin fornecem o mesmo binário — não instalar os dois.
    if pacman -Qs '^matugen-bin$' >/dev/null 2>&1; then
        echo "✅ matugen-bin já instalado (equivalente ao matugen)."
    elif pacman -Qs '^matugen$' >/dev/null 2>&1; then
        echo "✅ matugen já instalado."
    else
        "${AUR_CMD[@]}" matugen
    fi

    # Arch [extra]: o projeto renomeou-se para "awww" (binários awww / awww-daemon).
    # O AUR "swww" ainda existe e pode confundir; preferir o pacote oficial quando existir.
    if command -v pacman >/dev/null 2>&1 && pacman -Si awww &>/dev/null; then
        sudo pacman -S --needed --noconfirm awww
        echo "✅ Wallpaper: awww (repositório extra)."
    else
        "${AUR_CMD[@]}" swww
        echo "✅ Wallpaper: swww (AUR)."
    fi
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

    install_matugen_wallpaper
}
