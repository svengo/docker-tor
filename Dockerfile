FROM ubuntu:focal

# Build-time variables
ARG TOR_VERSION=0.4.7.7
ARG SU_EXEC_C=https://raw.githubusercontent.com/ncopa/su-exec/212b75144bbc06722fbd7661f651390dc47a43d1/su-exec.c
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

# set configuration defaults as build-tim variables
ARG DEFAULT_ORPORT=9001
ARG DEFAULT_DIRPORT=9030
ARG DEFAULT_EXITPOLICY="reject *:*"
ARG DEFAULT_CONTROLPORT=9051
ARG DEFAULT_HASHEDCONTROLPASSWORD=16:872860B76453A77D60CA2BB8C1A7042072093276A3D701AD684053EC4C
ARG DEFAULT_NICKNAME=ididnteditheconfig
ARG DEFAULT_CONTACTINFO="Random Person <nobody AT example dot com>"
ARG DEFAULT_MYFAMILY=

# set runtime variables
ENV ORPORT=${DEFAULT_ORPORT}
ENV DIRPORT=${DEFAULT_DIRPORT}
ENV EXITPOLICY=${DEFAULT_EXITPOLICY}
ENV CONTROLPORT=${DEFAULT_CONTROLPORT}
ENV HASHEDCONTROLPASSWORD=${DEFAULT_HASHEDCONTROLPASSWORD}
ENV NICKNAME=${DEFAULT_NICKNAME}
ENV CONTACTINFO=${DEFAULT_CONTACTINFO}
ENV MYFAMILY=${DEFAULT_MYFAMILY}

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
    gettext-base \
    libevent-2.1-7 \
    liblzma5 \
    libssl1.1 \
    libzstd1 \
    zlib1g" && \
  \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get -qq install $BUILD_PACKAGES && \
  \
  curl -o su-exec.c ${SU_EXEC_C}&& \
  gcc -Wall su-exec.c -o/usr/bin/su-exec && \
  \
  curl -SL -O https://dist.torproject.org/tor-${TOR_VERSION}.tar.gz && \
  curl -SL -O https://dist.torproject.org/tor-${TOR_VERSION}.tar.gz.sha256sum && \
  curl -SL -O https://dist.torproject.org/tor-${TOR_VERSION}.tar.gz.sha256sum.asc && \
  gpg --keyserver keys.openpgp.org --recv-keys \
    514102454D0A87DB0767A1EBBE6A0531C18A9179 \
    B74417EDDF22AC9F9E90F49142E86A2A11F48D36 \
    2133BC600AB133E1D826D173FE43009C4607B1FB && \
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
  adduser --system --disabled-login --ingroup tor tor

VOLUME /data
WORKDIR /data

COPY torrc-defaults-source /etc/tor

COPY docker-entry-point.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["tor", "-f", "/data/torrc"]

HEALTHCHECK --timeout=5s CMD echo quit | curl -sS telnet://localhost:${ORPORT:-9001} && curl -sSf http://localhost:${DIRPORT:-9030}/tor/server/authority || exit 1
