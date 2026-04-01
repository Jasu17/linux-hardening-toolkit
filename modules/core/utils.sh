#!/bin/bash

run_cmd(){
    if [ "${DRY_RUN:-false}" = true ]; then
        log_info "[DRY_RUN] $*"
        return 0
    fi

    "$@"
    return $?
}
