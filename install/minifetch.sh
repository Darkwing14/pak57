#!/bin/bash
set -euo pipefail

REPO="https://raw.githubusercontent.com/Darkwing14/pak57/main"
bindir="$HOME/.local/bin"
target="$bindir/minifetch"

if ! command -v curl >/dev/null 2>&1; then
    printf 'minifetch installer: curl is required\n' >&2
    exit 127
fi

mkdir -p -- "$bindir"

tmp="$(mktemp "$bindir/.minifetch.XXXXXX")"
cleanup() {
    rm -f -- "$tmp"
}
trap cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

if ! curl --fail --silent --show-error --location \
    --proto '=https' --proto-redir '=https' \
    --connect-timeout 15 --max-time 300 \
    "$REPO/utils/minifetch.sh" -o "$tmp"; then
    printf 'minifetch installer: failed to download utils/minifetch.sh\n' >&2
    exit 1
fi

chmod 755 -- "$tmp"
mv -f -- "$tmp" "$target"
trap - EXIT

printf 'Installed minifetch to %s\n' "$target"
if [[ ":$PATH:" != *":$bindir:"* ]]; then
    printf 'Note: %s may not be in PATH in this shell.\n' "$bindir"
fi
