#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

NX_PORT=${NX_PORT:-4000}
APPLICATION_GID=${APPLICATION_GID:-1000}
DISPLAY_WIDTH=${DISPLAY_WIDTH:-1280}
DISPLAY_HEIGHT=${DISPLAY_HEIGHT:-768}

if [[ ! -f /opt/docker/entrypoint.lock ]]; then
  groupmod -g $((APPLICATION_GID + 1)) nx
fi

sed -i -r "s/^#?(NXPort).*/\1 ${NX_PORT}/g" /usr/NX/etc/server.cfg
sed -i -r "s/^#?(CreateDisplay).*/\1 1/g" /usr/NX/etc/server.cfg
sed -i -r "s/^#?(DisplayOwner).*/\1 \"${APPLICATION_USER}\"/g" /usr/NX/etc/server.cfg
sed -i -r "s/^#?(DisplayGeometry).*/\1 \"${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}\"/g" /usr/NX/etc/server.cfg
sed -i -r "s/^#?(EnableClipboard).*/\1 both/g" /usr/NX/etc/server.cfg
