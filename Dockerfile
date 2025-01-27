FROM alpine:3.21.2

# Build-time variables
ARG TOR_VERSION=0.4.8.13
ARG TZ=America/Los_Angeles

# Environment variables
ENV RELAY_PORT=9001
ENV METRICS_PORT=9052
ENV DIR_PORT=9030
ENV RELAY_BANDWIDTH_RATE=81920
ENV RELAY_BANDWIDTH_BURST=102400
ENV TOR_SOCKS_PORT=0.0.0.0:9050
ENV EXTERNAL_ADDRESS=auto
ENV CONTROL_PORT=127.0.0.1:9051

WORKDIR /tmp

RUN \
  set -o xtrace && \
  apk update && \
  apk add \
    curl \
    gettext \
    libcap \
    libevent \
    su-exec \
    xz-libs \
    zlib \
    zstd-libs \
    nyx && \
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
  gpg --auto-key-locate nodefault,wkd --locate-keys ahf@torproject.org \
    dgoulet@torproject.org \
    nickm@torproject.org && \
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
  adduser -s /bin/false -SDH -G tor tor && \
  echo "HashedControlPassword 16:2565CFA67C16BE1C60ADB80B439895789609914A901BD3231B02F9DB86" >> /etc/tor/torrc-defaults-source

VOLUME /data
WORKDIR /data

COPY torrc-defaults-source /etc/tor/
COPY config.sh /config.sh
COPY entry-point.sh /entrypoint.sh
COPY healthcheck.sh /healthcheck.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["tor", "-f", "/data/torrc"]

HEALTHCHECK --timeout=5s CMD /healthcheck.sh
