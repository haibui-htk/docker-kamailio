FROM callforamerica/debian

MAINTAINER Joe Black <joeblack949@gmail.com>

ARG     KAMAILIO_VERSION
ARG     KAMAILIO_INSTALL_MODS
ARG     KAZOO_CONFIGS_BRANCH

ENV     KAMAILIO_VERSION=${KAMAILIO_VERSION:-4.4.5}
ENV     KAMAILIO_INSTALL_MODS=${KAMAILIO_INSTALL_MODS:-extra,kazoo,outbound,presence,tls,websocket}
ENV     KAZOO_CONFIGS_BRANCH=${KAZOO_CONFIGS_BRANCH:-4.0}

LABEL   app.kamailio.version=$KAMAILIO_VERSION
LABEL   app.kamailio.mods=$KAMAILIO_INSTALL_MODS

ENV     APP kamailio
ENV     USER $APP
ENV     HOME /opt/$APP

COPY    build.sh /tmp/
RUN     /tmp/build.sh

COPY    entrypoint /
COPY    build/kamailio.limits.conf /etc/security/limits.d/
COPY    build/sync-freeswitch /usr/local/bin/
COPY    build/50-kamailio-functions.sh /etc/profile.d/

ENV     KAMAILIO_LOG_LEVEL info
ENV     KAMAILIO_ENABLE_ROLES=websockets,message

# SIP-TCP / SIP-UDP / SIP-TLS
EXPOSE  5060 5060/udp 5061

# WS-TCP / WS-UDP / WSS-TCP / WSS-UDP
EXPOSE  5064 5064/udp 5065 5065/udp

# ALG-TCP / ALG-UDP / ALG-TLS
EXPOSE  7000 7000/udp 7001

VOLUME  ["/volumes/kamailio/dbtext", "/volumes/kamailio/tls"]

WORKDIR $HOME

SHELL       ["/bin/bash"]
HEALTHCHECK --interval=15s --timeout=5s \
    CMD  kamctl monitor 1 | grep -q ^Up || exit 1

ENTRYPOINT  ["/dumb-init", "--"]
CMD         ["/entrypoint"]
