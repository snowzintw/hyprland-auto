#!/bin/bash
# Atalho: aplica o mesmo que ./install.sh fix
cd "$(dirname "$0")" || exit 1
exec bash ./install.sh fix
