FROM alpine:edge

ARG TOR_VERSION=0.3.0.11

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.name="docker-tor" \
  org.label-schema.description="Simple docker container for a tor node" \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.vcs-url="https://github.com/svengo/docker-tor" \
  org.label-schema.vendor="Sven Gottwald" \
  org.label-schema.version=$TOR_VERSION \
  org.label-schema.schema-version="1.0"

ADD https://www.torproject.org/dist/tor-${TOR_VERSION}.tar.gz /tmp/
ADD https://www.torproject.org/dist/tor-${TOR_VERSION}.tar.gz.asc /tmp/

WORKDIR /tmp/
RUN \
  echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
  apk add --update \
    confd \
    libcap \
    libevent \
    su-exec \
    zlib && \
  apk add --virtual build \
    build-base \
    ca-certificates \
    gnupg \
    libcap-dev \
    libevent-dev \
    libressl-dev \
    linux-headers \
    w3m \
    wget \
    zlib-dev && \
  \
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

EXPOSE 9001 9003
CMD ["tor", "-f", "/data/torrc"]
