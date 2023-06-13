#!/usr/bin/env bash

# Create /docker.stdout and /docker.stderr
createDockerStdoutStderr() {
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

# Run "entrypoint" provisioning
runProvisionEntrypoint() {
    includeScriptDir "/opt/docker/bin/entrypoint.d"
    includeScriptDir "/entrypoint.d"
}

runEntrypoints() {
    ENTRYPOINT_PATH="/opt/docker/bin/entrypoints"
    if [ -f "${ENTRYPOINT_PATH}/${TASK}.sh" ]; then
        . "${ENTRYPOINT_PATH}/${TASK}.sh"
    elif [ -f "${ENTRYPOINT_PATH}/default.sh" ]; then
        . "${ENTRYPOINT_PATH}/default.sh"
    fi
    exit 1
}

#if [[ -z "$CONTAINER_UID" ]]; then
#    export CONTAINER_UID="application"
#fi

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value

# auto elevate privileges (if container is not started as root)
#if [[ "$UID" -ne 0 ]]; then
#    export CONTAINER_UID="$UID"
#    exec gosu root "$0" "$@"
#fi
# remove suid bit on gosu
#chmod -s /sbin/gosu

trap 'echo sigterm ; exit' SIGTERM
trap 'echo sigkill ; exit' SIGKILL

# sanitize input and set task
TASK="$(echo $1| sed 's/[^-_a-zA-Z0-9]*//g')"

source /opt/docker/bin/functions.sh

createDockerStdoutStderr

# Only run provision if user is root
if [[ "$UID" -eq 0 ]]; then
    if [ "$TASK" == "supervisord" -o "$TASK" == "noop" ]; then
        # Visible provisioning
        runProvisionEntrypoint
    else
        # Hidden provisioning
        runProvisionEntrypoint > /dev/null
    fi
fi

runEntrypoints "$@"
