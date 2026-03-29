#!/bin/bash

detect_distro(){
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO="$ID"
        DISTRO_LIKE="$ID_LIKE"
    
    # Normalize distro family
    if [[ "$DISTRO" == "arch" ]] || [[ "$DISTRO_LIKE" == *"arch"* ]]; then
        DISTRO_FAMILY="arch"
    elif [[ "$DISTRO" == "debian" ]] || [[ "$DISTRO" == "ubuntu" ]] || [[ "$DISTRO_LIKE" == *"debian"* ]]; then
        DISTRO_FAMILY="debian"
    elif [[ "$DISTRO" == "rhel" ]] || [[ "$DISTRO" == "fedora" ]] || [[ "$DISTRO" == "centos" ]] || [[ "$DISTRO_LIKE" == *"rhel"* ]]; then
        DISTRO_FAMILY="rhel"
    else
        DISTRO_FAMILY="unknown"
    fi
    else
        echo '[!] Cannot detect linux distribution.'
        exit 1
    fi
}