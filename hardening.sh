#!/bin/bash

echo "=== Linux Hardening Toolkit ==="
# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#Load modules
source "$SCRIPT_DIR/modules/core/detect_distro.sh"
source "$SCRIPT_DIR/modules/core/logger.sh"
source "$SCRIPT_DIR/modules/ssh/ssh_hardening.sh"
source "$SCRIPT_DIR/modules/firewall/firewall.sh"
source "$SCRIPT_DIR/modules/sysctl/sysctl_hardening.sh"

init_logger
log_info "Starting hardening process"

detect_distro
echo "[+] Detected distro: $DISTRO"
echo "[+] Distro Family: $DISTRO_FAMILY"


case "$DISTRO_FAMILY" in
    arch)
        source "$SCRIPT_DIR/modules/updates/arch.sh"
        update_arch
        ;;
    debian|ubuntu)
        source "$SCRIPT_DIR/modules/updates/debian.sh"
        update_debian
        ;;
    rhel|fedora|centos)
        source "$SCRIPT_DIR/modules/updates/rhel.sh"
        update_rhel
        ;;
    *)
        echo "[!] Unsupported distro: $DISTRO"
        exit 1
        ;;
esac

#SSH Hardening
install_ssh
backup_ssh_config
apply_ssh_hardening
validate_ssh_config
restart_ssh

# Firewall
setup_firewall

# Sysctl Hardening
setup_sysctl