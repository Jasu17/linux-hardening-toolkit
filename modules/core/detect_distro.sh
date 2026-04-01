#!/bin/bash

detect_distro(){
    if [ ! -f /etc/os-release ]; then
        log_error "Cannot detect Linux distribution (/etc/os-relase missing)"
        exit 1
    fi

    # Load OS info
    source /etc/os-release

    DISTRO="${ID:-unknown}"
    DISTRO_LIKE="${ID_LIKE:-}"

    # Normalize combined string for matching
    local combined="$DISTRO $DISTRO_LIKE"

    case "$combined" in 
        *arch*)
            DISTRO_FAMILY="arch"
            ;;
        *debian*|*ubuntu*)
            DISTRO_FAMILY="debian"
            ;;
        *rhel*|*fedora*|*centos*)
            DISTRO_FAMILY="rhel"
            ;;
        *)
            DISTRO_FAMILY="unknown"
            ;;
    esac

    log_info "Distro detected: $DISTRO"
    log_info "Distro family: $DISTRO_FAMILY"
}