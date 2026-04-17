# Hyprland Auto Installer

Instalador automático de rice Hyprland baseado no projeto [binnewbs/arch-hyprland](https://github.com/binnewbs/arch-hyprland) (Matugen, swww, waybar etc. — créditos ao autor do rice).

## Instalação

```bash
git clone https://github.com/snowzintw/hyprland-auto.git
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

## Problemas comuns

**`fatal: destination path 'hyprland-auto' already exists`** — a pasta já existe. Ou entre nela e atualize (`cd hyprland-auto && git pull`), ou apague/renomeie e clone de novo:

```bash
rm -rf hyprland-auto
git clone https://github.com/snowzintw/hyprland-auto.git
cd hyprland-auto
```

**`chmod` / `./install.sh`: no such file or directory** — você não está dentro da pasta do repo, ou o caminho está errado. Confira:

```bash
pwd
ls install.sh
```

Se `install.sh` existir mas `./install.sh` falhar no zsh, converta fins de linha (Windows CRLF) e rode com bash:

```bash
sudo pacman -S --needed dos2unix
dos2unix install.sh modules/*.sh
chmod +x install.sh
bash install.sh
```

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

## Publicar no GitHub

Na pasta do projeto (com [Git](https://git-scm.com/) e [GitHub CLI](https://cli.github.com/) instalados):

```bash
gh auth login
gh repo create hyprland-auto --public --source=. --remote=origin --push
```

Sem interação, use um [Personal Access Token](https://github.com/settings/tokens) com escopo `repo` e defina `GH_TOKEN` no ambiente antes do `gh repo create`.

**Alternativa (site):** crie um repositório vazio `hyprland-auto` no GitHub e rode:

```bash
git remote add origin https://github.com/snowzintw/hyprland-auto.git
git push -u origin main
```
