#!/usr/bin/env bash

# Fix special user permissions
APPLICATION_USER=${APPLICATION_USER:-application}

echo 'XFCE_PANEL_MIGRATE_DEFAULT=1' > /etc/environment

sudo rsync -a --relative /root/./.config/xfce4 /home/${APPLICATION_USER}/
sudo chown -R ${APPLICATION_USER}:${APPLICATION_USER} /home/${APPLICATION_USER}
