#!/bin/bash

update_rhel(){
    log_info '[+] Updating RHEL-based system...'

    run_cmd "sudo dnf upgrade -y" \
        || { log_error "System update failed"; exit 1; }

    log_info "System updated succesfully    "

}