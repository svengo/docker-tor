# Multi-Stage build - https://goo.gl/qejG4w
FROM golang:alpine as confd

ARG CONFD_VERSION=0.16.0

WORKDIR /tmp
RUN \
  apk add --no-cache \
    bzip2 \
    make \
    wget && \
  wget --no-verbose https://github.com/kelseyhightower/confd/archive/v${CONFD_VERSION}.tar.gz && \
  mkdir -p /go/src/github.com/kelseyhightower/confd && \
  cd /go/src/github.com/kelseyhightower/confd && \
  tar --strip-components=1 -zxf /tmp/v${CONFD_VERSION}.tar.gz && \
  go install github.com/kelseyhightower/confd && \
  rm -rf /tmp/v${CONFD_VERSION}.tar.gz


FROM alpine:latest

ARG TOR_VERSION=0.4.4.8
ARG BUILD_DATE
ARG VCS_REF

# Build-time metadata as defined at http://label-schema.org
LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.name="docker-tor" \
  org.label-schema.description="Simple docker container for a tor node" \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.vcs-url="https://github.com/svengo/docker-tor" \
  org.label-schema.vendor="Sven Gottwald" \
  org.label-schema.version=$TOR_VERSION \
  org.label-schema.schema-version="1.0"

COPY --from=confd /go/bin/confd /usr/bin/confd

WORKDIR /tmp
RUN \
  apk add --update \
    curl \
    libcap \
    libevent \
    openssl \
    su-exec \
    xz-libs \
    zlib \
    zstd \
    zstd-libs && \
  apk add --virtual build \
    build-base \
    ca-certificates \
    gnupg \
    libcap-dev \
    libevent-dev \
    linux-headers \
    openssl-dev \
    w3m \
    wget \
    xz-dev \
    zlib-dev \
    zstd-dev && \
  \
  wget --no-verbose https://www.torproject.org/dist/tor-${TOR_VERSION}.tar.gz && \
  wget --no-verbose https://www.torproject.org/dist/tor-${TOR_VERSION}.tar.gz.asc && \
  gpg --keyserver ipv4.pool.sks-keyservers.net --recv-keys \
    0x6AFEE6D49E92B601 \
    0x28988BF5 \
    0x19F78451 && \
  gpg --verify tor-${TOR_VERSION}.tar.gz.asc && \
  \
  export "CFLAGS=-Wno-cpp" && \
  \
  tar -zxf tor-${TOR_VERSION}.tar.gz && \
  cd tor-${TOR_VERSION} && \
  ./configure \ 
    --disable-gcc-warnings-advisory \
    --localstatedir=/var \
    --prefix=/usr \
    --silent \
    --sysconfdir=/etc && \
  make && \
  make test && \
  make install && \
  \
  apk del build && \
  rm -rf /tmp/* && \
  rm -rf /var/cache/apk/* && \
  \
  addgroup -S tor && \
  adduser -s /bin/false -SDH -G tor tor && \
  mkdir -p /etc/confd/conf.d && \
  mkdir -p /etc/confd/templates
  
VOLUME /data
WORKDIR /data

COPY torrc-defaults.toml /etc/confd/conf.d
COPY torrc-defaults.tmpl /etc/confd/templates

COPY docker-entry-point.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 9001 9030
CMD ["tor", "-f", "/data/torrc"]

HEALTHCHECK --timeout=5s CMD echo quit | curl -sS telnet://localhost:${ORPORT:-9001} && curl -sSf http://localhost:${DIRPORT:-9030}/tor/server/authority || exit 1
