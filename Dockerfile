FROM alpine:3.10

ENV COMPOSER_HOME=/var/cache/composer
ENV PROJECT_ROOT=/sw6
ENV ARTIFACTS_DIR=/artifacts
ENV LD_PRELOAD=/usr/lib/preloadable_libiconv.so
ENV COMPOSER_MEMORY_LIMIT=-1

RUN apk --no-cache add \
        nginx supervisor curl zip unzip rsync \
        php7 php7-fpm \
        php7-ctype php7-curl php7-dom php7-fileinfo php7-gd \
        php7-iconv php7-intl php7-json php7-mbstring \
        php7-mysqli php7-openssl php7-pdo_mysql php7-sodium \
        php7-session php7-simplexml php7-tokenizer php7-xml php7-xmlreader php7-xmlwriter \
        php7-zip php7-zlib php7-phar git \
        gnu-libiconv php7-opcache php7-pecl-apcu composer

RUN apk --no-cache add npm bash

RUN adduser -u 1000 -D -h /sw6 sw6 sw6
RUN rm /etc/nginx/conf.d/default.conf

COPY config/etc /etc

WORKDIR /sw6

ENV SHOPWARE_URL=https://github.com/shopware/development.git
ENV PLATFORM_URL=https://github.com/shopware/platform.git
ENV APP_URL=http://localhost.local

RUN mkdir -p /cache &&\
    mkdir -p /var/cache/composer/cache/files/
RUN git clone $SHOPWARE_URL /sw6
RUN cd /sw6 && composer require shopware/platform v6.3.0.2
RUN touch /sw6/install.lock && touch /sw6/.env
RUN chown -R sw6.sw6 /run \
    /var/lib/nginx \
    /var/tmp/nginx \
    /var/log/nginx \
    /var/cache/composer/ \
    /sw6 \
    /cache

USER sw6

RUN php ./dev-ops/generate_ssl.php

EXPOSE 8000

ENTRYPOINT [ "/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf" ]

HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8000/fpm-ping
