FROM ubuntu:18.04
# @todo Not so nice: ubuntu:20.04

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
        curl wget aria2 git rsync sudo supervisor vim \
        locales language-pack-de \
        xfce4 xfce4-terminal xfce4-goodies conky-all \
        x11vnc xvfb net-tools \
        gedit vlc \
        firefox firefox-locale-de && \
    apt-get remove -y pm-utils xscreensaver* && \
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "${TIMEZONE}" > /etc/timezone && \
    update-locale LANG="${LANGUAGE}.UTF-8" && \
    apt-get -y autoclean && apt-get -y autoremove && rm -rf /var/lib/apt/lists/*

# NoMachine
ENV NOMACHINE_OS="Linux" \
    NOMACHINE_VERSION="7.1" \
    NOMACHINE_PACKAGE_NAME="nomachine_7.1.3_1_amd64.deb" \
    NOMACHINE_MD5="d833ad52f92e5b3cc30c96f12686d97f"

RUN curl -fSL "https://download.nomachine.com/download/${NOMACHINE_VERSION}/${NOMACHINE_OS}/${NOMACHINE_PACKAGE_NAME}" -o nomachine.deb && \
    echo "${NOMACHINE_MD5} nomachine.deb" | md5sum -c - && \
    dpkg -i nomachine.deb

# Albert Launcher
RUN curl https://build.opensuse.org/projects/home:manuelschneid3r/public_key | sudo apt-key add - && \
    echo "deb http://download.opensuse.org/repositories/home:/manuelschneid3r/xUbuntu_$(lsb_release -sr)/ /" > /etc/apt/sources.list.d/home:manuelschneid3r.list && \
    wget -nv https://download.opensuse.org/repositories/home:manuelschneid3r/xUbuntu_$(lsb_release -sr)/Release.key -O "/etc/apt/trusted.gpg.d/home:manuelschneid3r.asc" && \
    apt-get update && apt install -y albert && \
    apt-get -y autoclean && apt-get -y autoremove && rm -rf /var/lib/apt/lists/*

ADD rootfs/ /

RUN set -x && \
  chmod +x /opt/docker/bin/* && \
  /opt/docker/bin/bootstrap.sh

EXPOSE 4000
EXPOSE 4467/udp
WORKDIR /root
ENTRYPOINT ["/entrypoint"]
CMD ["supervisord"]
#CMD ["noop"]
