#!/usr/bin/env bash

# Start up supervisord
/usr/bin/supervisord

# NOOP (no operation)
source /opt/docker/bin/entrypoints/noop.sh
