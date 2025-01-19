#!/usr/bin/env bash
set -e; # Exit on error

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd "${SCRIPTPATH}"

APPLICATION_UID=${APPLICATION_UID:-1000}
APPLICATION_GID=${APPLICATION_GID:-1000}
APPLICATION_USER=${APPLICATION_USER:-application}
APPLICATION_GROUP=${APPLICATION_GROUP:-application}

setTerminalTitle() {
    echo -ne "\033]0;${1}\007"
    #echo -e "\033]2;${1}\007"
}

loadEnvironmentVariables() {
    if [ -f ".env" ]; then
      source .env
    fi
    if [ -f ".env.local" ]; then
      source .env.local
    fi
}

isContextDevelopment() {
    # Symfony
    APP_ENV=${APP_ENV:-}
    if [ "${APP_ENV}" == "dev" ]; then
        echo 1; return;
    fi

    # TYPO3
    TYPO3_CONTEXT=${TYPO3_CONTEXT:-}
    if [ "${TYPO3_CONTEXT:0:11}" == "Development" ]; then
        echo 1; return;
    fi

    # Wordpress
    WP_ENVIRONMENT_TYPE=${WP_ENVIRONMENT_TYPE:-}
    if [ "${WP_ENVIRONMENT_TYPE:0:11}" == "development" ]; then
        echo 1; return;
    fi

    # Custom
    ENV_DOCKER_CONTEXT=${ENV_DOCKER_CONTEXT:-}
    if [ "${ENV_DOCKER_CONTEXT:0:11}" == "Development" ]; then
        echo 1; return;
    fi

    echo 0;
}

setDockerComposeFile() {
    local developmentSuffix=''
    if [ "$(isContextDevelopment)" == "1" ]; then
        developmentSuffix='.dev'
    fi

    DOCKER_COMPOSE_FILE="compose${developmentSuffix}.yaml"
    if [ -e "compose${developmentSuffix}.yml" ]; then
        DOCKER_COMPOSE_FILE="compose${developmentSuffix}.yml"
    elif [ -e "docker-compose${developmentSuffix}.yaml" ]; then
        DOCKER_COMPOSE_FILE="docker-compose${developmentSuffix}.yaml"
    elif [ -e "docker-compose${developmentSuffix}.yml" ]; then
        DOCKER_COMPOSE_FILE="docker-compose${developmentSuffix}.yml"
    fi
}

dockerComposeCmd() {
    docker-compose -f "${DOCKER_COMPOSE_FILE}" "${@:1}"
}

checkRoot() {
    if [[ $EUID -ne 0 ]]; then
        echo 'You must be a root user!' 2>&1
        exit 1
    fi
}

