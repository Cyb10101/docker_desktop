FROM ubuntu

ENV DEBIAN_FRONTEND=noninteractive \
    TIMEZONE="Europe/Berlin" \
    LANGUAGE="de_DE" \
    DISPLAY_WIDTH=1280 \
    DISPLAY_HEIGHT=768 \
    LOG_STDOUT="" \
    LOG_STDERR="" \
    APPLICATION_UID=1000 \
    APPLICATION_GID=1000 \
    APPLICATION_USER="application" \
    APPLICATION_GROUP="application" \
    PASSWORD="Admin123!"

RUN apt-get clean && apt-get update && \
    apt-get install -y \
        curl git rsync sudo supervisor vim \
        locales language-pack-de \
        xfce4 xfce4-terminal xfce4-goodies \
        x11vnc xvfb net-tools \
        firefox firefox-locale-de && \
    apt-get remove -y pm-utils xscreensaver* && \
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "${TIMEZONE}" > /etc/timezone && \
    update-locale LANG="${LANGUAGE}.UTF-8" && \
    apt-get -y autoclean && apt-get -y autoremove && rm -rf /var/lib/apt/lists/*

ENV NOMACHINE_BUILD="6.9" \
    NOMACHINE_VERSION="6.9.2_1_amd64" \
    NOMACHINE_MD5="86fe9a0f9ee06ee6fce41aa36674f727"

RUN curl -fSL "https://download.nomachine.com/download/${NOMACHINE_BUILD}/Linux/nomachine_${NOMACHINE_VERSION}.deb" -o nomachine.deb && \
    echo "${NOMACHINE_MD5} *nomachine.deb" | md5sum -c - && \
    dpkg -i nomachine.deb

ADD rootfs/ /

RUN set -x && \
  chmod +x /opt/docker/bin/* && \
  /opt/docker/bin/bootstrap.sh

EXPOSE 4000
WORKDIR /root
ENTRYPOINT ["/entrypoint"]
CMD ["supervisord"]
#CMD ["noop"]
