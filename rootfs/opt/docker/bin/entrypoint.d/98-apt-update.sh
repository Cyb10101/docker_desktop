#!/usr/bin/env bash

if [[ ! -f /opt/docker/entrypoint.lock ]]; then
  apt-get update
fi
