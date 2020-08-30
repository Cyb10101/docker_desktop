FROM ubuntu:18.04
# @todo No so nice: ubuntu:20.04

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
        curl git rsync sudo supervisor vim \
        locales language-pack-de \
        xfce4 xfce4-terminal xfce4-goodies conky-all \
        x11vnc xvfb net-tools \
        firefox firefox-locale-de && \
    apt-get remove -y pm-utils xscreensaver* && \
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "${TIMEZONE}" > /etc/timezone && \
    update-locale LANG="${LANGUAGE}.UTF-8" && \
    apt-get -y autoclean && apt-get -y autoremove && rm -rf /var/lib/apt/lists/*

ENV NOMACHINE_OS="Linux" \
    NOMACHINE_VERSION="6.11" \
    NOMACHINE_PACKAGE_NAME="nomachine_6.11.2_1_amd64.deb" \
    NOMACHINE_MD5="d268d38823489c9b3cffd5d618c05b22"

RUN curl -fSL "https://download.nomachine.com/download/${NOMACHINE_VERSION}/Linux/${NOMACHINE_PACKAGE_NAME}" -o nomachine.deb && \
    echo "${NOMACHINE_MD5} nomachine.deb" | md5sum -c - && \
    dpkg -i nomachine.deb

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
