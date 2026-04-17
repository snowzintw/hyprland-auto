#!/bin/bash
# Primeira imagem em ~/Pictures/wallpapers (mesmo caminho do wppicker do binnewbs)
set -euo pipefail
sleep 0.8
DIR="${HOME}/Pictures/wallpapers"
[[ -d "$DIR" ]] || exit 0
IMG="$(find "$DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | head -1)"
[[ -z "$IMG" ]] && exit 0

if command -v matugen >/dev/null 2>&1; then
  matugen image "$IMG" 2>/dev/null || true
fi

if command -v awww >/dev/null 2>&1; then
  awww img "$IMG" --transition-type any --transition-fps 60 2>/dev/null || true
elif command -v swww >/dev/null 2>&1; then
  swww img "$IMG" --transition-type any --transition-fps 60 2>/dev/null || true
fi
