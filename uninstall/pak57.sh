#!/bin/bash
set -euo pipefail

target="$HOME/.local/bin/minifetch"

if [[ -e "$target" || -L "$target" ]]; then
    rm -- "$target"
    printf 'Uninstalled minifetch from %s\n' "$target"
else
    printf 'minifetch is not installed at %s\n' "$target"
fi
