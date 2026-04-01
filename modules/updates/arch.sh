#!/bin/bash

update_arch(){
    log_info "Updating Arch-based system..."
    
    run_cmd sudo pacman -Syu --noconfirm \
        || { log_error "System update failed"; exit 1; }
    
    log_info "System updated successfully"
}