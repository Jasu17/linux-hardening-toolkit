#!/bin/bash

SSH_CONFIG="/etc/ssh/ssh_config"

backup_ssh_config(){
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
    sudo seed -i 's/^#Protocol.*/Protocol 2/' "$SSH_CONFIG"

    log_info "SSH hardening rules applied"
}

restart_ssh(){
    log_info "Restarting SSH service..."

    if command -v systemctl &> /dev/null; then
        sudo systemctl restart sshd 2>/dev/null || sudo systemctl restart ssh
    else
        log_warn "systemctl not available, skipping SSH restart"
    fi
}