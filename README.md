# really/nginx-certbot
Docker container providing [nginx](https://www.nginx.com) with [lua](https://www.nginx.com/resources/wiki/modules/lua/) and certbot for [Let's Encrypt](https://letsencrypt.org) SSL certificates

[![](https://images.microbadger.com/badges/image/really/nginx-certbot.svg)](https://microbadger.com/images/really/nginx-certbot "Get your own image badge on microbadger.com") [![GitHub issues](https://img.shields.io/github/issues/reallyreally/docker-nginx-certbot.svg?style=flat-square)](https://github.com/reallyreally/docker-nginx-certbot/issues) [![GitHub license](https://img.shields.io/github/license/reallyreally/docker-nginx-certbot.svg?style=flat-square)](https://github.com/reallyreally/docker-nginx-certbot/blob/master/LICENSE) [![Docker Pulls](https://img.shields.io/docker/pulls/really/nginx-certbot.svg?style=flat-square)](https://github.com/reallyreally/docker-nginx-certbot/)

Launch nginx using the default config:
```
docker run --name nginx-certbot \
  --restart=always \
  --net=host \
  -v /data/nginx/conf.d:/etc/nginx/conf.d:rw \
  -v /data/letsencrypt:/etc/letsencrypt:rw \
  -p 80:80 -p 443:443 -d \
  really/nginx-certbot
```

Certbot
-------
**IMPORTANT**
Let's Encrypt have (temporarily?) [disabled tls-sni-01](https://community.letsencrypt.org/t/2018-01-09-issue-with-tls-sni-01-and-shared-hosting-infrastructure/49996). While this is disabled, you will not be able to use certbot to automatically generate and renew certificates with this container. There is no easy work around - you could use DNS-01, but renewals will break.


**Once tls-sni is re-enabled...**

Easily add SSL security to your nginx hosts with certbot.
`docker exec -it nginx-certbot /bin/sh` will bring up a prompt at which time you can `certbot` to your hearts content.

_or_

`docker exec -it nginx-certbot certbot --no-redirect --must-staple -d example.com`

It even auto-renew's for you every day!
