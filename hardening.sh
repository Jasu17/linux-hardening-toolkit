#!/bin/bash

echo "=== Linux Hardening Toolkit ==="
# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default flags
RUN_UPDATES=true
RUN_SSH=true
RUN_FIREWALL=true
RUN_SYSCTL=true
RUN_SERVICES=true
DRY_RUN=false

# Argument parser
while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-updates)
            RUN_UPDATES=false
            ;;
        --no-ssh)
            RUN_SSH=false
            ;;
        --no-firewall)
            RUN_FIREWALL=false
            ;;
        --no-sysctl)
            RUN_SYSCTL=false
            ;;
        --no-services)
            RUN_SERVICES=false
            ;;
        --only)
            shift
            RUN_UPDATES=false
            RUN_SSH=false
            RUN_FIREWALL=false
            RUN_SYSCTL=false
            RUN_SERVICES=false

            case "$1" in
                updates) RUN_UPDATES=true;;
                ssh) RUN_SSH=true;;
                firewall) RUN_FIREWALL=true;;
                sysctl) RUN_SYSCTL=true;;
                services) RUN_SERVICES=true;;
                *)
                    echo "[!] unknown module: $1"
                    exit 1
                    ;;
            esac
            ;;
        --dry-run)
            DRY_RUN=true
            ;;
        *)
            echo "[!] Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

# Load core modules
source "$SCRIPT_DIR/modules/core/detect_distro.sh"
source "$SCRIPT_DIR/modules/core/logger.sh"
source "$SCRIPT_DIR/modules/core/utils.sh"

# Init logger
init_logger
log_info "Starting hardening process"

# Detect distro
detect_distro

log_info "Detected distro: $DISTRO"
log_info "Distro Family: $DISTRO_FAMILY"

# Execution path
log_info "Execution path"
log_info "Updates: $RUN_UPDATES"
log_info "SSH: $RUN_SSH"
log_info "Firewall: $RUN_FIREWALL"
log_info "Sysctl: $RUN_SYSCTL"
log_info "Services: $RUN_SERVICES"
log_info "Dry-run: $DRY_RUN"

# Load modules
source "$SCRIPT_DIR/modules/updates/arch.sh"
source "$SCRIPT_DIR/modules/updates/debian.sh"
source "$SCRIPT_DIR/modules/updates/rhel.sh"

source "$SCRIPT_DIR/modules/ssh/ssh_hardening.sh"
source "$SCRIPT_DIR/modules/firewall/firewall.sh"
source "$SCRIPT_DIR/modules/sysctl/sysctl_hardening.sh"
source "$SCRIPT_DIR/modules/services/services_hardening.sh"

case "$DISTRO_FAMILY" in
    arch)
        update_arch
        ;;
    debian|ubuntu)
        update_debian
        ;;
    rhel|fedora|centos)
        update_rhel
        ;;
    *)
        log_error "Unsupported distro for updates: $DISTRO"
        exit 1
        ;;
esac



#SSH Hardening
if [ "$RUN_SSH" = true ]; then
    install_ssh
    generate_ssh_keys
    backup_ssh_config
    apply_ssh_hardening
    validate_ssh_config
    restart_ssh
fi

# Firewall
if [ "$RUN_FIREWALL" = true ]; then
    setup_firewall
fi

# Sysctl Hardening
if [ "$RUN_SYSCTL" = true ]; then
    setup_sysctl
fi

# Services Hardening
if [ "$RUN_SERVICES" = true ]; then
    setup_services
fi

log_info "Hardening process completed"