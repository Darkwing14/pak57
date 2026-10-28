#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
    exec sudo bash "$0" "$@"
fi

systemctl stop ollama.service 2>/dev/null || true
systemctl disable ollama.service 2>/dev/null || true

rm -f /etc/systemd/system/ollama.service
rm -f /usr/local/bin/ollama

rm -rf /usr/local/lib/ollama

systemctl daemon-reload
systemctl reset-failed

echo "Ollama binaries and service removed."
echo "User model data has been left untouched."
