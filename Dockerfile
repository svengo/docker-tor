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


FROM ubuntu:focal

ARG TOR_VERSION=0.4.5.8
ARG TZ=Europe/Berlin
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
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get -qq install \
    automake \
    build-essential \
    curl \
    libevent-2.1-7 \
    libevent-dev \
    liblzma-dev \
    liblzma5 \
    libssl-dev \
    libssl1.1 \
    libzstd-dev \
    libzstd1 \
    pkg-config \
    python3 \
    zlib1g \
    zlib1g-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  \
  curl -o su-exec.c https://raw.githubusercontent.com/ncopa/su-exec/master/su-exec.c && \
  gcc -Wall su-exec.c -o/usr/bin/su-exec && \
  \
  curl -SL -o tor-${TOR_VERSION}.tar.gz https://www.torproject.org/dist/tor-${TOR_VERSION}.tar.gz && \
  curl -SL -o tor-${TOR_VERSION}.tar.gz.asc https://www.torproject.org/dist/tor-${TOR_VERSION}.tar.gz.asc && \
  gpg --keyserver ipv4.pool.sks-keyservers.net --recv-keys \
	0x6AFEE6D49E92B601 \
	0x28988BF5 \
	0x19F78451 && \
  gpg --verify tor-${TOR_VERSION}.tar.gz.asc && \
  \
  export "CFLAGS=-Wno-cpp" && \
  tar -zxf tor-${TOR_VERSION}.tar.gz && \
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
  make && \
  make test && \
  make install && \
  \
  apt-get remove -y \
    automake \
    build-essential \
    libevent-dev \
    liblzma-dev \
    libssl-dev \
    libzstd-dev \
    pkg-config \
    python3 \
    zlib1g-dev && \
  apt-get autoremove -y && \
  \
  addgroup --system tor && \
  adduser --system --disabled-login --ingroup tor tor && \
  mkdir -p /etc/confd/conf.d && \
  mkdir -p /etc/confd/templates
 
VOLUME /data
WORKDIR /data

COPY torrc-defaults.toml /etc/confd/conf.d
COPY torrc-defaults.tmpl /etc/confd/templates

COPY docker-entry-point.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["tor", "-f", "/data/torrc"]

HEALTHCHECK --timeout=5s CMD echo quit | curl -sS telnet://localhost:${ORPORT:-9001} && curl -sSf http://localhost:${DIRPORT:-9030}/tor/server/authority || exit 1
