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
apt-get -y install software-properties-common wget

# Add repositories
add-apt-repository -y --no-update universe

# Add repository to install Firefox
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc 1>/dev/null
fingerprint=$(gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); print $0}')
if [ "${fingerprint}" != "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3" ]; then
    echo "Verification failed: The fingerprint (${fingerprint}) does not match\!"; exit 1
fi
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee -a /etc/apt/sources.list.d/mozilla.list 1>/dev/null
printf "Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1001" | tee /etc/apt/preferences.d/mozilla 1>/dev/null

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
    curl aria2 git rsync supervisor vim \
    htop net-tools \
    jq python3 python3-pip \
    conky-all gedit mpv
    # vlc x11vnc xvfb

pip3 install yq

# Install XFCE4
apt-get -y install xfce4 xfce4-terminal xfce4-goodies gnome-backgrounds
apt-get -y remove pm-utils xscreensaver*

# Install Firefox
apt-get -y install firefox speech-dispatcher

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
