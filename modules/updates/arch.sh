#!/bin/bash

update_arch(){
    log_info 'Updating Arch-basedd system...'
    
    if ! sudo pacman -Syu --noconfirm;then
        log_error "System update failed"
        exit 1
    fi
    
    log_info "System updated succesfully"
}