#!/bin/bash
set -euo pipefail

target="$HOME/.local/bin/pak57"

if [[ -e "$target" || -L "$target" ]]; then
    rm -- "$target"
    printf 'Uninstalled pak57 from %s\n' "$target"
else
    printf 'pak57 is not installed at %s\n' "$target"
fi
