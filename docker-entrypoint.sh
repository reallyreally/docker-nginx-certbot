#!/usr/bin/env sh

if [ ! -f "/etc/ssl/dhparam.pem" ]; then
  /usr/bin/openssl dhparam -out /etc/ssl/dhparam.pem 2048
fi

if [ -f "/usr/sbin/nginx" ]; then
  /usr/sbin/nginx -g "daemon off;" "$@"
else
  echo "There is no NGINX application installed"
  "$@"
fi
