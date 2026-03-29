#!/bin/bash

update_rhel(){
    echo '[+] Updating RHEL-based system...'
    sudo dnf upgrade -y

}