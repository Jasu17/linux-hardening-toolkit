#!/bin/bash

disable_service(){
    local service="$1"

    if systemctl list-unit-files --type=service| grep -q "^${service}"; then
        log_warn "Disabling service: $service"

        run_cmd sudo systemctl disable --now "$service" \
            || log_warn "Failed to disable service: $service"
    else
        log_info "Service not found: $service"
    fi
}

disable_unnecessary_services(){
    log_info "Disabling unnecessary services..."

    SERVICES=(
        avahi-daemon.service
        cups.service
        bluetooth.service
    )

    for svc in "${SERVICES[@]}"; do
        disable_service "$svc"
    done
}

setup_services(){
    if ! command -v systemctl &> /dev/null; then
        log_warn "systemctl not available, skipping services hardening" 
        return
    fi

    disable_unnecessary_services
}