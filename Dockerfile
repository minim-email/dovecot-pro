FROM ubuntu:focal

SHELL ["/bin/bash", "-c"]

RUN : \
    && apt-get -y update \
    && apt-get -y install \
        ca-certificates \
        tini \
    && rm -rf /var/lib/apt/lists/*

ADD ox-build-key.gpg /etc/apt/trusted.gpg.d/

ARG OX_REPO_USERNAME
ARG OX_REPO_PASSWORD

RUN test -n "$OX_REPO_USERNAME"
RUN test -n "$OX_REPO_PASSWORD"

RUN --mount=type=bind,target=/mnt : \
    && /mnt/format-apt-source-list.sh "$OX_REPO_USERNAME" "$OX_REPO_PASSWORD" \
        > /etc/apt/sources.list.d/dovecot.list \
    && apt-get -y update \
    && apt-get -y install \
        dovecot-ee-* \
    && rm -rf /var/lib/apt/lists/* \
    && rm /etc/apt/sources.list.d/*

# https://github.com/dovecot/docker/blob/main/2.3.20/Dockerfile#L31-L40
RUN : \
    && groupadd -g 1000 vmail \
    && useradd -u 1000 -g 1000 vmail -d /srv/vmail \
    && passwd -l vmail \
    && rm -rf /etc/dovecot \
    && mkdir /srv/mail \
    && chown vmail:vmail /srv/mail \
    && mkdir /etc/dovecot

# https://github.com/dovecot/docker/blob/main/2.3.20/Dockerfile#L44-L54
EXPOSE 24
EXPOSE 110
EXPOSE 143
EXPOSE 587
EXPOSE 990
EXPOSE 993
EXPOSE 4190
VOLUME ["/etc/dovecot", "/srv/mail"]
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/usr/sbin/dovecot", "-F"]
