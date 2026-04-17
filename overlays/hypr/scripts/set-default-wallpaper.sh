#!/bin/bash
set -uo pipefail
sleep 1.2
DIR="${HOME}/Pictures/wallpapers"
mkdir -p "$DIR"

# Sem imagens localmente: tenta o mesmo URL do instalador (binnewbs no GitHub)
ensure_one_image() {
    local n
    n="$(find "$DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | head -1)"
    [[ -n "$n" ]] && echo "$n" && return 0
    local url="https://raw.githubusercontent.com/binnewbs/arch-hyprland/main/wallpapers/07a937dfa5fcb675506b9622ad3802d4.jpg"
    local out="$DIR/hyprland-auto-default.jpg"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$out" 2>/dev/null && { echo "$out"; return 0; }
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$url" -O "$out" 2>/dev/null && { echo "$out"; return 0; }
    fi
    echo ""
}

IMG="$(ensure_one_image)"
[[ -z "$IMG" ]] && IMG="$(find "$DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | head -1)"
[[ -z "$IMG" ]] && exit 0

if command -v matugen >/dev/null 2>&1; then
    matugen image "$IMG" 2>/dev/null || true
fi

if command -v awww >/dev/null 2>&1; then
    awww img "$IMG" --transition-type any --transition-fps 60 2>/dev/null || true
elif command -v swww >/dev/null 2>&1; then
    swww img "$IMG" --transition-type any --transition-fps 60 2>/dev/null || true
fi
