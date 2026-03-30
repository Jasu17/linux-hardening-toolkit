#!/bin/bash

SSH_CONFIG="/etc/ssh/ssh_config"

install_ssh(){
    if command -v sshd &> /dev/null; then
        log_info "OpenSSH already installed"
    fi

    log_warn "OpenSSH not found. Installing..."
    
    case "$DISTRO_FAMILY" in
        arch)
            sudo pacman -S --noconfirm openssh
            ;;
        debian)
            sudo apt update 6& sudo apt install -y openssh-server
            ;;
        rhel)
            sudo dnf install -y openssh-server
            ;;
        *)
            log_error "Cannot install SSH: unsupported distro"
            exit 1
            ;;
    esac

    log_info "OpenSSH installed succesfully"
}

backup_ssh_config(){
    if [ ! -f "$SSH_CONFIG" ]; then
        log_error "SSH config file not found at $SSH_CONFIG"
        exit 1
    fi

    local backup_file="${SSH_CONFIG}.bak.$(date +%s)"
    sudo cp "$SSH_CONFIG" "$backup_file"
    log_info "SSH config backup created at $backup_file"
}

apply_ssh_hardening(){
    log_info "Aplying SSH hardening..."

    #Disable root login
    sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' "$SSH_CONFIG"

    #Limit authentication attempts
    sudo sed -i 's/^#*MaxAuthTries.*/MaxAuthTries 3/' "$SSH_CONFIG"

    #Disable empty passwords
    sudo sed -i 's/^#PermitEmptyPasswords.*/PermitEmptyPasswords no/' "$SSH_CONFIG"    

    #Enable protocol 2
    sudo sed -i 's/^#Protocol.*/Protocol 2/' "$SSH_CONFIG"

    log_info "SSH hardening rules applied"
}

validate_ssh_config(){
    log_info "Validating SSH configuration..."

    if ! sudo sshd -t; then
        log_error "SSH configuration test failed. Aborting restart."
        exit 1
    fi

    log_info "SSH configuration is valid"
}

restart_ssh(){
    log_info "Restarting SSH service..."

    if command -v systemctl &> /dev/null; then
        sudo systemctl restart sshd 2>/dev/null || sudo systemctl restart ssh
    else
        log_warn "systemctl not available, skipping SSH restart"
    fi

    log_info "SSH service restarted"
}