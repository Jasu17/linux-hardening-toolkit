#!/bin/bash

run_cmd(){
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY_RUN] $*"
        return 0
    else
        eval "$@"
        return $?
    fi
}
