FROM alpine:3.19

LABEL name="docker-icecast" \
      maintainer="Jee jee@jeer.fr" \
      description="Icecast is free server software for streaming multimedia." \
      url="https://icecast.org" \
      org.label-schema.vcs-url="https://github.com/jee-r/docker-icecast" \
      org.opencontainers.image.source="https://github.com/jee-r/docker-icecast"

ARG ICECAST_VERSION="2.4.4"

COPY rootfs /

RUN apk update && \
    apk upgrade && \
    apk add --upgrade --no-cache --virtual=build-dependencies \
        build-base \
        curl-dev \
        libxslt-dev \
        libxml2-dev \
        libogg-dev \
        libvorbis-dev \
        libtheora-dev \
        speex-dev \
        openssl-dev && \
    apk add --upgrade --no-cache --virtual=base \
        curl \
        libxslt \
        libxml2 \
        libogg \
        libvorbis \
        libtheora \
        speex \
        openssl \
        mailcap \
        tzdata && \
    wget https://downloads.xiph.org/releases/icecast/icecast-$ICECAST_VERSION.tar.gz -O /tmp/icecast-$ICECAST_VERSION.tar.gz && \
    tar -xvf /tmp/icecast-$ICECAST_VERSION.tar.gz -C /tmp/ && \
    cd /tmp//icecast-$ICECAST_VERSION && \
    ./configure \
		--prefix=/usr \
		--localstatedir=/var \
		--sysconfdir=/etc \
		--mandir=/usr/share/man \
		--infodir=/usr/share/info \
		--with-curl && \
    make check && \
    make install && \
    apk del --purge build-dependencies && \
    chmod -R 777 /config && \
    rm -rf /tmp/* 

EXPOSE 8000

STOPSIGNAL SIGQUIT
ENTRYPOINT ["icecast", "-c", "/config/icecast.xml"]
