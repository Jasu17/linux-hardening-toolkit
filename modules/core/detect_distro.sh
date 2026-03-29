#!/bin/bash

detect_distro(){
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    else
        echo '[!] Cannot detect linux distribution.'
        exit 1
    fi
}