#!/usr/bin/env bash

# Fix special user permissions
APPLICATION_UID=${APPLICATION_UID:-1000}
APPLICATION_GID=${APPLICATION_GID:-1000}
APPLICATION_USER=${APPLICATION_USER:-application}
APPLICATION_GROUP=${APPLICATION_USER:-application}
PASSWORD=${PASSWORD:-Admin123!}

if [[ ! -f /opt/docker/entrypoint.lock ]]; then
  # Add group
  groupadd -g "$APPLICATION_GID" "$APPLICATION_GROUP"

  # Add user
  useradd -u "$APPLICATION_UID" --home "/home/$APPLICATION_USER" --create-home --shell /bin/bash --no-user-group "$APPLICATION_USER"

  # Assign user to group
  usermod -g "$APPLICATION_GROUP" "$APPLICATION_USER"
fi

if [[ ! -f /opt/docker/entrypoint.lock ]]; then
  usermod -aG sudo "$APPLICATION_USER"

  # Set password
  echo "$APPLICATION_USER":"$PASSWORD" | chpasswd

  # Copy files
  cp /root/.shell-methods.sh /home/$APPLICATION_USER/
  cp /root/.bashrc /home/$APPLICATION_USER/

  chown -R "$APPLICATION_USER":"$APPLICATION_GROUP" /home/$APPLICATION_USER
fi