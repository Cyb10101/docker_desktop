#!/usr/bin/env bash

dockerImage='test/desktop'
dockerContainer='test_desktop'

removeContainer() {
  if [ "$(docker ps -a | grep ${dockerContainer})" ]; then
    docker stop ${dockerContainer}
  fi
  if [ "$(docker ps -a | grep ${dockerContainer})" ]; then
    docker rm ${dockerContainer}
  fi
}

removeContainer
docker build --rm -t ${dockerImage} -f Dockerfile . && \
docker run --rm -d --name ${dockerContainer} \
  -p 4001:4000 \
  -e PASSWORD="Admin123!" \
  --cap-add=SYS_PTRACE \
  -v /home/${USER}/projects/docker_desktop/storage/downloads:/home/application/Downloads \
  -v /home/${USER}/projects/docker_desktop/storage/.mozilla:/home/application/.mozilla \
  -v /home/${USER}/projects/docker_desktop/storage/jd2:/home/application/jd2 \
  ${dockerImage} && \

docker exec -ti ${dockerContainer} bash
removeContainer
