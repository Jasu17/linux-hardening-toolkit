#!/bin/bash

update_debian(){
    log_info 'Updating Debian-based system...'
    
    run_cmd "sudo apt update && sudo apt upgrade -y" \
        || { log_error "System update failed"; exit 1 ; }

    log_info "System update succesfully"
    
}