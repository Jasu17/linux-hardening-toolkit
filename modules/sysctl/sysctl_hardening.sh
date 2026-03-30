#!/bin/bash

SYSCTL_FILE="/etc/sysctl.d/99-hardening.conf"

apply_sysctl_setting(){
    log_info "Applying sysctl hardening settings..."

    sudo tee "$SYSCTL_FILE" > /dev/null <<EOF
# IP spoofing protection
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Ignore ICMP breadcast request
net.ipv4.icmp_echo_ignore_broadcast = 1

# Disable source packet routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# Enable TCP SYN cookies (protect against SYN flood)
net.ipv4.tcp_syncookies = 1

# Log suspicious packets
net.ipv4.conf.all.log_martians = 1

# Ignore ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0

# Disable IPv6 redirects (if IPv6 enabled)
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
EOF

    log_info "Sysctl connfiguration written to $SYSCTL_FILE"
}

apply_sysctl_runtime(){
    log_info "Reloading sysctl settings..."

    sudo sysctl --system

    log_info "Sysctl settings applied"
}

setup_sysctl(){
    apply_sysctl_setting
    apply_sysctl_runtime
}