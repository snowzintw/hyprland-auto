#!/bin/bash

detect_gpu() {
    echo "🔍 Detectando GPU..."

    if lspci 2>/dev/null | grep -E "NVIDIA"; then
        GPU="nvidia"
        echo "⚠️ NVIDIA detectada"
    elif lspci 2>/dev/null | grep -E "AMD|ATI"; then
        GPU="amd"
        echo "✅ AMD detectada"
    elif lspci 2>/dev/null | grep -E "Intel"; then
        GPU="intel"
        echo "✅ Intel detectada"
    else
        GPU="intel"
        echo "✅ Assumindo Intel (não encontrou NVIDIA/AMD explícitos)"
    fi
}
