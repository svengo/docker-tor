FROM alpine:3.18.2

# Build-time variables
ARG TOR_VERSION
ARG TZ=Europe/Berlin
ARG BUILD_DATE
ARG VCS_REF
ARG CURL_OPTIONS="--no-progress-meter --fail --location --remote-name"

# Build-time metadata as defined at http://label-schema.org
LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.name="docker-tor" \
  org.label-schema.description="Simple docker container for a tor node" \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.vcs-url="https://github.com/svengo/docker-tor" \
  org.label-schema.vendor="Sven Gottwald" \
  org.label-schema.version=$TOR_VERSION \
  org.label-schema.schema-version="1.0"

WORKDIR /tmp

RUN \
  set -o xtrace && \
  if test -z "$TOR_VERSION" ; then echo ERROR: TOR_VERSION not provided && exit 1; fi && \
  \
  apk update && \
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
  curl ${CURL_OPTIONS} "https://dist.torproject.org/tor-${TOR_VERSION}.tar.gz" && \
  curl ${CURL_OPTIONS} "https://dist.torproject.org/tor-${TOR_VERSION}.tar.gz.sha256sum" && \
  curl ${CURL_OPTIONS} "https://dist.torproject.org/tor-${TOR_VERSION}.tar.gz.sha256sum.asc" && \
  gpg --auto-key-locate nodefault,wkd --locate-keys ahf@torproject.org \
    dgoulet@torproject.org \
    nickm@torproject.org && \
  sha256sum -c "tor-${TOR_VERSION}.tar.gz.sha256sum" && \
  gpg --verify "tor-${TOR_VERSION}.tar.gz.sha256sum.asc" && \
  \
  tar -zxf "tor-${TOR_VERSION}.tar.gz" && \
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
  CFLAGS=-Wno-cpp make && \
  make test && \
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
COPY docker-entry-point.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["tor", "-f", "/data/torrc"]

HEALTHCHECK --timeout=5s CMD echo quit | curl -sS telnet://localhost:${ORPORT} && \
  curl -sSf http://localhost:${DIRPORT}/tor/server/authority || exit 1
