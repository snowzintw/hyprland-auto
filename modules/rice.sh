#!/bin/bash

install_rice() {
    echo "🎨 Instalando rice..."

    RICE_DIR="${SCRIPT_DIR}/arch-hyprland"
    rm -rf "$RICE_DIR"
    git clone https://github.com/binnewbs/arch-hyprland.git "$RICE_DIR"

    mkdir -p ~/.config
    cp -a "$RICE_DIR/.config/." ~/.config/

    # Hyprland ≥ 0.54: binnewbs ainda usa windowrule antigo (class: / tag:).
    OVERLAY="${SCRIPT_DIR}/overlays/hypr"
    if [[ -d "$OVERLAY" ]]; then
        mkdir -p ~/.config/hypr/configs
        cp -a "$OVERLAY/configs/tags.conf" ~/.config/hypr/configs/tags.conf
        cp -a "$OVERLAY/configs/windowrules.conf" ~/.config/hypr/configs/windowrules.conf
        echo "✅ Aplicado overlay Hyprland 0.54 (tags.conf + windowrules.conf)."
    fi

    cp "$RICE_DIR/.zshrc" ~/

    if [[ "${SHELL:-}" != "/bin/zsh" ]]; then
        chsh -s /bin/zsh
    fi

    swww init || true
}
