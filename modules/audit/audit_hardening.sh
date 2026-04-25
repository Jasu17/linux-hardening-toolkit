#!/bin/bash

install_audit(){
    log_info "Checking auditd availability..."

    if command -v auditctl &>dev/null; then
        log_info "auditd is already installed"
        return 0
    fi

    log_warn "audit not found. Installing..."

    case "$DISTRO_FAMILY" in
        arch)
            run_cmd sudo pacman -S --noconfirm audit \
                || { log_error "Failed to install audit"; exit 1; }
            ;;
        debian|ubuntu)
            run_cmd sudo apt update \
                || { log_error "Failed to update package list"; exit 1; }
            run_cmd sudo apt install -y auditd \
                || { log_error "Failed to install auditd"; exit 1; }
            ;;
        rhel)
            run_cmd sudo dnf install -y audit \
                || { log_error "Failed to install audit"; exit 1; }
            ;;
        *)
            log_error "Unsupported distro for audit installation: $DISTRO"
            exit 1
            ;;
    esac

    log_info "Audit installed succesfully"
}


apply_audit_rules(){
    log_info "Applying audit rules..."

    local rules_file="/etc/audit/rules.d/99-hardening.rules"

    run_cmd sudo tee "$rules_file" > /dev/null <<EOF
# Delete all existing rules
-D

# Set buffer size
-b 8192

# Monitor changes to user/group files
-w /etc/passwd -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/sudoers -p wa -k sudoers

# Monitor login/logout events
-w /var/log/lastlog -p wa -k logins
-w /var/run/faillock -p wa -k logins

# Monitor sudo usage
-w /usr/bin/sudo -p x -k sudo_usage

# Monitor SSH config changes
-w /etc/ssh/sshd_config -p wa -k sshd_config

# Monitor sysctl config changes
-w /etc/sysctl.d/ -p wa -k sysctl

# Detect privilege escalation
-a always,exit -F arch=b64 -S setuid -S setgid -k privilege_escalation
-a always,exit -F arch=b32 -S setuid -S setgid -k privilege_escalation
EOF

    log_info "Audit rules written to $rules_file"
}

enable_auditd(){
    log_info "Enabling auditd service..."

    if command -v systemctl &>/dev/null; then
        run_cmd sudo systemctl enable --now auditd \
            || { log_error "Failed to enable auditd"; exit 1; }
    else
        log_warn "systemctl not available, skipping auditd enable"
        return
    fi

    log_info "auditd enabled and running"
}

reload_audit_rules(){
    log_info "Reloading audit rules..."

    run_cmd sudo augenrules --load \
        || run_cmd sudo auditctl -R /etc/audit/rules.d/99-hardening.rules \
        || { log_error "Failed to reload audit rules"; exit 1; }

    log_info "Audit rules loaded"
}

setup_audit(){
    install_auditd
    apply_audit_rules
    enable_auditd
    reload_audit_rules
}