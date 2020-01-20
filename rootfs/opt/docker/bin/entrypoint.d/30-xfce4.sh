#!/usr/bin/env bash

APPLICATION_USER=${APPLICATION_USER:-application}
DISPLAY_WIDTH=${DISPLAY_WIDTH:-1280}
DISPLAY_HEIGHT=${DISPLAY_HEIGHT:-768}

if [[ ! -f /opt/docker/entrypoint.lock ]]; then
  echo 'XFCE_PANEL_MIGRATE_DEFAULT=1' > /etc/environment

  sed -i -r "s/(<property name=\"Resolution\" .* value=\")[0-9]+x[0-9]+(\"\/>)/\1${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}\2/g" /root/.config/xfce4/xfconf/xfce-perchannel-xml/displays.xml

  sudo rsync -a --relative /root/./.config/xfce4 /home/${APPLICATION_USER}/
  sudo chown -R ${APPLICATION_USER}:${APPLICATION_USER} /home/${APPLICATION_USER}
fi
