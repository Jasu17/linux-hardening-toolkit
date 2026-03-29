#!/bin/bash

#Log file
LOG_FILE="$SCRIPT_DIR/logs/hardening.log"

init_logger(){
    mkdir -p "$(dirname "$LOG_FILE")"
    touch "$LOG_FILE"
}

_log(){
    local level="$1"
    local message="$2"
    local timestamp

    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

log_info(){
    _log "INFO" "$1"
}

log_warn(){
    _log "WARN" "$1"
}

log_error(){
    _log "ERROR" "$1"
}