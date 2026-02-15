# Stage 1: Builder
FROM alpine:3.23.3 AS builder

ARG TOR_VERSION=0.4.8.22

RUN apk add --no-cache \
  build-base \
  ca-certificates \
  curl \
  gnupg \
  gnupg-keyboxd \
  libcap-dev \
  libevent-dev \
  openssl-dev \
  xz-dev \
  zlib-dev \
  zstd-dev

WORKDIR /tmp

RUN \
  CURL_OPTIONS="--no-progress-meter --fail --location --remote-name" && \
  curl ${CURL_OPTIONS} "https://dist.torproject.org/tor-${TOR_VERSION}.tar.gz" && \
  curl ${CURL_OPTIONS} "https://dist.torproject.org/tor-${TOR_VERSION}.tar.gz.sha256sum" && \
  curl ${CURL_OPTIONS} "https://dist.torproject.org/tor-${TOR_VERSION}.tar.gz.sha256sum.asc" && \
  gpg --keyserver hkps://keys.openpgp.org --recv-keys \
  514102454D0A87DB0767A1EBBE6A0531C18A9179 \
  B74417EDDF22AC9F9E90F49142E86A2A11F48D36 \
  2133BC600AB133E1D826D173FE43009C4607B1FB && \
  sha256sum -c "tor-${TOR_VERSION}.tar.gz.sha256sum" && \
  gpg --verify "tor-${TOR_VERSION}.tar.gz.sha256sum.asc" && \
  tar -zxf "tor-${TOR_VERSION}.tar.gz" && \
  cd "tor-${TOR_VERSION}" && \
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
  make -j$(nproc) && \
  make test && \
  make install

# Stage 2: Final
FROM alpine:3.23.3

RUN apk add --no-cache \
  ca-certificates \
  curl \
  gettext \
  libcap \
  libevent \
  xz-libs \
  zlib \
  zstd-libs \
  tzdata \
  && addgroup -S tor \
  && adduser -s /bin/false -SDH -G tor tor \
  && mkdir -p /data \
  && chown -R tor:tor /data /etc/tor \
  && cp /usr/share/zoneinfo/${TZ} /etc/localtime \
  && echo ${TZ} > /etc/timezone

COPY --from=builder --chown=tor:tor /usr/bin/tor* /usr/bin/
COPY --from=builder --chown=tor:tor /usr/share/tor/* /usr/share/tor/
COPY --from=builder --chown=tor:tor /etc/tor/* /etc/tor/

USER tor
VOLUME /data
WORKDIR /data

COPY --chown=tor:tor torrc-defaults-source /etc/tor/
COPY --chown=tor:tor config.sh /config.sh
COPY --chown=tor:tor entry-point.sh /entrypoint.sh
COPY --chown=tor:tor healthcheck.sh /healthcheck.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["tor", "-f", "/data/torrc"]

HEALTHCHECK --timeout=5s CMD /healthcheck.sh
