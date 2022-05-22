#
# Multi-stage build: builder
#

FROM ubuntu:focal AS builder

# Build-time variables
ARG TOR_VERSION
ARG SU_EXEC_C=https://raw.githubusercontent.com/ncopa/su-exec/212b75144bbc06722fbd7661f651390dc47a43d1/su-exec.c
ARG TZ=Europe/Berlin

WORKDIR /tmp

RUN \
  if test -z "$TOR_VERSION" ; then echo ERROR: TOR_VERSION not provided && exit 1; fi && \
  \
  BUILD_PACKAGES=" \
    automake \
    build-essential \
    curl \
    libevent-dev \
    liblzma-dev \
    libssl-dev \
    libzstd-dev \
    pkg-config \
    python3 \
    zlib1g-dev" && \
  export DEBIAN_FRONTEND=noninteractive &&\
  \
  apt-get update && \
  apt-get -qq install $BUILD_PACKAGES && \
  \
  curl -o su-exec.c ${SU_EXEC_C}&& \
  gcc -Wall su-exec.c -o/usr/bin/su-exec && \
  \
  curl -SL -O https://dist.torproject.org/tor-${TOR_VERSION}.tar.gz && \
  curl -SL -O https://dist.torproject.org/tor-${TOR_VERSION}.tar.gz.sha256sum && \
  curl -SL -O https://dist.torproject.org/tor-${TOR_VERSION}.tar.gz.sha256sum.asc && \
  gpg --auto-key-locate nodefault,wkd --locate-keys ahf@torproject.org \
    dgoulet@torproject.org \
    nickm@torproject.org && \
  sha256sum --check tor-${TOR_VERSION}.tar.gz.sha256sum && \
  gpg --verify tor-${TOR_VERSION}.tar.gz.sha256sum.asc && \
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
  make test


#
# Multi-stage build: image
#

FROM ubuntu:focal

# Build-time variables
ARG TOR_VERSION
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

RUN \
  RUNTIME_PACKAGES=" \
    curl \
    gettext-base \
    libevent-2.1-7 \
    liblzma5 \
    libssl1.1 \
    libzstd1 \
    zlib1g" && \
  export DEBIAN_FRONTEND=noninteractive &&\
  \
  apt-get update && \
  apt-get install -y $RUNTIME_PACKAGES && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  \
  addgroup --system tor && \
  adduser --system --disabled-login --ingroup tor tor

VOLUME /data
WORKDIR /data

# copy files from builder
COPY --from=builder \
  /usr/bin/su-exec \
  /tmp/tor-${TOR_VERSION}/src/app/tor \
  /tmp/tor-${TOR_VERSION}/src/tools/tor-resolve \
  /tmp/tor-${TOR_VERSION}/src/tools/tor-print-ed-signing-cert \
  /tmp/tor-${TOR_VERSION}/src/tools/tor-gencert \
  /tmp/tor-${TOR_VERSION}/contrib/client-tools/torify \
  /usr/bin/
COPY --from=builder \
  /tmp/tor-${TOR_VERSION}/src/config/geoip \
  /tmp/tor-${TOR_VERSION}/src/config/geoip6 \
  /usr/share/tor/
COPY --from=builder \
  /tmp/tor-${TOR_VERSION}/src/config/torrc.sample \
  /etc/tor/

COPY torrc-defaults-source /etc/tor/
COPY docker-entry-point.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["tor", "-f", "/data/torrc"]

HEALTHCHECK --timeout=5s CMD echo quit | curl -sS telnet://localhost:${ORPORT} && \
  curl -sSf http://localhost:${DIRPORT}/tor/server/authority || exit 1
