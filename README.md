# Hyprland Auto Installer

Instalador automático de rice Hyprland baseado no projeto [binnewbs/arch-hyprland](https://github.com/binnewbs/arch-hyprland) (Matugen, swww, waybar etc. — créditos ao autor do rice).

## Instalação

```bash
git clone https://github.com/snowzintw/hyprland-auto.git
cd hyprland-auto
chmod +x install.sh restore-hypr-configs.sh
./install.sh
```

**Só corrigir Hyprland** (erros vermelhos, fundo preto, configs) **sem reinstalar tudo**:

```bash
cd hyprland-auto && git pull
./install.sh fix
# ou: ./restore-hypr-configs.sh
```

## O que ele faz

- Instala Hyprland e dependências (waybar, kitty, rofi, dunst, pipewire…)
- Instala helper AUR (`yay`) se ainda não existir
- Detecta GPU (informação; drivers NVIDIA não são instalados automaticamente)
- Pergunta se você quer backup completo de `~/.config`; se não, faz backup seletivo (`hypr`, `waybar`, `kitty`, `rofi`, `dunst`) e sempre salva `~/.zshrc` em `~/.backup-config`
- Clona o [arch-hyprland](https://github.com/binnewbs/arch-hyprland) (último `main`), copia `.config` e `.zshrc`, aplica **overlay** Hyprland **0.54+** (`tags.conf`, `windowrules.conf`, `hyprland-auto.conf`, script de wallpaper inicial), **matugen** com comando **awww**, copia **wallpapers** para `~/Pictures/wallpapers`, alinha **swww→awww** só onde faz sentido, opção de shell zsh

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

**Clone pede usuário/senha no GitHub** — use o URL certo (`snowz**i**ntw`, com **z**). No campo “Password” use um [Personal Access Token](https://github.com/settings/tokens), não a senha da conta. Repositório público não precisa de login se a URL estiver correta.

**`matugen` e `matugen-bin` em conflito** — o script instala só o que falta: se já existir `matugen-bin`, não tenta instalar `matugen`. Para trocar de um para o outro manualmente: `sudo pacman -Rns matugen-bin` e depois rode o instalador de novo (ou instale `matugen` com o yay).

**Erros vermelhos `invalid field class` em `tags.conf`** — o Hyprland **já não carrega** `~/.config/hypr/configs/tags.conf` por defeito: o instalador altera `hyprland.conf` para usar **`hyprland-auto-tags.conf`** e **`hyprland-auto-windowrules.conf`** (sintaxe 0.54), assim mesmo que algo volte a estragar `tags.conf`, **deixa de ser lido**. Corre `./install.sh fix` após `git pull`.

**Não tens `restore-hypr-configs.sh`** — faz `git pull` no repositório; o script chama internamente `./install.sh fix`.

**`chsh`: shell not changed** — o `chsh` pede a **password** do teu utilizador e só funciona bem em sessão **interativa**. O instalador agora pergunta antes de chamar `chsh`. Para mudar à mão: `chsh -s /usr/bin/zsh` (no Arch o zsh costuma ser `/usr/bin/zsh`; tem de estar listado em `/etc/shells`).

**`swww`: unrecognized subcommand "init"`** — versões recentes não têm `init`; o daemon arranca com **`exec-once`** no Hyprland. No **Arch**, o pacote em [extra] chama-se **`awww`** (binários `awww` e **`awww-daemon`**); o instalador instala `awww` e substitui referências `swww`/`swww-daemon` nos configs copiados. Se ainda vires o erro, faz **`git pull`** e volta a correr o script (ou remove o pacote AUR antigo `swww` se estiver a conflituar).

**`Sync Explicit: awww`** — é normal: no Arch o wallpaper oficial é o pacote **`awww`**, não confundir com um typo de `swww`.

**Fundo preto** — causas comuns: (1) **monitor** do binnewbs é `eDP-1`; se o teu output tiver outro nome, o compositor pode mostrar preto — `./install.sh fix` substitui por `monitor = , preferred, auto, 1`. (2) **`exec-once` com `$HOME`** — em alguns setups o Hyprland não expande; o `hyprland-auto.conf` usa `/bin/sh -c '...'`. (3) **awww** sem imagem — o script regista tudo em **`/tmp/hyprland-auto-wallpaper.log`**; se `awww img` falhar, tenta **swaybg** (pacote `swaybg`). Depois do fix: `hyprctl reload`, **Super+W** para escolher wallpaper.

## Requisitos

- Arch Linux instalado
- Usuário com `sudo`

## Observações

- NVIDIA pode exigir drivers/config extra; o script só detecta a placa.
- No Arch o pacote chama-se **awww** (equivalente moderno); **Matugen** continua a gerar cores para waybar, kitty, hypr, etc.
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
