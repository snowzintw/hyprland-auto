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

    # Shell por defeito: Arch usa /usr/bin/zsh; chsh pede password e falha sem TTY.
    _zsh_path=""
    for _c in /usr/bin/zsh /bin/zsh; do
        [[ -x "$_c" ]] || continue
        if grep -qxF "$_c" /etc/shells 2>/dev/null; then
            _zsh_path="$_c"
            break
        fi
    done
    if [[ -n "$_zsh_path" ]]; then
        _login_shell="$(getent passwd "$(id -un)" | cut -d: -f7)"
        if [[ "$_login_shell" == "$_zsh_path" ]]; then
            echo "✅ Shell de login já é zsh ($_zsh_path)."
        elif [[ -t 0 ]]; then
            read -r -p "Alterar shell de login para zsh ($_zsh_path)? Pedirá a password. [s/N]: " _ans
            case "$_ans" in
                [sS]|[sS][iI][mM])
                    if chsh -s "$_zsh_path"; then
                        echo "✅ Shell alterado. Abra um novo login para aplicar."
                    else
                        echo "⚠️ chsh falhou. Corra manualmente: chsh -s $_zsh_path"
                    fi
                    ;;
                *)
                    echo "ℹ️ Mantido o shell atual. Para zsh depois: chsh -s $_zsh_path"
                    ;;
            esac
        else
            echo "ℹ️ Sem terminal interativo — não se alterou o shell. Corra: chsh -s $_zsh_path"
        fi
    else
        echo "⚠️ zsh não encontrado ou não está em /etc/shells — instale zsh e confira /etc/shells."
    fi

    # swww ≥0.10 removeu `swww init`; o hyprland.conf do rice usa `exec-once = swww-daemon`.
    if command -v swww-daemon >/dev/null 2>&1; then
        echo "✅ swww-daemon disponível (arranca com o Hyprland)."
    elif command -v swww >/dev/null 2>&1; then
        echo "ℹ️ swww instalado; use swww-daemon no autostart (Hyprland ≥ rice binnewbs)."
    fi
}
