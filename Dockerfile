FROM alpine:edge
MAINTAINER Sven Gottwald <svengo@gmx.net>

RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories && \
  echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
  apk update && \
  apk add --update tor libevent confd su-exec && \
  rm -rf /var/cache/apk/*

RUN addgroup -S tor && \
  id -u tor &>/dev/null || adduser -s /bin/false -SDH -G tor tor && \
  mkdir /data && \
  chown tor:tor /data && \
  mkdir -p /etc/confd/conf.d && \
  mkdir -p /etc/confd/templates

VOLUME /data

COPY torrc.toml /etc/confd/conf.d
COPY torrc.tmpl /etc/confd/templates 

COPY docker-entry-point.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 9001 9003
CMD ["tor", "-f", "/data/torrc"]
