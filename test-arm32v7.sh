#!/usr/bin/env bash

# @todo Testing on amd processor not working, but works on live arm32v7 processor

dockerImage='test/desktop:arm32v7'
dockerContainer='test_desktop_arm32v7'

removeContainer() {
  if [ "$(docker ps -a | grep ${dockerContainer})" ]; then
    docker stop ${dockerContainer}
  fi
  if [ "$(docker ps -a | grep ${dockerContainer})" ]; then
    docker rm ${dockerContainer}
  fi
}

docker run --rm --privileged multiarch/qemu-user-static:register --reset

removeContainer
docker build --rm -t ${dockerImage} -f Dockerfile.arm32v7 . && \
docker run --rm -d --name ${dockerContainer} \
  -p 4001:4000 \
  -e PASSWORD="Admin123!" \
  --cap-add=SYS_PTRACE \
  -v /home/${USER}/projects/docker_desktop/storage/downloads:/home/application/Downloads \
  -v /home/${USER}/projects/docker_desktop/storage/.mozilla:/home/application/.mozilla \
  ${dockerImage} && \

docker exec -ti ${dockerContainer} bash
removeContainer
