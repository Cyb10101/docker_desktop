#!/usr/bin/env bash

# Fix special user permissions
APPLICATION_USER=${APPLICATION_USER:-application}

if [[ ! -f /opt/docker/entrypoint.lock ]]; then
  sed -i -r "s/\/root\//\/home\/${APPLICATION_USER}\//g" /home/${APPLICATION_USER}/.config/autostart/conky.desktop
  sed -i -r "s/\/root\//\/home\/${APPLICATION_USER}\//g" /home/${APPLICATION_USER}/.config/conky/conky.lua
  sed -i -r "s/\/root\//\/home\/${APPLICATION_USER}\//g" /home/${APPLICATION_USER}/.config/conky/conky.sh
fi
