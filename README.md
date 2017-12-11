# really/nginx-certbot
Docker container providing nginx with lua and certbot for SSL certificates

[![](https://images.microbadger.com/badges/image/really/nginx-certbot.svg)](https://microbadger.com/images/really/nginx-certbot "Get your own image badge on microbadger.com") [![GitHub issues](https://img.shields.io/github/issues/reallyreally/docker-nginx-certbot.svg?style=flat-square)](https://github.com/reallyreally/docker-nginx-certbot/issues) [![GitHub license](https://img.shields.io/github/license/reallyreally/docker-nginx-certbot.svg?style=flat-square)](https://github.com/reallyreally/docker-nginx-certbot/blob/master/LICENSE)
[![Docker Pulls](https://img.shields.io/docker/pulls/really/nginx-certbot.svg?style=flat-square)](https://github.com/reallyreally/docker-nginx-certbot/)

Launch nginx proxying connections to the upstream using the default config:
```
docker run --name lb001-sin \
  --restart=always \
  --net=host \
  -v /data/nginx:/etc/nginx:rw \
  -v /data/letsencrypt:/etc/letsencrypt:rw \
  -v /etc/ssl:/etc/ssl:ro \
  -v /etc/pki:/etc/pki:ro \
  -d -p 80:80 -p 443:443 -d \
  really/nginx-certbot
```

Example Config
--------------

This will not work well stand-alone. You must provide configuration per the example above (in /data for exampe).
