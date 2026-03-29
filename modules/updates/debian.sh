#!/bin/bash

update_debian(){
    log_info 'Updating Debian-based system...'
    
    if ! sudo apt update && sudo apt upgrade -y; then
        log_error "System update failed"
        exit 1
    fi

    log_info "System update succesfully"
    
}