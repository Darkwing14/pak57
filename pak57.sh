#!/bin/bash

set -u

REPO="https://raw.githubusercontent.com/Darkwing14/pak57/main"

usage() {
    printf 'Usage:\n'
    printf '  pak57 <utility>\n'
    printf '  pak57 install <package>\n'
    printf '  pak57 uninstall <package>\n'
}

if [[ $# -ge 1 ]]; then
    if [[ "$1" == "install" || "$1" == "uninstall" ]]; then
        if [[ $# -lt 2 ]]; then
            usage >&2
            exit 2
        fi

        action="$1"
        name="$2"
        shift 2
    else
        action="utils"
        name="$1"
        shift
    fi
else
    usage >&2
    exit 2
fi

case "$action" in
    utils|install|uninstall)
        ;;
    *)
        printf 'pak57: unknown action: %s\n' "$action" >&2
        usage >&2
        exit 2
        ;;
esac

if [[ ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    printf 'pak57: invalid script name: %s\n' "$name" >&2
    exit 2
fi

if ! command -v curl >/dev/null 2>&1; then
    printf 'pak57: curl is required\n' >&2
    exit 127
fi

tmp="$(mktemp /tmp/pak57.XXXXXX)" || {
    printf 'pak57: could not create temporary file\n' >&2
    exit 1
}

cleanup() {
    rm -f -- "$tmp"
}

trap cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

url="$REPO/$action/$name.sh"

if [[ "$action" != "utils" ]]; then
    printf 'Running /%s/%s.sh...\n' "$action" "$name"
fi

if ! curl --fail --silent --show-error --location \
    --proto '=https' --proto-redir '=https' \
    --connect-timeout 15 --max-time 300 \
    "$url" -o "$tmp"; then
    printf 'pak57: failed to download %s/%s.sh\n' "$action" "$name" >&2
    exit 1
fi

bash "$tmp" "$@"
status=$?

if [[ "$action" != "utils" ]]; then
    if [[ $status -eq 0 ]]; then
        printf 'Done!\n'
    else
        printf 'pak57: script exited with status %s\n' "$status" >&2
    fi
fi

exit "$status"
