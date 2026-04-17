#!/bin/bash
# Aplica overlays Hyprland + altera hyprland.conf para NÃO carregar tags.conf (ficheiro muitas vezes corrompido).

patch_hyprland_conf_sources() {
    local h="$HOME/.config/hypr/hyprland.conf"
    [[ -f "$h" ]] || return 0

    # ~ ou caminho absoluto $HOME (o segundo usa variável do utilizador)
    sed -i \
        -e 's|^source[[:space:]]*=[[:space:]]*~/.config/hypr/configs/tags.conf|source = ~/.config/hypr/configs/hyprland-auto-tags.conf|' \
        -e 's|^source[[:space:]]*=[[:space:]]*~/.config/hypr/configs/windowrules.conf|source = ~/.config/hypr/configs/hyprland-auto-windowrules.conf|' \
        "$h"
    if [[ -n "${HOME:-}" ]]; then
        local esc="${HOME//\//\\/}"
        sed -i "s|^source[[:space:]]*=[[:space:]]*${esc}/.config/hypr/configs/tags.conf|source = ~/.config/hypr/configs/hyprland-auto-tags.conf|" "$h"
        sed -i "s|^source[[:space:]]*=[[:space:]]*${esc}/.config/hypr/configs/windowrules.conf|source = ~/.config/hypr/configs/hyprland-auto-windowrules.conf|" "$h"
    fi

    if ! grep -qF 'hyprland-auto.conf' "$h" 2>/dev/null; then
        printf '\n# hyprland-auto (instalador)\nsource = ~/.config/hypr/hyprland-auto.conf\n' >>"$h"
    fi
}

# binnewbs: "monitor = eDP-1, ..." — se o painel tiver outro nome → ecrã preto
patch_hyprland_monitor_fallback() {
    local h="$HOME/.config/hypr/hyprland.conf"
    [[ -f "$h" ]] || return 0
    if grep -qE '^monitor[[:space:]]*=[[:space:]]*eDP-1' "$h"; then
        sed -i 's|^monitor[[:space:]]*=[[:space:]]*eDP-1,.*|monitor = , preferred, auto, 1|' "$h"
        echo "✅ Monitor: eDP-1 fixo substituído por deteção automática (evita ecrã preto)."
    fi
}

copy_hypr_overlays_from_repo() {
    local ROOT="${SCRIPT_DIR:?}"
    local OVER_HYPR="$ROOT/overlays/hypr"
    [[ -d "$OVER_HYPR" ]] || return 1
    mkdir -p "$HOME/.config/hypr"
    cp -a "$OVER_HYPR/." "$HOME/.config/hypr/"
    chmod +x "$HOME/.config/hypr/scripts/"*.sh 2>/dev/null || true

    mkdir -p "$HOME/.config/hypr/configs"
    cp -a "$OVER_HYPR/configs/tags.conf" "$HOME/.config/hypr/configs/tags.conf"
    cp -a "$OVER_HYPR/configs/windowrules.conf" "$HOME/.config/hypr/configs/windowrules.conf"
    cp -a "$OVER_HYPR/configs/hyprland-auto-tags.conf" "$HOME/.config/hypr/configs/hyprland-auto-tags.conf"
    cp -a "$OVER_HYPR/configs/hyprland-auto-windowrules.conf" "$HOME/.config/hypr/configs/hyprland-auto-windowrules.conf"
}

copy_matugen_overlay() {
    local ROOT="${SCRIPT_DIR:?}"
    [[ -d "$ROOT/overlays/matugen" ]] || return 0
    mkdir -p "$HOME/.config/matugen"
    cp -a "$ROOT/overlays/matugen/config.toml" "$HOME/.config/matugen/config.toml"
}

apply_awww_sed_safe() {
    command -v awww >/dev/null 2>&1 || return 0
    [[ -f "$HOME/.config/hypr/hyprland.conf" ]] && sed -i 's/^exec-once = swww-daemon/exec-once = awww-daemon/' "$HOME/.config/hypr/hyprland.conf"
    local _f
    while IFS= read -r -d '' _f; do
        [[ "$_f" == *"/configs/tags.conf" ]] && continue
        [[ "$_f" == *"/configs/windowrules.conf" ]] && continue
        [[ "$_f" == *"/configs/hyprland-auto-tags.conf" ]] && continue
        [[ "$_f" == *"/configs/hyprland-auto-windowrules.conf" ]] && continue
        grep -q 'swww' "$_f" 2>/dev/null || continue
        sed -i 's/swww-daemon/awww-daemon/g;s/\bswww\b/awww/g' "$_f"
    done < <(find "$HOME/.config/hypr" -type f \( -name '*.sh' -o -name '*.conf' \) -print0 2>/dev/null)
    [[ -f "$HOME/.config/matugen/config.toml" ]] && sed -i 's/^command = "swww"/command = "awww"/' "$HOME/.config/matugen/config.toml"
}

# Chamado pelo install.sh fix e pelo fim do rice (sem re-clonar)
fix_hypr_configs() {
    echo "🔧 Modo fix: overlays + patch hyprland.conf (ignora tags.conf quebrado)…"
    copy_hypr_overlays_from_repo || {
        echo "❌ overlays/hypr em falta no repositório."
        return 1
    }
    copy_matugen_overlay
    patch_hyprland_conf_sources
    patch_hyprland_monitor_fallback
    apply_awww_sed_safe
    download_fallback_wallpaper_if_empty
    if command -v hyprctl >/dev/null 2>&1 && [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
        hyprctl reload && echo "✅ hyprctl reload" || echo "⚠️ hyprctl reload falhou — tenta de novo dentro do Hyprland."
    else
        echo "✅ Config atualizada. No Hyprland: hyprctl reload"
    fi
    return 0
}

# Se ~/Pictures/wallpapers estiver vazio, descarrega uma imagem do binnewbs (GitHub raw)
download_fallback_wallpaper_if_empty() {
    local dir="$HOME/Pictures/wallpapers"
    mkdir -p "$dir"
    find "$dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.webp' \) -print -quit 2>/dev/null | grep -q . && return 0
    local url="https://raw.githubusercontent.com/binnewbs/arch-hyprland/main/wallpapers/07a937dfa5fcb675506b9622ad3802d4.jpg"
    local out="$dir/hyprland-auto-default.jpg"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$out" && echo "✅ Wallpaper de recurso descarregado: $out"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$url" -O "$out" && echo "✅ Wallpaper de recurso descarregado: $out"
    else
        echo "⚠️ Instala curl ou wget para descarregar wallpaper de recurso."
    fi
}
