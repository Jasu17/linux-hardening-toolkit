#!/bin/bash

update_debian(){
    echo '[+] Updating Debian-based system...'
    sudo apt update && sudo apt upgrade -y
    
}