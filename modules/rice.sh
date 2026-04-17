#!/bin/bash

install_rice() {
    echo "🎨 Instalando rice..."

    RICE_DIR="${SCRIPT_DIR}/arch-hyprland"
    rm -rf "$RICE_DIR"
    git clone https://github.com/binnewbs/arch-hyprland.git "$RICE_DIR"

    mkdir -p ~/.config
    cp -a "$RICE_DIR/.config/." ~/.config/
    cp "$RICE_DIR/.zshrc" ~/

    if [[ "${SHELL:-}" != "/bin/zsh" ]]; then
        chsh -s /bin/zsh
    fi

    swww init || true
}
