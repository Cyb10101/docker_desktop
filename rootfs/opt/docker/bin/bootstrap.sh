#!/usr/bin/env bash
set -e

createEntrypoint() {
    ln -sf /opt/docker/bin/entrypoint.sh /entrypoint

    # Create /entrypoint.d
    mkdir -p /entrypoint.d
    chmod 700 /entrypoint.d
    chown root:root /entrypoint.d

    echo '#!/usr/bin/env bash' > /entrypoint.d/placeholder.sh
    echo "echo 'Custom entrypoint'" >> /entrypoint.d/placeholder.sh
    chmod 700 /entrypoint.d/placeholder.sh
}

# Clean apt
apt-get clean

# Install add-apt-repository
apt-get update
apt-get -y install software-properties-common

# Add repositories
add-apt-repository -y --no-update universe

# Add repository to install Firefox without Snap
add-apt-repository -y --no-update ppa:mozillateam/ppa
echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:$(lsb_release -sc)";' | tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox

# Update packages
apt-get update
apt-get -y dist-upgrade

# Set timezone and locale
apt-get -y install locales language-pack-de
echo "${TIMEZONE}" > /etc/timezone
update-locale LANG="${LANGUAGE}.UTF-8"

# Create entrypoint
createEntrypoint

# Install sudo
apt-get -y install sudo
echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
visudo --check /etc/sudoers

# Install apps
apt-get -y install \
    curl wget aria2 git rsync supervisor vim \
    htop net-tools \
    jq python3 python3-pip \
    conky-all gedit mpv
    # vlc x11vnc xvfb

pip3 install yq

# Install XFCE4
apt-get -y install xfce4 xfce4-terminal xfce4-goodies gnome-backgrounds
apt-get -y remove pm-utils xscreensaver*

# Install Firefox without Snap
apt-get -y --allow-downgrades install firefox

# Install Nomachine
NOMACHINE_VERSION_SHORT=`echo ${NOMACHINE_VERSION} | cut -d. -f1-2`
curl --progress-bar -o /tmp/nomachine.deb -fL "https://download.nomachine.com/download/${NOMACHINE_VERSION_SHORT}/${NOMACHINE_OS}/nomachine_${NOMACHINE_VERSION}_${NOMACHINE_ARCHITECTURE}.deb"
echo "${NOMACHINE_MD5} /tmp/nomachine.deb" | md5sum -c -
dpkg -i /tmp/nomachine.deb && rm /tmp/nomachine.deb

# Set permissions
chown root:root /usr/local/bin/create-temp

# Clean apt
apt-get clean
rm -rf /var/lib/apt/lists/*
