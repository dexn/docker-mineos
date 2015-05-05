FROM phusion/baseimage:0.9.11
MAINTAINER DexN

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Installing Dependencies
RUN apt-get update; \
    apt-get -y install screen python-cherrypy3 rdiff-backup git openjdk-7-jre-headless; \
    apt-get -y install openssh-server uuid

# Installing MineOS scripts
RUN mkdir -p /usr/games /var/games/minecraft; \
    git clone git://github.com/hexparrot/mineos /usr/games/minecraft; \
    cd /usr/games/minecraft; \
    git config core.filemode false; \
    chmod +x server.py mineos_console.py generate-sslcert.sh; \
    ln -s /usr/games/minecraft/mineos_console.py /usr/local/bin/mineos

# Customize server settings
ADD mineos.conf /usr/games/minecraft/mineos.conf
RUN mkdir -p /etc/my_init.d
RUN cp /usr/games/minecraft/init/mineos /etc/my_init.d/; \
    chmod 744 /etc/my_init.d/mineos
RUN cp /usr/games/minecraft/init/minecraft /etc/my_init.d/; \
    chmod 744 /etc/my_init.d/minecraft
RUN mkdir /var/games/minecraft/ssl_certs; \
    mkdir /var/games/minecraft/log; \
    mkdir /var/games/minecraft/run

# Add start script
ADD start.sh /usr/games/minecraft/start.sh
RUN chmod +x /usr/games/minecraft/start.sh

# Add minecraft user and change owner files.
RUN useradd -s /bin/bash -d /usr/games/minecraft -m minecraft; \
    usermod -G sudo minecraft; \
    sed -i 's/%sudo.*/%sudo   ALL=(ALL:ALL) NOPASSWD:ALL/' /etc/sudoers; \
    chown -R minecraft:minecraft /usr/games/minecraft /var/games/minecraft

# Cleaning
RUN apt-get clean

VOLUME /var/games/minecraft
WORKDIR /usr/games/minecraft
EXPOSE 22 8443 25565

ENTRYPOINT ["./start.sh"]
