#!/bin/bash
# Restaura tags.conf + windowrules.conf compatíveis com Hyprland 0.54 (corrige erros "invalid field class")
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p ~/.config/hypr/configs
cp -a "$ROOT/overlays/hypr/configs/tags.conf" ~/.config/hypr/configs/tags.conf
cp -a "$ROOT/overlays/hypr/configs/windowrules.conf" ~/.config/hypr/configs/windowrules.conf
if command -v hyprctl >/dev/null 2>&1 && [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
  hyprctl reload
  echo "✅ hyprctl reload"
else
  echo "✅ Ficheiros copiados. No Hyprland corre: hyprctl reload"
fi