gitCheckBranch() {
    if [ -d ".git" ]; then
        if [[ $(git symbolic-ref --short -q HEAD) != "${1}" ]]; then
            echo "ERROR: Git is not on branch ${1}!"
            [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
        fi
    fi
}

gitCheckDirty() {
    if [ -d ".git" ]; then
        if [[ $(git diff --stat) != '' ]]; then
            echo
            git status --porcelain
            echo

            read -p 'Git is dirty... Continue? [y/N] ' -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
            fi
        fi
    fi
}

findBinaryByWhich() {
  set +e
  binary=$(which "${1}")
  if [ $? -ne 0 ]; then
    return
  fi
  set -e
  echo ${binary}
  return
}

setPermissions() {
    chown -R ${APPLICATION_UID}:${APPLICATION_GID} .
    find . -type d -exec chmod ugo+rx,ug+w {} \;
    find . -type f -exec chmod ugo+r,ug+w {} \;
}

gitPull() {
    if [ -d ".git" ]; then
        git pull "${@:1}"
    fi
}

composerInstall() {
    if [ -f "composer.json" ]; then
        ${BIN_PHP} ${BIN_COMPOSER} --no-interaction install "${@:1}"
    fi
}

symfonyUpdateDatabase() {
    if [ -f "symfony.lock" ] && [ ! -z "${DATABASE_URL}" ]; then
        read -p 'Update database schema? [y/N] ' -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            ${BIN_PHP} ./bin/console doctrine:schema:update --force
        fi
    fi
}

symfonyClearCache() {
    if [ -f "symfony.lock" ]; then
        ${BIN_PHP} ./bin/console cache:clear --no-warmup
        ${BIN_PHP} ./bin/console cache:warmup
    fi
}

deployImages() {
  # Default: 64 bit
  setTerminalTitle "Build default (32/64 bit) ..."
  docker pull ubuntu:22.04
  docker build --no-cache --file Dockerfile --tag cyb10101/desktop:amd64 .
  docker push cyb10101/desktop:amd64

  # Arm64v8
  setTerminalTitle "Build Arm64v8 ..."
  docker pull multiarch/qemu-user-static:x86_64-aarch64
  docker pull --platform linux/arm64/v8 arm64v8/ubuntu:22.04
  docker run --rm --privileged multiarch/qemu-user-static:register --reset
  docker build --no-cache --file Dockerfile.arm64v8 --tag cyb10101/desktop:arm64v8 .
  docker push cyb10101/desktop:arm64v8

  # Arm32v7
  setTerminalTitle "Build Arm32v7 ..."
  docker pull multiarch/qemu-user-static:x86_64-arm
  docker pull --platform linux/arm/v7 arm32v7/ubuntu:22.04
  docker run --rm --privileged multiarch/qemu-user-static:register --reset
  docker build --no-cache --file Dockerfile.arm32v7 --tag cyb10101/desktop:arm32v7 .
  docker push cyb10101/desktop:arm32v7

  # Create manifest
  docker manifest create cyb10101/desktop:latest \
    --amend docker.io/cyb10101/desktop:amd64 \
    --amend docker.io/cyb10101/desktop:arm64v8 \
    --amend docker.io/cyb10101/desktop:arm32v7

  docker manifest push --purge cyb10101/desktop:latest
  setTerminalTitle ""

  # Clean up
  set +e
  read -p 'Remove ARM images? [y/N] ' -n 1 -r; echo ''
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker rmi $(docker images --filter=reference="cyb10101/desktop:arm64v8" -q)
    docker rmi $(docker images --filter=reference="cyb10101/desktop:arm32v7" -q)

    docker rmi $(docker images --filter=reference="multiarch/qemu-user-static:x86_64-aarch64" -q)
    docker rmi $(docker images --filter=reference="multiarch/qemu-user-static:x86_64-arm" -q)

    docker rmi $(docker images --filter=reference="arm64v8/ubuntu:22.04" -q)
    docker rmi $(docker images --filter=reference="arm32v7/ubuntu:22.04" -q)
  fi

  read -p 'Remove Ubuntu images? [y/N] ' -n 1 -r; echo ''
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker rmi $(docker images --filter=reference="ubuntu:22.04" -q)
  fi
  set -e
}

runDeploy() {
    checkRoot
    gitCheckBranch ${GIT_BRANCH}
    gitCheckDirty

    # Task 1: Deploy Git as root in server
    gitPull origin ${GIT_BRANCH}
    setPermissions

    # Task 2: Deploy as user in container (Docker)
    startFunction start
    startFunction exec-app ./start.sh deployDirect

    # Task 2: Deploy as user in system (Switch from root to user)
    #if [ -z "${RUN_AS_USERNAME}" ]; then echo 'Error variable RUN_AS_USERNAME is empty!'; exit 1; fi
    #runuser -u ${RUN_AS_USERNAME} -- ./start.sh deployDirect

    # Task 2: Deploy directly (Webhosting)
    #startFunction deployDirect
}

# Deploy directly (In Docker container or Webhosting)
deployDirect() {
    # For in Container or Webhosting (SSH-Key for private repositories needed)
    #gitPull origin ${GIT_BRANCH}

    composerInstall
    symfonyUpdateDatabase
    symfonyClearCache
}

loadEnvironmentVariables
if [ -z "${BIN_PHP}" ]; then BIN_PHP=$(findBinaryByWhich php); fi
if [ -z "${BIN_COMPOSER}" ]; then BIN_COMPOSER=$(findBinaryByWhich composer); fi
GIT_BRANCH="${GIT_BRANCH:-master}"
RUN_AS_USERNAME=${RUN_AS_USERNAME:-}

setDockerComposeFile
if [ ! -e "${DOCKER_COMPOSE_FILE}" ]; then
    echo "Docker compose file '${DOCKER_COMPOSE_FILE}' not found!"; exit 1
fi

startFunction() {
    case ${1} in
        start)
            startFunction pull && \
            startFunction build && \
            startFunction up
        ;;
        up)
            dockerComposeCmd up -d
        ;;
        down)
            dockerComposeCmd down --remove-orphans
        ;;
        login-root)
            dockerComposeCmd exec app bash
        ;;
        login)
            startFunction bash
        ;;
        bash)
            dockerComposeCmd exec -u ${APPLICATION_USER} app bash
        ;;
        zsh)
            dockerComposeCmd exec -u ${APPLICATION_USER} app zsh
        ;;
        exec-app)
            dockerComposeCmd exec -u ${APPLICATION_USER} app "${@:2}"
        ;;
        deploy-images)
          deployImages
        ;;
        deploy)
            runDeploy
        ;;
        deployDirect)
            deployDirect
        ;;
        *)
            dockerComposeCmd "${@:1}"
        ;;
    esac
}

startFunction "${@:1}"
exit $?
