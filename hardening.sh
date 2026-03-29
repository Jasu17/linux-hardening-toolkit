#!/bin/bash

echo "=== Linux Hardening Toolkit ==="
source modules/core/detect_distro.sh

detect_distro

case "$DISTRO" in
    arch)
        source modules/updates/arch.sh
        update_arch
        ;;
    debian|ubuntu)
        source modules/updates/arch.sh
        update_arch
        ;;
    rhel|fedora|centos)
        source modules/updates/arch.sh
        update_arch
        ;;
    *)
        echo "[!] Unsupported distro: $DISTRO"
        exit 1
        ;;
esac
