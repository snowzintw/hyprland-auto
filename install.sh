#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

export SCRIPT_DIR HYPR_AUTO_ROOT="$SCRIPT_DIR"

source "$SCRIPT_DIR/modules/fix.sh"

case "${1:-}" in
    fix|--fix|repair)
        fix_hypr_configs
        exit $?
        ;;
esac

LOG_FILE="$SCRIPT_DIR/install.log"

: > "$LOG_FILE"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "🚀 Hyprland Auto Installer"

if ! command -v pacman >/dev/null 2>&1; then
    echo "❌ Este instalador é para Arch/derivados (pacman não encontrado)."
    exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
    echo "❌ sudo não encontrado."
    exit 1
fi

# -------------------------
# Importar módulos
# -------------------------
source "$SCRIPT_DIR/modules/ui.sh"
source "$SCRIPT_DIR/modules/gpu.sh"
source "$SCRIPT_DIR/modules/aur.sh"
source "$SCRIPT_DIR/modules/deps.sh"
source "$SCRIPT_DIR/modules/backup.sh"
source "$SCRIPT_DIR/modules/rice.sh"

# -------------------------
# Execução
# -------------------------
show_banner
ask_backup_preference
detect_gpu
install_aur_helper
install_dependencies
backup_configs
install_rice

echo ""
echo "✅ INSTALAÇÃO FINALIZADA!"
echo "📄 Log salvo em: $LOG_FILE"
echo "💡 Corrigir só Hyprland sem reinstalar: ./install.sh fix"
