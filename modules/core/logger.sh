#!/bin/bash

# Ensure SCRIPT_DIR exist
: "${SCRIPT_DIR:?SCRIPT_DIR is not set}"

#Log file
LOG_FILE="$SCRIPT_DIR/logs/hardening.log"

init_logger(){
    mkdir -p "$(dirname "$LOG_FILE")"
    touch "$LOG_FILE"

    # Rotate if log exceeds 1MB
    if [ -f "$LOG_FILE" ] && [ "$(stat -c%s "$LOG_FILE")" -gt 1048576 ]; then
        mv "$LOG_FILE" "${LOG_FILE}.$(date +%Y%m%d%H%M%S).bak"
        touch "$LOG_FILE"
    fi

    echo "" >> "$LOG_FILE"
    echo "=============================================" >> "$LOG_FILE"
    echo "   Session started: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
    echo "   User: $(whoami)  Host: $(hostname)" >> "$LOG_FILE"
    echo "=============================================" >> "$LOG_FILE"
}

_log(){
    local level="$1"
    shift
    local message="$*"
    local timestamp

    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

    local log_entry="[$timestamp] [$level] $message"

    # Allways write to file
    echo "$log_entry" >> "$LOG_FILE"

    # Print to console
    case "$level" in
        ERROR)
            echo "$log_entry" >&2
            ;;
        *)
            echo "$log_entry"
            ;;
    esac
}

log_info(){
    _log "INFO" "$@"
}

log_warn(){
    _log "WARN" "$@"
}

log_error(){
    _log "ERROR" "$@"
}