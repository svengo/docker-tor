FROM alpine:3.21.3

# OpenContainers annotations
LABEL org.opencontainers.image.description="Simple Docker container to run a Tor node."
LABEL org.opencontainers.image.licenses="Unlicense"
LABEL org.opencontainers.image.source="https://github.com/svengo/docker-tor"
LABEL org.opencontainers.image.title="docker-tor"
LABEL org.opencontainers.image.url="https://github.com/svengo/docker-tor"
  
# Build-time variables
ARG TOR_VERSION=0.4.8.14
ARG TZ=Europe/Berlin

WORKDIR /tmp

RUN \
  set -o xtrace && \
  apk update && \
  apk upgrade && \
  apk add \
    curl \
    gettext \
    libcap \
    libevent \
    su-exec \
    xz-libs \
    zlib \
    zstd-libs && \
  apk add --virtual build \
    build-base \
    ca-certificates \
    gnupg \
    gnupg-keyboxd \
    libcap-dev \
    libevent-dev \
    openssl-dev \
    xz-dev \
    zlib-dev \
    zstd-dev && \
  \
  CURL_OPTIONS="--no-progress-meter --fail --location --remote-name" && \
  curl ${CURL_OPTIONS} "https://dist.torproject.org/tor-${TOR_VERSION}.tar.gz" && \
  curl ${CURL_OPTIONS} "https://dist.torproject.org/tor-${TOR_VERSION}.tar.gz.sha256sum" && \
  curl ${CURL_OPTIONS} "https://dist.torproject.org/tor-${TOR_VERSION}.tar.gz.sha256sum.asc" && \
  gpg --recv-keys 514102454D0A87DB0767A1EBBE6A0531C18A9179 \
    B74417EDDF22AC9F9E90F49142E86A2A11F48D36 \
    2133BC600AB133E1D826D173FE43009C4607B1FB && \
  sha256sum -c "tor-${TOR_VERSION}.tar.gz.sha256sum" && \
  gpg --verify "tor-${TOR_VERSION}.tar.gz.sha256sum.asc" && \
  tar -zxf "tor-${TOR_VERSION}.tar.gz" && \
  \
  cd tor-${TOR_VERSION} && \
  ./configure \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --prefix=/usr \
    --disable-gcc-warnings-advisory \
    --disable-asciidoc \
    --disable-html-manual \
    --disable-manpage \
    --enable-lzma \
    --enable-zstd \
    --silent && \
  \
  CFLAGS=-Wno-cpp make && \
  \
  make test && \
  \
  make install && \
  \
  apk del build && \
  rm -rf /tmp/* && \
  rm -rf /var/cache/apk/* && \
  \
  addgroup -S tor && \
  adduser -s /bin/false -SDH -G tor tor

VOLUME /data
WORKDIR /data

COPY torrc-defaults-source /etc/tor/
COPY config.sh /config.sh
COPY entry-point.sh /entrypoint.sh
COPY healthcheck.sh /healthcheck.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["tor", "-f", "/data/torrc"]

HEALTHCHECK --timeout=5s CMD /healthcheck.sh
