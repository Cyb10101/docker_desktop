#!/usr/bin/env bash
set -e

cronLog() {
  echo "$(date '+%F %H:%M') Cron '$(basename ${0})': ${1}"
}

createFolder() {
  if [ ! -d ${1} ]; then
    mkdir -p ${1}
  fi
  if [ ! -d ${1} ]; then
    echo "ERROR: Can not create folder '${1}'!"
    exit 1
  fi
}
