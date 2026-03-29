#!/bin/bash

echo "=== Linux Hardening Toolkit ==="
# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/modules/core/detect_distro.sh"

detect_distro

case "$DISTRO" in
    arch)
        source "$SCRIPT_DIR/modules/updates/arch.sh"
        update_arch
        ;;
    debian|ubuntu)
        source "$SCRIPT_DIR/modules/updates/debian.sh"
        update_arch
        ;;
    rhel|fedora|centos)
        source "$SCRIPT_DIR/modules/updates/rhel.sh"
        update_arch
        ;;
    *)
        echo "[!] Unsupported distro: $DISTRO"
        exit 1
        ;;
esac
