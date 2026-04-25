#!/bin/bash

lock_root_account(){
    log_info "Locking root account"

    if run_cmd sudo passwd -l root; then
        log_info "Root account locked"
    else        
        log_warn "Failed to lock root account"
    fi
}

set_pasword_policy(){
    log_info "Applying password policies..."

    local login_defs="/etc/login.defs"

    if [ ! -f "$login_defs" ]; then
        log_warn "login.defs not found, skipping password policy"
        return
    fi

    run_cmd sudo sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' "$login_defs"
    run_cmd sudo sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   1/' "$login_defs"
    run_cmd sudo sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   7/' "$login_defs"

    log_info "Password policy applied (max 90 days, min 1 day, warn 7 days)"
}

disable_unusedaccounts(){
    log_info "Checking for unused system accounts..."

    local accounts=("games" "news" "uucp" "proxy" "list" "irc" "gnats")

    for account in "${accounts[@]}"; do
        if id "$account" $>/dev/null; then
            run_cmd sudo usermod -s /usr/sbin/nologin "$account" \
                && log_info "Disabled login shell for: $account" \
                || log_warn "Could not disable: $account"
        fi
    done
}

setup_users (){
    lock_root_account
    set_pasword_policy
    disable_unusedaccounts
    }