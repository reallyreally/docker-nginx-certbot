FROM alpine:latest

MAINTAINER Troy Kelly <troy.kelly@really.ai>

ENV VERSION=v0.0.2

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="NGINX with Certbot and lua support" \
      org.label-schema.description="Provides nginx with support for certbot --nginx." \
      org.label-schema.url="https://really.ai/about/opensource" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/reallyreally/docker-nginx-certbot" \
      org.label-schema.vendor="Really Really, Inc." \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"


RUN apk add --update --no-cache linux-headers alpine-sdk curl tzdata openssl openssl-dev nginx nginx-mod-http-lua nginx-mod-http-lua-upstream nginx-mod-devel-kit python2-dev libffi-dev py-pip py2-future py2-certifi py2-urllib3 py2-chardet && \
  mkdir -p /var/log/nginx && \
  pip install certbot certbot-nginx && \
  apk del linux-headers alpine-sdk curl openssl openssl-dev python2-dev libffi-dev && \
  apk add openssl && \
  chown -R nginx:nginx /var/log/nginx

EXPOSE 80 443

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
