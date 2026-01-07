FROM alpine:3.23 as builder

ARG ICECAST_VERSION="2.5.0" \
    LIBIGLOO_VERSION="0.9.5"

RUN apk update && \
    apk upgrade && \
    apk add --upgrade --no-cache --virtual=build-dependencies \
        build-base \
        coreutils \
        curl \
        curl-dev \
        libxslt-dev \
        libxml2-dev \
        libogg-dev \
        libvorbis-dev \
        libtheora-dev \
        speex-dev \
        openssl-dev \
        rhash-dev \
        autoconf \
        automake \
        libtool

WORKDIR /build

RUN wget https://downloads.xiph.org/releases/igloo/libigloo-$LIBIGLOO_VERSION.tar.gz -O /build/libigloo-$LIBIGLOO_VERSION.tar.gz && \
    wget https://downloads.xiph.org/releases/igloo/SHA512SUMS.txt -O /build/igloo-SHA512SUMS.txt && \
    sha512sum --ignore-missing --check igloo-SHA512SUMS.txt && \
    tar -xvf libigloo-$LIBIGLOO_VERSION.tar.gz -C .

WORKDIR /build/libigloo-$LIBIGLOO_VERSION

RUN ./configure --prefix=/usr
RUN make check
RUN make install
RUN make install DESTDIR=/build/output

WORKDIR /build

RUN wget https://downloads.xiph.org/releases/icecast/icecast-$ICECAST_VERSION.tar.gz -O /build/icecast-$ICECAST_VERSION.tar.gz && \
    wget https://downloads.xiph.org/releases/icecast/SHA512SUMS.txt -O /build/icecast-SHA512SUMS.txt && \
    sha512sum --ignore-missing --check icecast-SHA512SUMS.txt && \
    tar -xvf icecast-$ICECAST_VERSION.tar.gz -C .
    
WORKDIR /build/icecast-$ICECAST_VERSION

RUN ./configure \
	    --prefix=/usr \
		--localstatedir=/var \
		--sysconfdir=/etc \
		--mandir=/usr/share/man \
		--infodir=/usr/share/info \
		--with-curl

RUN make install DESTDIR=/build/output

FROM alpine:3.23

LABEL name="docker-icecast" \
      maintainer="Jee jee@jeer.fr" \
      description="Icecast is free server software for streaming multimedia." \
      url="https://icecast.org" \
      org.label-schema.vcs-url="https://github.com/jee-r/docker-icecast" \
      org.opencontainers.image.source="https://github.com/jee-r/docker-icecast"

COPY rootfs /

RUN apk update && \
    apk upgrade && \
    apk add --upgrade --no-cache --virtual=base \
        curl \
        libxslt \
        libxml2 \
        libogg \
        libvorbis \
        libtheora \
        speex \
        openssl \
        rhash-libs \
        mailcap \
        tzdata && \
    chmod -R 777 /config && \
    rm -rf /tmp/* 

COPY --from=builder /build/output /

EXPOSE 8000

WORKDIR /config

HEALTHCHECK --interval=1m --timeout=10s --start-period=30s --retries=5 \
    CMD curl --fail --silent --show-error --output /dev/null --write-out "%{http_code}"  http://127.0.0.1:8000/status-json.xsl || exit 1
STOPSIGNAL SIGQUIT
ENTRYPOINT ["icecast", "-c", "/config/icecast.xml"]