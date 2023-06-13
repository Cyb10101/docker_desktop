#!/usr/bin/env bash

# Fix special user permissions
APPLICATION_USER=${APPLICATION_USER:-application}

if [ ! -f /opt/docker/entrypoint.lock ]; then
  if [ -f /home/${APPLICATION_USER}/.config/autostart/conky.desktop ]; then
    sed -i -r "s/\/root\//\/home\/${APPLICATION_USER}\//g" /home/${APPLICATION_USER}/.config/autostart/conky.desktop
  fi

  if [ -f /home/${APPLICATION_USER}/.config/conky/conky.lua ]; then
    sed -i -r "s/\/root\//\/home\/${APPLICATION_USER}\//g" /home/${APPLICATION_USER}/.config/conky/conky.lua
  fi

  if [ -f /home/${APPLICATION_USER}/.config/conky/conky.sh ]; then
    sed -i -r "s/\/root\//\/home\/${APPLICATION_USER}\//g" /home/${APPLICATION_USER}/.config/conky/conky.sh
  fi
fi
