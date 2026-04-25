#!/bin/bash

run_cmd(){
    if [ "${DRY_RUN:-false}" = true ]; then
        log_info "[DRY_RUN] $*"
        return 0
    fi

    "$@"
    return $?
}

check_privileges(){
    if [ "$EUID" -eq 0 ]; then
        log_info "Running as root"
        return 0
    fi

    if ! sudo -n true 2>/dev/null; then
        log_error "This script requires root or passwordless sudo privileges"
        exit 1
    fi

    log_info "Sudo privileges confirmed"
}