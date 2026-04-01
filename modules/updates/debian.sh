#!/bin/bash

update_debian(){
    log_info 'Updating Debian-based system...'
    
    run_cmd sudo apt update \
        || { log_error "System update failed"; exit 1 ; }
    run_cmd sudo apt upgrade -y \
        || { log_error "System upgrade failed"; exit 1 ; }

    log_info "System update successfully"
    
}