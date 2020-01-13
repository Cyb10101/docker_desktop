#!/usr/bin/env bash

if [[ ! -f /opt/docker/entrypoint.lock ]]; then
  touch /opt/docker/entrypoint.lock
else
  echo 'Entrypoint locked!'
fi;
