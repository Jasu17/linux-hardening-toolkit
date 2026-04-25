#!/bin/bash

install_firewall(){
    log_info "Checking firewall availability..."

    if command -v ufw &> /dev/null; then
        FIREWALL="ufw"
    elif command -v firewall-cmd &> /dev/null; then
        FIREWALL="firewalld"
    else
        log_warn "No firewall found. Installing..."

        case "$DISTRO_FAMILY" in
            arch)
                run_cmd sudo pacman -S --noconfirm ufw \
                    || { log_error "Failed to install ufw"; exit 1; }
                FIREWALL="ufw"
                ;;
            debian)
                run_cmd sudo apt update \
                    || { log_error "apt update failed"; exit 1; } 
                run_cmd sudo apt install -y ufw \
                    || { log_error "Failed to install ufw"; exit 1; }
                FIREWALL="ufw"
                ;;
            rhel)
                run_cmd sudo dnf install -y firewalld \
                    || { log_error "Failed to install firewalld" ; exit 1; }
                FIREWALL="firewalld"
                ;;
            *)
            log_error "Cannot install firewall: unsupported distro"
            ;;
        esac
    fi

    log_info "Using firewall: $FIREWALL"
}

configure_ufw(){
    log_info "Configuring UFW..."

    run_cmd sudo ufw default deny incoming
    run_cmd sudo ufw default allow outgoing

    # Allow SSH (critical)
    run_cmd sudo ufw allow ssh

    run_cmd sudo ufw --force enable

    log_info "UFW configured and enabled"
}

configure_firewalld(){
    log_info "Configuring firewalld..."

    run_cmd sudo systemctl enable --now firewalld \
        || { log_error "Failed to start firewalld"; exit 1; }

    # Allow SSH
    run_cmd sudo firewall-cmd --permanent --add-service=ssh \
        || { log_error "Failed to allow SSH"; exit 1; }

    # Reload rules
    run_cmd sudo firewall-cmd --reload \
        || { log_error "Failed to reload firewall rules"; exit 1; }

    log_info "firewalld configured and running" 
}

setup_firewall(){
    install_firewall    

    case "$FIREWALL" in
        ufw)
            configure_ufw
            ;;
        firewalld)
            configure_firewalld
            ;;
        *)
            log_error "Unknown firewall: $FIREWALL"
            exit 1
            ;;
    esac
}