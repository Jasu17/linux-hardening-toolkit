#!/bin/bash

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load core modules
source "$SCRIPT_DIR/modules/core/logger.sh"
source "$SCRIPT_DIR/modules/core/utils.sh"
source "$SCRIPT_DIR/modules/core/detect_distro.sh"

# Init logger
init_logger
log_info "=== Linux Hardening Toolkit ==="
check_privileges

# Default values
RUN_UPDATES=true
RUN_USERS=true
RUN_SSH=true
RUN_FIREWALL=true
RUN_SYSCTL=true
RUN_SERVICES=true
DRY_RUN=false

CONFIG_FILE="$SCRIPT_DIR/configs/default.conf"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
    log_info "Loaded configuration from $CONFIG_FILE"

    RUN_UPDATES=${ENABLE_UPDATES:-true}
    RUN_USERS=${ENABLE_USERS:-true}
    RUN_SSH=${ENABLE_SSH:-true}
    RUN_FIREWALL=${ENABLE_FIREWALL:-true}
    RUN_SYSCTL=${ENABLE_SYSCTL:-true}
    RUN_SERVICES=${ENABLE_SERVICES:-true}
else
    log_warn "Config file not found, using defaults"
fi

apply_profile(){
    case "$PROFILE" in
        server)
            log_info "Applying server profile"
            RUN_SERVICES=true
            RUN_USERS=true
            RUN_FIREWALL=true
            ;;
        desktop)
            log_info "Applying desktop profile"
            RUN_SERVICES=false
            RUN_USERS=true
            ;;
        *)
            log_warn "Unknown profile: $PROFILE"
            ;;
    esac
}

show_help(){
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  --dry-run              Simulate execution without applying changes
  --only <module>        Run only the specified module
  --no-users             Skip user account hardening
  --no-updates           Skip system updates
  --no-ssh               Skip SSH hardening
  --no-firewall          Skip firewall configuration
  --no-sysctl            Skip kernel hardening
  --no-services          Skip service minimization
  --help                 Show this help message

Modules:
  updates, ssh, firewall, sysctl, services, users

Profiles (set in configs/default.conf):
  server                 Enables firewall and service minimization
  desktop                Disables service minimization

Examples:
  $(basename "$0") --dry-run
  $(basename "$0") --only ssh
  $(basename "$0") --no-firewall --no-services
EOF
    exit 0
}

print_summary(){
    log_info "======================================"
    log_info "  Hardening Summary"
    log_info "======================================"
    for module in updates ssh firewall sysctl services; do
        local status="${MODULE_STATUS[$module]:-SKIPPED}"
        log_info "  $(printf '%-12s' "$module") $status"
    done
    log_info "======================================"
}

# Argument parser
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help) show_help ;;
        --no-users) RUN_USERS=false ;;
        --no-updates) RUN_UPDATES=false ;;
        --no-ssh) RUN_SSH=false ;;
        --no-firewall) RUN_FIREWALL=false ;;
        --no-sysctl) RUN_SYSCTL=false ;;
        --no-services) RUN_SERVICES=false ;;

        --only)
            shift
            RUN_UPDATES=false
            RUN_SSH=false
            RUN_FIREWALL=false
            RUN_SYSCTL=false
            RUN_SERVICES=false
            RUN_USERS=false

            case "$1" in
                updates) RUN_UPDATES=true ;;
                ssh) RUN_SSH=true ;;
                firewall) RUN_FIREWALL=true ;;
                sysctl) RUN_SYSCTL=true ;;
                services) RUN_SERVICES=true ;;
                users) RUN_USERS=true ;;
                *)
                    log_error "Unknown module: $1"
                    exit 1
                    ;;
            esac
            ;;
        --dry-run)
            DRY_RUN=true
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

apply_profile

# Detect distro
detect_distro

log_info "Detected distro: $DISTRO"
log_info "Distro Family: $DISTRO_FAMILY"

# Execution plan
log_info "Execution plan"
log_info "Updates: $RUN_UPDATES"
log_info "SSH: $RUN_SSH"
log_info "Firewall: $RUN_FIREWALL"
log_info "Sysctl: $RUN_SYSCTL"
log_info "Services: $RUN_SERVICES"
log_info "Users: $RUN_USERS"
log_info "Dry-run: $DRY_RUN"

declare -A MODULE_STATUS

# Updates
if [ "$RUN_UPDATES" = true ]; then
    source "$SCRIPT_DIR/modules/updates/arch.sh"
    source "$SCRIPT_DIR/modules/updates/debian.sh"
    source "$SCRIPT_DIR/modules/updates/rhel.sh"

    case "$DISTRO_FAMILY" in
        arch)
            update_arch && MODULE_STATUS[updates]="OK" || MODULE_STATUS[updates]="FAILED"
            ;;
        debian|ubuntu)
            update_debian && MODULE_STATUS[updates]="OK" || MODULE_STATUS[updates]="FAILED"
            ;;
        rhel)
            update_rhel && MODULE_STATUS[updates]="OK" || MODULE_STATUS[updates]="FAILED"
            ;;
        *)
            log_error "Unsupported distro for updates: $DISTRO"
            MODULE_STATUS[updates]="FAILED"
            exit 1
            ;;
    esac
else
    MODULE_STATUS[updates]="SKIPPED"
fi

# SSH Hardening
if [ "$RUN_SSH" = true ]; then
    source "$SCRIPT_DIR/modules/ssh/ssh_hardening.sh"
    install_ssh
    generate_ssh_keys
    backup_ssh_config
    apply_ssh_hardening
    validate_ssh_config
    restart_ssh && MODULE_STATUS[ssh]="OK" || MODULE_STATUS[ssh]="FAILED"
else
    MODULE_STATUS[ssh]="SKIPPED"
fi

# Firewall
if [ "$RUN_FIREWALL" = true ]; then
    source "$SCRIPT_DIR/modules/firewall/firewall.sh"
    setup_firewall && MODULE_STATUS[firewall]="OK" || MODULE_STATUS[firewall]="FAILED"
else
    MODULE_STATUS[firewall]="SKIPPED"
fi

# Sysctl Hardening
if [ "$RUN_SYSCTL" = true ]; then
    source "$SCRIPT_DIR/modules/sysctl/sysctl_hardening.sh"
    setup_sysctl && MODULE_STATUS[sysctl]="OK" || MODULE_STATUS[sysctl]="FAILED"
else
    MODULE_STATUS[sysctl]="SKIPPED"
fi

# Services Hardening
if [ "$RUN_SERVICES" = true ]; then
    source "$SCRIPT_DIR/modules/services/services_hardening.sh"
    setup_services && MODULE_STATUS[services]="OK" || MODULE_STATUS[services]="FAILED"
else
    MODULE_STATUS[services]="SKIPPED"
fi

# Users Hardening
if [ "$RUN_USERS" = true ]; then
    source "$SCRIPT_DIR/modules/users/users_hardening.sh"
    setup_users && MODULE_STATUS[users]="OK" || MODULE_STATUS[users]="FAILED"
else
    MODULE_STATUS[users]="SKIPPED"
fi

print_summary