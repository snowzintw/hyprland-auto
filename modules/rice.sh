#!/bin/bash

install_rice() {
    echo "🎨 Instalando rice..."

    RICE_DIR="${SCRIPT_DIR}/arch-hyprland"
    rm -rf "$RICE_DIR"
    git clone --depth 1 https://github.com/binnewbs/arch-hyprland.git "$RICE_DIR"

    mkdir -p ~/.config
    cp -a "$RICE_DIR/.config/." ~/.config/

    # Matugen: comando awww (Arch extra); se só existir swww (AUR), ajusta-se abaixo.
    if [[ -d "${SCRIPT_DIR}/overlays/matugen" ]]; then
        mkdir -p ~/.config/matugen
        cp -a "${SCRIPT_DIR}/overlays/matugen/config.toml" ~/.config/matugen/config.toml
    fi

    # Overlay completo Hyprland (tags/windowrules 0.54, scripts, extras)
    OVER_HYPR="${SCRIPT_DIR}/overlays/hypr"
    if [[ -d "$OVER_HYPR" ]]; then
        mkdir -p ~/.config/hypr
        cp -a "$OVER_HYPR/." ~/.config/hypr/
        chmod +x ~/.config/hypr/scripts/*.sh 2>/dev/null || true
    fi

    # Papel de parede do repositório binnewbs → mesmo sítio que o wppicker espera
    if [[ -d "$RICE_DIR/wallpapers" ]]; then
        mkdir -p ~/Pictures/wallpapers
        cp -a "$RICE_DIR/wallpapers/." ~/Pictures/wallpapers/ 2>/dev/null || true
        echo "✅ Imagens de wallpaper copiadas para ~/Pictures/wallpapers"
    fi

    # Arch [extra]: binários awww — só substituir swww onde realmente aparece (não tocar em tags/windowrules)
    if command -v awww >/dev/null 2>&1; then
        [[ -f ~/.config/hypr/hyprland.conf ]] && sed -i 's/^exec-once = swww-daemon/exec-once = awww-daemon/' ~/.config/hypr/hyprland.conf
        while IFS= read -r -d '' _f; do
            [[ "$_f" == *"/configs/tags.conf" ]] && continue
            [[ "$_f" == *"/configs/windowrules.conf" ]] && continue
            grep -q 'swww' "$_f" 2>/dev/null || continue
            sed -i 's/swww-daemon/awww-daemon/g;s/\bswww\b/awww/g' "$_f"
        done < <(find ~/.config/hypr -type f \( -name '*.sh' -o -name '*.conf' \) -print0 2>/dev/null)
        if [[ -f ~/.config/matugen/config.toml ]]; then
            sed -i 's/^command = "swww"/command = "awww"/' ~/.config/matugen/config.toml
        fi
        echo "✅ Referências swww → awww onde aplicável."
    else
        # Só swww (AUR): matugen overlay pedia awww — voltar a swww
        if [[ -f ~/.config/matugen/config.toml ]] && command -v swww >/dev/null 2>&1; then
            sed -i 's/^command = "awww"/command = "swww"/' ~/.config/matugen/config.toml
        fi
    fi

    # Garantir que os extras (wallpaper inicial) são carregados
    if [[ -f ~/.config/hypr/hyprland-auto.conf ]] && ! grep -qF 'hyprland-auto.conf' ~/.config/hypr/hyprland.conf 2>/dev/null; then
        printf '\n# hyprland-auto (instalador)\nsource = ~/.config/hypr/hyprland-auto.conf\n' >> ~/.config/hypr/hyprland.conf
    fi

    # Última linha de defesa: configs Hyprland 0.54 (evita ficheiros corrompidos por ferramentas antigas)
    if [[ -f "${SCRIPT_DIR}/overlays/hypr/configs/tags.conf" ]]; then
        cp -a "${SCRIPT_DIR}/overlays/hypr/configs/tags.conf" ~/.config/hypr/configs/tags.conf
        cp -a "${SCRIPT_DIR}/overlays/hypr/configs/windowrules.conf" ~/.config/hypr/configs/windowrules.conf
        echo "✅ tags.conf + windowrules.conf reforçados (sintaxe Hyprland 0.54)."
    fi

    cp "$RICE_DIR/.zshrc" ~/

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

    if command -v awww-daemon >/dev/null 2>&1; then
        echo "✅ awww-daemon disponível (autostart no Hyprland)."
    elif command -v swww-daemon >/dev/null 2>&1; then
        echo "✅ swww-daemon disponível (autostart no Hyprland)."
    fi

    echo ""
    echo "👉 Depois do login no Hyprland: hyprctl reload"
    echo "👉 Se ainda vires erros em tags.conf, apaga-o e copia de novo do repo (overlay)."
}
