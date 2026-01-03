FROM alpine:3.23 AS builder

ARG ICECAST_VERSION="2.5.0" \
    SHA512="d92ce5d8ae1cd011eaa8c7424adea744f35e5c2d3e8244d362743be1c6bbc8fc44d76d7a212cf1eebe79da9b7d83b2ed5ab8659fb97929af316674b5ddf590b5"

RUN apk update && \
    apk upgrade && \
    apk add --upgrade --no-cache --virtual=build-dependencies \
        autoconf \
        automake \
        build-base \
        coreutils \
        curl-dev \
        git \
        pkgconfig \
        libtool \
        libxslt-dev \
        libxml2-dev \
        libogg-dev \
        libvorbis-dev \
        libtheora-dev \
        speex-dev \
        openssl-dev \
        rhash-dev

WORKDIR /tmp
    
RUN git clone https://gitlab.xiph.org/xiph/icecast-libigloo.git && \
    cd icecast-libigloo && \
    ./autogen.sh && \
    ./configure --prefix=/usr && \
    make && \
    make install && \
    rm -rf /tmp/icecast-libigloo

WORKDIR /build

RUN wget https://downloads.xiph.org/releases/icecast/icecast-$ICECAST_VERSION.tar.gz -O /build/icecast-$ICECAST_VERSION.tar.gz && \
    # NOTE: due to a bug SHA512SUMS file provide only beta SHA512SUM so we can not verify the download
    # thank to tbr who help me to find the original sha256"
    # wget https://downloads.xiph.org/releases/icecast/SHA512SUMS.txt -O /build/SHA512SUMS.txt && \ 
    # sha512sum --ignore-missing --check SHA512SUMS.txt && \
    echo "$SHA512 /build/icecast-$ICECAST_VERSION.tar.gz" | sha512sum -c - && \
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
        mailcap \
        rhash \
        tzdata && \
    chmod -R 777 /config && \
    rm -rf /tmp/* 

COPY --from=builder /build/output /
COPY --from=builder /usr/lib/libigloo.so* /usr/lib/
RUN ldconfig /usr/lib

EXPOSE 8000

WORKDIR /config

HEALTHCHECK --interval=1m --timeout=10s --start-period=30s --retries=5 \
    CMD curl --fail --silent --show-error --output /dev/null --write-out "%{http_code}"  http://127.0.0.1:8000/status-json.xsl || exit 1
STOPSIGNAL SIGQUIT
ENTRYPOINT ["icecast", "-c", "/config/icecast.xml"]