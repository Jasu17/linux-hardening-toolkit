#!/bin/bash

update_rhel(){
    log_info '[+] Updating RHEL-based system...'
    
    if ! sudo dnf upgrade -y; then
        log_error "System update failed"
        exit 1
    fi

    log_info "System updated succesfully    "

}