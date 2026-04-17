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

**Erros `invalid field class: …` (centenas de linhas, nomes tipo `XfceWnck`)** — isso **não** é o `tags.conf` do binnewbs nem o nosso overlay: costuma ser um ficheiro **corrompido ou gerado por outra ferramenta** com sintaxe antiga (`class:…` sem `windowrule` / sem `match:`). O instalador **volta a copiar** `overlays/hypr/configs/tags.conf` e `windowrules.conf` no **final** do passo do rice. Depois de `git pull`, corre **`bash restore-hypr-configs.sh`** na pasta do repo (ou):

```bash
chmod +x restore-hypr-configs.sh
./restore-hypr-configs.sh
```

Confirma que `~/.config/hypr/hyprland.conf` contém `source = ~/.config/hypr/hyprland-auto.conf` (o instalador acrescenta). O **Matugen** do binnewbs **não** gera `tags.conf`; se tiveres templates personalizados a escrever esse ficheiro, desativa-os.

**`chsh`: shell not changed** — o `chsh` pede a **password** do teu utilizador e só funciona bem em sessão **interativa**. O instalador agora pergunta antes de chamar `chsh`. Para mudar à mão: `chsh -s /usr/bin/zsh` (no Arch o zsh costuma ser `/usr/bin/zsh`; tem de estar listado em `/etc/shells`).

**`swww`: unrecognized subcommand "init"`** — versões recentes não têm `init`; o daemon arranca com **`exec-once`** no Hyprland. No **Arch**, o pacote em [extra] chama-se **`awww`** (binários `awww` e **`awww-daemon`**); o instalador instala `awww` e substitui referências `swww`/`swww-daemon` nos configs copiados. Se ainda vires o erro, faz **`git pull`** e volta a correr o script (ou remove o pacote AUR antigo `swww` se estiver a conflituar).

**`Sync Explicit: awww`** — é normal: no Arch o wallpaper oficial é o pacote **`awww`**, não confundir com um typo de `swww`.

**Fundo preto / sem tema** — o binnewbs arranca só o **daemon** do wallpaper; sem **primeira imagem** o ecrã fica preto. O overlay inclui `set-default-wallpaper.sh` (Matugen + `awww img`) e copia as imagens do repositório para `~/Pictures/wallpapers`. Garante `git pull` e volta a correr o instalador, ou no Hyprland: `Super+W` (wppicker) para escolher wallpaper. `hyprctl reload` após corrigir configs.

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
