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
                sudo pacman -S --noconfirm ufw
                FIREWALL="ufw"
                ;;
            debian)
                sudo apt update && sudo apt install -y ufw
                FIREWALL="ufw"
                ;;
            rhel)
                sudo dnf install -y firewalld
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

    sudo ufw default deny incomming
    sudo ufw default allow outgoing

    # Allow SSH
    sudo ufw allow ssh

    sudo ufw --force enable

    log_info "UFW configured and enabled"
}

configure_firewalld(){
    log_info "Configuring firewalld..."

    sudo systemctl enable --now firewalld

    # Allow SSH
    sudo firewall-cmd --permanent --add-service=ssh

    # Reload rules
    sudo firewall-cmd --reload

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