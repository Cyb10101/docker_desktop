#!/usr/bin/env bash

# Create /docker.stdout and /docker.stderr
function createDockerStdoutStderr() {
    # link stdout from docker
    if [[ -n "$LOG_STDOUT" ]]; then
        echo "Log stdout redirected to $LOG_STDOUT"
    else
        LOG_STDOUT="/proc/$$/fd/1"
    fi

    if [[ -n "$LOG_STDERR" ]]; then
        echo "Log stderr redirected to $LOG_STDERR"
    else
        LOG_STDERR="/proc/$$/fd/2"
    fi

    ln -f -s "$LOG_STDOUT" /docker.stdout
    ln -f -s "$LOG_STDERR" /docker.stderr
}

function includeScriptDir() {
    if [[ -d "$1" ]]; then
        for FILE in "$1"/*.sh; do
            echo "-> Executing ${FILE}"
            # run custom scripts, only once
            . "$FILE"
        done
    fi
}

# Run "entrypoint" scripts
function runEntrypoints() {
    # Try to find entrypoint
    ENTRYPOINT_SCRIPT="/opt/docker/bin/entrypoints/${TASK}.sh"

    if [ -f "$ENTRYPOINT_SCRIPT" ]; then
        . "$ENTRYPOINT_SCRIPT"
    fi

    # Run default
    if [ -f "/opt/docker/bin/entrypoints/default.sh" ]; then
        . /opt/docker/bin/entrypoints/default.sh
    fi

    exit 1
}

# Run "entrypoint" provisioning
function runProvisionEntrypoint() {
    includeScriptDir "/opt/docker/bin/entrypoint.d"
    includeScriptDir "/entrypoint.d"
}
