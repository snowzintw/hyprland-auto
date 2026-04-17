#!/bin/bash
# Log para depuração: tail -f /tmp/hyprland-auto-wallpaper.log
exec >>/tmp/hyprland-auto-wallpaper.log 2>&1
echo "=== $(date) set-default-wallpaper ==="

set -uo pipefail
sleep 2.5

DIR="${HOME}/Pictures/wallpapers"
mkdir -p "$DIR"

ensure_one_image() {
    local n
    n="$(find "$DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | head -1)"
    [[ -n "$n" ]] && { echo "$n"; return 0; }
    local url="https://raw.githubusercontent.com/binnewbs/arch-hyprland/main/wallpapers/07a937dfa5fcb675506b9622ad3802d4.jpg"
    local out="$DIR/hyprland-auto-default.jpg"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$out" && { echo "$out"; return 0; }
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$url" -O "$out" && { echo "$out"; return 0; }
    fi
    echo ""
}

IMG="$(ensure_one_image)"
[[ -z "$IMG" ]] && IMG="$(find "$DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | head -1)"
if [[ -z "$IMG" ]]; then
    echo "Nenhuma imagem disponível."
    exit 0
fi
echo "Imagem: $IMG"

if command -v matugen >/dev/null 2>&1; then
    matugen image "$IMG" 2>&1 || true
fi

_ok=0
if command -v awww >/dev/null 2>&1; then
    if awww img "$IMG" --transition-type any --transition-fps 60 2>&1; then
        _ok=1
    fi
elif command -v swww >/dev/null 2>&1; then
    if swww img "$IMG" --transition-type any --transition-fps 60 2>&1; then
        _ok=1
    fi
fi

# Fallback: fundo sólido sem depender do daemon awww (extra: swaybg)
if [[ "$_ok" != 1 ]] && command -v swaybg >/dev/null 2>&1; then
    pkill swaybg 2>/dev/null || true
    swaybg -m fill -i "$IMG" &
    echo "Usado swaybg como fallback."
fi
