FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    TIMEZONE="Europe/Berlin" \
    LANGUAGE="de_DE" \
    LOG_STDOUT="" \
    LOG_STDERR="" \
    APPLICATION_UID=1000 \
    APPLICATION_GID=1000 \
    APPLICATION_USER="application" \
    APPLICATION_GROUP="application" \
    PASSWORD="Admin123!"

RUN apt-get clean && apt-get update && apt-get -y dist-upgrade && \
    apt-get install -y \
        software-properties-common \
        curl wget aria2 git rsync sudo supervisor vim jq \
        locales language-pack-de \
        xfce4 xfce4-terminal xfce4-goodies conky-all \
        x11vnc xvfb net-tools \
        gedit vlc firefox \
        jq python3 python3-pip && \
    apt-get remove -y pm-utils xscreensaver* && \
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "${TIMEZONE}" > /etc/timezone && \
    update-locale LANG="${LANGUAGE}.UTF-8" && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# NoMachine Linux 64bit Debian Package - https://downloads.nomachine.com/linux/?id=1
ENV NOMACHINE_VERSION="8.2.3_4" \
    NOMACHINE_MD5="f54fadba321d34e9745d25ec156bdacc"

RUN NOMACHINE_OS="Linux" && NOMACHINE_ARCHITECTURE="amd64" && \
    NOMACHINE_VERSION_SHORT=`echo ${NOMACHINE_VERSION} | cut -d. -f1-2` && \
    curl -fsSL "https://download.nomachine.com/download/${NOMACHINE_VERSION_SHORT}/${NOMACHINE_OS}/nomachine_${NOMACHINE_VERSION}_${NOMACHINE_ARCHITECTURE}.deb" -o /tmp/nomachine.deb && \
    echo "${NOMACHINE_MD5} /tmp/nomachine.deb" | md5sum -c - && \
    dpkg -i /tmp/nomachine.deb && rm /tmp/nomachine.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Albert Launcher
RUN curl -fsSL https://build.opensuse.org/projects/home:manuelschneid3r/public_key | apt-key add - && \
    echo "deb https://download.opensuse.org/repositories/home:/manuelschneid3r/xUbuntu_$(lsb_release -sr)/ /" > /etc/apt/sources.list.d/home:manuelschneid3r.list && \
    curl -fsSL "https://download.opensuse.org/repositories/home:manuelschneid3r/xUbuntu_$(lsb_release -sr)/Release.key" -o "/etc/apt/trusted.gpg.d/home:manuelschneid3r.asc" && \
    apt-get update && apt-get install -y albert && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Firefox without Snap
ADD rootfs/etc/apt/preferences.d/mozilla-firefox /etc/apt/preferences.d/mozilla-firefox
RUN add-apt-repository -y ppa:mozillateam/ppa && \
    echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:$(lsb_release -sc)";' | tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox && \
    apt-get update && apt -y --allow-downgrades install firefox && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ADD rootfs/ /
RUN chown root:root /usr/local/bin/create-temp

RUN set -x && \
  chmod +x /opt/docker/bin/* && \
  /opt/docker/bin/bootstrap.sh

EXPOSE 4000
EXPOSE 4467/udp
WORKDIR /root
ENTRYPOINT ["/entrypoint"]
CMD ["supervisord"]
#CMD ["noop"]
