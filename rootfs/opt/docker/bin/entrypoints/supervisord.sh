#!/usr/bin/env bash

# Start up supervisord
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf

# NOOP (no operation)
source /opt/docker/bin/entrypoints/noop.sh
