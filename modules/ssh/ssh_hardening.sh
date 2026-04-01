#!/bin/bash

SSH_CONFIG="/etc/ssh/sshd_config"

install_ssh(){
    if command -v sshd &> /dev/null; then
        log_info "OpenSSH already installed"
        return
    fi

    log_warn "OpenSSH not found. Installing..."
    
    case "$DISTRO_FAMILY" in
        arch)
            run_cmd sudo pacman -S --noconfirm openssh
            ;;
        debian)
            run_cmd sudo apt update \
            || { log_error "apt update failed"; exit 1; }
            run_cmd sudo apt install -y openssh-server
            ;;
        rhel)
            run_cmd sudo dnf install -y openssh-server
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
    run_cmd sudo cp "$SSH_CONFIG" "$backup_file"
    log_info "SSH config backup created at $backup_file"
}

apply_ssh_hardening(){
    log_info "Aplying SSH hardening..."

    run_cmd sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' "$SSH_CONFIG"
    run_cmd sudo sed -i 's/^#*MaxAuthTries.*/MaxAuthTries 3/' "$SSH_CONFIG"
    run_cmd sudo sed -i 's/^#*PermitEmptyPasswords.*/PermitEmptyPasswords no/' "$SSH_CONFIG"
    run_cmd sudo sed -i 's/^#*Protocol.*/Protocol 2/' "$SSH_CONFIG"

    log_info "SSH hardening rules applied"
}

validate_ssh_config(){
    log_info "Validating SSH configuration..."

    if ! run_cmd sudo sshd -t; then
        log_error "SSH configuration test failed. Aborting restart."
        exit 1
    fi

    log_info "SSH configuration is valid"
}

restart_ssh(){
    log_info "Restarting SSH service..."

    if command -v systemctl &> /dev/null; then
        run_cmd sudo systemctl restart sshd 2>/dev/null \
            || sudo systemctl restart ssh
    else
        log_warn "systemctl not available, skipping SSH restart"
    fi

    log_info "SSH service restarted"
}

generate_ssh_keys(){
    log_info "Checking SSH host keys..."

    if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
        log_warn "SSH host keys not found. Generating..."
        run_cmd sudo ssh-keygen -A
        log_info "SSH host keys generated"
    else
        log_info "SSH host keys already exist"
    fi
}