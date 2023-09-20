FROM alpine:3.18.3

# Build-time variables
ARG TOR_VERSION=0.4.8.6
ARG TZ=Europe/Berlin

WORKDIR /tmp

RUN \
  echo "::group::Install required packages" && \
  set -o xtrace && \
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
  echo "::endgroup::" && \
  \
  echo "::group::Download Tor" && \
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
  echo "::endgroup::" && \
  \
  echo "::group::Configure" && \
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
  echo "::endgroup::" && \
  echo "::group::Build" && \
  CFLAGS=-Wno-cpp make && \
  echo "::endgroup::" && \
  echo "::group::Test" && \
  make test && \
  echo "::group::Install" && \
  make install && \
  echo "::endgroup::" && \
  \
  echo "::group::Cleanup" && \
  apk del build && \
  rm -rf /tmp/* && \
  rm -rf /var/cache/apk/* && \
  echo "::endgroup::" && \
  \
  echo "::group::Add tor user and group" && \
  addgroup -S tor && \
  adduser -s /bin/false -SDH -G tor tor && \
  echo "::endgroup::"

VOLUME /data
WORKDIR /data

COPY torrc-defaults-source /etc/tor/
COPY docker-entry-point.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["tor", "-f", "/data/torrc"]

HEALTHCHECK --timeout=5s CMD echo quit | curl -sS telnet://localhost:${ORPORT} && \
  curl -sSf http://localhost:${DIRPORT}/tor/server/authority || exit 1
