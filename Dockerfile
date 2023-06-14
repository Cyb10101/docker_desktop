FROM ubuntu:22.04

RUN mkdir -p /opt/docker && echo "amd64" > /opt/docker/architecture
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

# NoMachine Linux 64bit Debian Package - https://downloads.nomachine.com/linux/?id=1
ENV NOMACHINE_OS="Linux" NOMACHINE_ARCHITECTURE="amd64" \
    NOMACHINE_VERSION="8.5.3_1" \
    NOMACHINE_MD5="91e3e70e3de7bc062151b9b771838f93"

ADD rootfs/opt/docker/bin/bootstrap.sh /opt/docker/bin/bootstrap.sh
ADD rootfs/etc/apt/preferences.d/mozilla-firefox /etc/apt/preferences.d/mozilla-firefox
ADD rootfs/usr/local/bin/create-temp /usr/local/bin/create-temp
RUN chmod +x /opt/docker/bin/bootstrap.sh && /opt/docker/bin/bootstrap.sh

ADD rootfs/ /
RUN chmod +x /opt/docker/bin/*

EXPOSE 4000
EXPOSE 4467/udp
WORKDIR /root
ENTRYPOINT ["/entrypoint"]
CMD ["supervisord"]
#CMD ["noop"]
