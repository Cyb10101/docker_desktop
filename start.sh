#!/usr/bin/env bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
APPLICATION_UID=${APPLICATION_UID:-1000}
APPLICATION_GID=${APPLICATION_GID:-1000}
APPLICATION_USER=${APPLICATION_USER:-application}
APPLICATION_GROUP=${APPLICATION_GROUP:-application}

# Load environment file
if [ -f .env ]; then
  source .env
fi
if [ -f .env.local ]; then
  source .env.local
fi

# Select docker compose file
START_CONTEXT=${START_CONTEXT:-}
DOCKER_COMPOSE_FILE=docker-compose.yml
if [ "${START_CONTEXT:0:11}" == "Development" ]; then
  DOCKER_COMPOSE_FILE=docker-compose.dev.yml
fi

function startFunction {
    case ${1} in
        start)
            startFunction pull && \
            startFunction build && \
            startFunction up
        ;;
        up)
            docker-compose --project-directory "${SCRIPTPATH}" -f "${SCRIPTPATH}/${DOCKER_COMPOSE_FILE}" up -d
        ;;
        down)
            docker-compose --project-directory "${SCRIPTPATH}" -f "${SCRIPTPATH}/${DOCKER_COMPOSE_FILE}" down --remove-orphans
        ;;
        login-root)
            docker-compose --project-directory "${SCRIPTPATH}" -f "${SCRIPTPATH}/${DOCKER_COMPOSE_FILE}" exec desktop bash
        ;;
        login)
            startFunction bash
        ;;
        bash)
            docker-compose --project-directory "${SCRIPTPATH}" -f "${SCRIPTPATH}/${DOCKER_COMPOSE_FILE}" exec -u ${APPLICATION_USER} desktop bash
        ;;
        exec-web)
            docker-compose --project-directory "${SCRIPTPATH}" -f "${SCRIPTPATH}/${DOCKER_COMPOSE_FILE}" exec -u ${APPLICATION_USER} desktop "${@:2}"
        ;;
        *)
            docker-compose --project-directory "${SCRIPTPATH}" -f "${SCRIPTPATH}/${DOCKER_COMPOSE_FILE}" "${@:1}"
        ;;
    esac
}

startFunction "${@:1}"
exit $?
