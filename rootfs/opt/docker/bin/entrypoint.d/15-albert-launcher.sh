#!/usr/bin/env bash

albertLauncherDisabled=${albertLauncherDisabled:-}
if [ "${albertLauncherDisabled}" == "true" ]; then
    rm /root/.config/autostart/albert.desktop
fi
