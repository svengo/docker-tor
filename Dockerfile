FROM alpine:edge
MAINTAINER Sven Gottwald <svengo@gmx.net>

ENV VERSION 0.3.0.11

ADD https://www.torproject.org/dist/tor-${VERSION}.tar.gz /tmp/
ADD https://www.torproject.org/dist/tor-${VERSION}.tar.gz.asc /tmp/

WORKDIR /tmp/
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
  apk add --update --no-cache libevent libcap zlib confd su-exec && \
  apk add --update --no-cache --virtual build wget w3m ca-certificates gnupg build-base linux-headers libressl-dev libevent-dev zlib-dev libcap-dev && \
  \
  gpg --keyserver ipv4.pool.sks-keyservers.net --recv-keys 0x6AFEE6D49E92B601 0x28988BF5 0x19F78451 && \
  gpg --verify tor-${VERSION}.tar.gz.asc && \
  \
  tar -zxf tor-${VERSION}.tar.gz && \
  cd tor-${VERSION} && \
  ./configure \ 
    --silent \
    --prefix=/usr \
    --localstatedir=/var \
    --sysconfdir=/etc \
    --disable-gcc-warnings-advisory	&& \
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
