FROM ubuntu:focal

ARG CONFD_VERSION=0.16.0
ARG TOR_VERSION=0.4.6.8
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

WORKDIR /tmp

RUN \
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
  RUNTIME_PACKAGES=" \
    curl \
    libevent-2.1-7 \
    liblzma5 \
    libssl1.1 \
    libzstd1 \
    zlib1g" && \
  \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get -qq install $BUILD_PACKAGES && \
  \
  curl -o su-exec.c https://raw.githubusercontent.com/ncopa/su-exec/master/su-exec.c && \
  gcc -Wall su-exec.c -o/usr/bin/su-exec && \
  \
  curl -SL -o /usr/bin/confd https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 && \
  chmod +x /usr/bin/confd && \
  \
  curl -SL -o tor-${TOR_VERSION}.tar.gz https://www.torproject.org/dist/tor-${TOR_VERSION}.tar.gz && \
  curl -SL -o tor-${TOR_VERSION}.tar.gz.asc https://www.torproject.org/dist/tor-${TOR_VERSION}.tar.gz.asc && \
  gpg --keyserver keys.openpgp.org --recv-keys \
	0xEB5A896A28988BF5 \
	0xC218525819F78451 \
	0xFE43009C4607B1FB \
	0x6AFEE6D49E92B601 && \
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
  AUTO_ADDED_PACKAGES=`apt-mark showauto` && \
  apt-get remove --purge -y $BUILD_PACKAGES $AUTO_ADDED_PACKAGES && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y $RUNTIME_PACKAGES && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /tmp/* && \
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
