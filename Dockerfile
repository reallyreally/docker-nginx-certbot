FROM alpine:latest

MAINTAINER Troy Kelly <troy.kelly@really.ai>

ENV VERSION=1.13.7
ENV NPS_VERSION=1.12.34.3-stable
#ENV MODPAGESPEED_VERSION=latest-stable
ENG MODPAGESPEED_VERSION=latest-beta
ENV BINUTILS_VERSION=2.25
ENV LIBPNG_VERSION=1.6.34

export VERSION=1.13.7 && \
export NPS_VERSION=1.12.34.3-stable && \
export MODPAGESPEED_VERSION=latest-beta && \
export BINUTILS_VERSION=2.25 && \
export LIBPNG_VERSION=1.2.56 && \
export build_pkgs=".build-deps apache2-dev apr-dev apr-util-dev build-base curl icu-dev libjpeg-turbo-dev linux-headers gperf pcre-dev zlib-dev bash openssl openssl-dev python2-dev py-pip libffi-dev" && \
export runtime_pkgs="ca-certificates libuuid apr apr-util libjpeg-turbo icu icu-libs openssl pcre zlib"

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
ARG NPS_VERSION
ARG MODPAGESPEED_VERSION
ARG LIBPNG_VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="NGINX with Certbot and lua support" \
      org.label-schema.description="Provides nginx with support for certbot --nginx." \
      org.label-schema.url="https://really.ai/about/opensource" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/reallyreally/docker-nginx-certbot" \
      org.label-schema.vendor="Really Really, Inc." \
      org.label-schema.version=v$VERSION \
      org.label-schema.schema-version="1.0"

RUN build_pkgs=".build-deps apache2-dev apr-dev apr-util-dev build-base curl icu-dev libjpeg-turbo-dev linux-headers gperf pcre-dev zlib-dev bash openssl openssl-dev python2-dev py-pip libffi-dev" && \
  runtime_pkgs="ca-certificates libuuid apr apr-util libjpeg-turbo icu icu-libs openssl pcre zlib" && \
  apk add --update --no-cache ${build_pkgs} ${runtime_pkgs} && \
  mkdir -p /src/bin /var/log/nginx /run/nginx && \
  pip install certbot certbot-nginx && \
  cd /src && \
  wget http://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.gz && \
  wget "http://prdownloads.sourceforge.net/libpng/libpng-${LIBPNG_VERSION}.tar.gz" && \
  wget "http://ftp.gnu.org/pub/gnu/gettext/gettext-latest.tar.gz" && \
  tar xvf binutils-${BINUTILS_VERSION}.tar.gz && \
  cd binutils-${BINUTILS_VERSION} && \
  ./configure --prefix=/usr --disable-static && make && make install && \
  cd /src && \
  tar xvf gettext-latest.tar.gz && \
  cd gettext-* && \
  ./configure --prefix=/usr --disable-static && make && make install && \
  cd /src && \
  tar xvf libpng-${LIBPNG_VERSION}.tar.gz && \
  cd libpng-${LIBPNG_VERSION} && \
  ./configure --prefix=/usr --disable-static && make && make install && \
  cd /src && \
  git clone -b ${MODPAGESPEED_VERSION} --recursive https://github.com/pagespeed/mod_pagespeed.git && \
  cd /src/mod_pagespeed && \
  find . -name platform.h -exec sed -i s/"define U_TIMEZONE\s\+__timezone"/"define U_TIMEZONE timezone"/ "{}" \; && \
  wget https://github.com/pagespeed/ngx_pagespeed/files/195988/psol-chromium.stacktrace.patch.txt && \
  patch third_party/chromium/src/base/debug/stack_trace_posix.cc < psol-chromium.stacktrace.patch.txt && \
  python build/gyp_chromium --depth=. && \
  make BUILDTYPE=Release CXXFLAGS=" -I/usr/include/apr-1 -I/src/libpng-${LIBPNG_VERSION} -fPIC -D_GLIBCXX_USE_CXX11_ABI=0" CFLAGS=" -I/usr/include/apr-1 -I/src/libpng-${LIBPNG_VERSION} -fPIC -D_GLIBCXX_USE_CXX11_ABI=0" && \
  make all BUILDTYPE=Release CXXFLAGS=" -I/usr/include/apr-1 -I/src/libpng-${LIBPNG_VERSION} -fPIC -D_GLIBCXX_USE_CXX11_ABI=0 -Duse_system_libs=1 -Duse_system_icu=1" CFLAGS=" -I/usr/include/apr-1 -I/src/libpng-${LIBPNG_VERSION} -D_GLIBCXX_USE_CXX11_ABI=0 -Duse_system_libs=1 -Duse_system_icu=1" && \
  make BUILDTYPE=Release CXXFLAGS=" -I/usr/include/apr-1 -I/src/libpng-${LIBPNG_VERSION} -fPIC -D_GLIBCXX_USE_CXX11_ABI=0" CFLAGS=" -I/usr/include/apr-1 -I/src/libpng-${LIBPNG_VERSION} -fPIC -D_GLIBCXX_USE_CXX11_ABI=0"
  make BUILDTYPE=Release CXXFLAGS=" -I/usr/include/apr-1 -I/tmp/libpng-${LIBPNG_VERSION} -fPIC -D_GLIBCXX_USE_CXX11_ABI=0" CFLAGS=" -I/usr/include/apr-1 -I/tmp/libpng-${LIBPNG_VERSION} -fPIC -D_GLIBCXX_USE_CXX11_ABI=0" && \

  make BUILDTYPE=Release mod_pagespeed_test pagespeed_automatic_test && \
  cd /src/mod_pagespeed/src && \
  make AR.host=`pwd`/build/wrappers/ar.sh AR.target=`pwd`/build/wrappers/ar.sh BUILDTYPE=Release && \
  wget https://github.com/pagespeed/ngx_pagespeed/archive/v${NPS_VERSION}.zip && \
  unzip v${NPS_VERSION}.zip && \
  cd ngx_pagespeed-${NPS_VERSION}/ && \
  NPS_RELEASE_NUMBER=${NPS_VERSION/beta/} && \
  NPS_RELEASE_NUMBER=${NPS_VERSION/stable/} && \
  psol_url=https://dl.google.com/dl/page-speed/psol/${NPS_RELEASE_NUMBER}.tar.gz && \
  [ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL) && \
  wget ${psol_url} && \
  tar -xzvf $(basename ${psol_url}) && \
  cd /src  && \
  wget http://nginx.org/download/nginx-${VERSION}.tar.gz  && \
  tar -xvzf nginx-${VERSION}.tar.gz  && \
  cd nginx-${VERSION}/ && \
  ./configure --add-module=/src/ngx_pagespeed-${NPS_VERSION} ${PS_NGX_EXTRA_FLAGS} && \
  make && \
  sudo make install && \
  apk del linux-headers alpine-sdk curl openssl openssl-dev python2-dev libffi-dev && \
  apk add openssl && \
  chown -R nginx:nginx /var/log/nginx && \
  chown -R nginx:nginx /run/nginx

EXPOSE 80 443

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
