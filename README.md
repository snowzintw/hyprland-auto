# Hyprland Auto Installer

Instalador automático de rice Hyprland baseado no projeto [binnewbs/arch-hyprland](https://github.com/binnewbs/arch-hyprland) (Matugen, swww, waybar etc. — créditos ao autor do rice).

## Instalação

```bash
git clone https://github.com/SEU-USUARIO/hyprland-auto.git
cd hyprland-auto
chmod +x install.sh
./install.sh
```

## O que ele faz

- Instala Hyprland e dependências (waybar, kitty, rofi, dunst, pipewire…)
- Instala helper AUR (`yay`) se ainda não existir
- Detecta GPU (informação; drivers NVIDIA não são instalados automaticamente)
- Pergunta se você quer backup completo de `~/.config`; se não, faz backup seletivo (`hypr`, `waybar`, `kitty`, `rofi`, `dunst`) e sempre salva `~/.zshrc` em `~/.backup-config`
- Clona [arch-hyprland](https://github.com/binnewbs/arch-hyprland), copia `.config` e `.zshrc`, define shell para zsh e roda `swww init`

## Requisitos

- Arch Linux instalado
- Usuário com `sudo`

## Observações

- NVIDIA pode exigir drivers/config extra; o script só detecta a placa.
- Recomenda-se revisar configs do rice original se mudar backend de wallpaper (o autor usa **swww** + **Matugen**).
- Log da execução: `install.log` na pasta do repositório.

## Logs

Arquivo gerado no diretório do instalador:

`install.log`
