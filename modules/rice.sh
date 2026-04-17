#!/bin/bash

# HYPR_RICE_URL — URL do rice (por defeito binnewbs). Ex.: export HYPR_RICE_URL=https://github.com/binnewbs/arch-hyprland.git
# HYPR_SKIP_OVERLAY=1 — só copia o .config do rice, sem overlays Hyprland 0.54 / matugen do instalador (para rices com estrutura própria)

apply_after_arch_clone() {
    local RICE_DIR="${1:?}"

    copy_hypr_overlays_from_repo
    copy_matugen_overlay

    if [[ -d "$RICE_DIR/wallpapers" ]]; then
        mkdir -p ~/Pictures/wallpapers
        cp -a "$RICE_DIR/wallpapers/." ~/Pictures/wallpapers/ 2>/dev/null || true
        echo "✅ Wallpapers copiados para ~/Pictures/wallpapers"
    fi

    apply_awww_sed_safe
    patch_hyprland_conf_sources
    patch_hyprland_monitor_fallback
    download_fallback_wallpaper_if_empty
}

install_rice() {
    echo "🎨 Instalando rice…"

    local RICE_GIT_URL="${HYPR_RICE_URL:-https://github.com/binnewbs/arch-hyprland.git}"
    RICE_DIR="${SCRIPT_DIR}/rice-upstream"
    rm -rf "$RICE_DIR"
    git clone --depth 1 "$RICE_GIT_URL" "$RICE_DIR"

    mkdir -p ~/.config
    cp -a "$RICE_DIR/.config/." ~/.config/

    if [[ "${HYPR_SKIP_OVERLAY:-}" == "1" ]]; then
        echo "⚠️ HYPR_SKIP_OVERLAY=1 — overlays do instalador não aplicados; usa só o rice clonado."
        download_fallback_wallpaper_if_empty
    else
        if [[ "$RICE_GIT_URL" != *"binnewbs/arch-hyprland"* ]]; then
            echo "⚠️ Rice não-binnewbs: os overlays (Hyprland 0.54, matugen awww) podem não coincidir com esta repo."
            echo "   Se algo falhar, tenta: HYPR_SKIP_OVERLAY=1 ./install.sh"
        fi
        apply_after_arch_clone "$RICE_DIR"
    fi

    if command -v awww >/dev/null 2>&1; then
        echo "✅ awww disponível (wallpaper Arch extra)."
    elif command -v swww >/dev/null 2>&1; then
        if [[ -f ~/.config/matugen/config.toml ]]; then
            sed -i 's/^command = "awww"/command = "swww"/' ~/.config/matugen/config.toml
        fi
        echo "✅ swww (AUR) — matugen ajustado para swww."
    fi

    if [[ -f "$RICE_DIR/.zshrc" ]]; then
        cp "$RICE_DIR/.zshrc" ~/
    else
        echo "ℹ️ Este rice não tem .zshrc na raiz — ignorado."
    fi

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
                        echo "✅ Shell alterado. Novo login para aplicar."
                    else
                        echo "⚠️ chsh falhou. Manual: chsh -s $_zsh_path"
                    fi
                    ;;
                *)
                    echo "ℹ️ Mantido o shell atual. Para zsh: chsh -s $_zsh_path"
                    ;;
            esac
        else
            echo "ℹ️ Sem TTY — não se alterou o shell. Manual: chsh -s $_zsh_path"
        fi
    fi

    if command -v awww-daemon >/dev/null 2>&1; then
        echo "✅ awww-daemon no PATH."
    elif command -v swww-daemon >/dev/null 2>&1; then
        echo "✅ swww-daemon no PATH."
    fi

    echo ""
    if [[ "${HYPR_SKIP_OVERLAY:-}" != "1" ]]; then
        echo "👉 O Hyprland foi patchado para hyprland-auto-tags.conf (quando aplicável)."
    fi
    echo "👉 Depois do login: hyprctl reload"
}
