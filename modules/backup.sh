#!/bin/bash

ask_backup_preference() {
    BACKUP_FULL_CONFIG=0
    read -r -p "📦 Deseja backup COMPLETO de ~/.config? (pode demorar) [s/N]: " reply
    case "$reply" in
        [sS]|[sS][iI][mM]) BACKUP_FULL_CONFIG=1 ;;
        *) BACKUP_FULL_CONFIG=0 ;;
    esac
}

backup_configs() {
    echo "📦 Criando backup..."

    local backup_root="$HOME/.backup-config"
    local stamp
    stamp="$(date +%s)"
    mkdir -p "$backup_root"

    if [[ "$BACKUP_FULL_CONFIG" -eq 1 ]]; then
        cp -a "$HOME/.config" "$backup_root/config-$stamp" 2>/dev/null || true
        echo "✅ Backup completo de ~/.config criado."
    else
        local selective_dir="$backup_root/selective-$stamp"
        mkdir -p "$selective_dir"
        for d in hypr waybar kitty rofi dunst; do
            if [[ -e "$HOME/.config/$d" ]]; then
                cp -a "$HOME/.config/$d" "$selective_dir/$d" 2>/dev/null || true
            fi
        done
        echo "✅ Backup seletivo criado (hypr/waybar/kitty/rofi/dunst)."
    fi

    cp -a "$HOME/.zshrc" "$backup_root/zshrc-$stamp" 2>/dev/null || true
}
