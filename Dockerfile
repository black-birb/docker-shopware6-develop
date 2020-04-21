FROM alpine:3.10

ENV COMPOSER_HOME=/var/cache/composer
ENV PROJECT_ROOT=/sw6
ENV ARTIFACTS_DIR=/artifacts
ENV LD_PRELOAD=/usr/lib/preloadable_libiconv.so
ENV SHOPWARE_URL=https://www.shopware.com/de/Download/redirect/version/sw6/file/install_6.1.5_1585830011.zip

RUN apk --no-cache add \
        nginx supervisor curl zip unzip rsync \
        php7 php7-fpm \
        php7-ctype php7-curl php7-dom php7-fileinfo php7-gd \
        php7-iconv php7-intl php7-json php7-mbstring \
        php7-mysqli php7-openssl php7-pdo_mysql \
        php7-session php7-simplexml php7-tokenizer php7-xml php7-xmlreader php7-xmlwriter \
        php7-zip php7-zlib php7-phar git \
        gnu-libiconv

RUN apk --no-cache add npm bash

RUN adduser -u 1000 -D -h /sw6 sw6 sw6
RUN rm /etc/nginx/conf.d/default.conf

COPY config/etc /etc

WORKDIR /sw6

RUN mkdir -p /cache
RUN wget $SHOPWARE_URL -O /cache/install.zip
RUN unzip /cache/install.zip -d /sw6
RUN touch /sw6/install.lock
RUN chown -R sw6.sw6 /run \
    /var/lib/nginx \
    /var/tmp/nginx \
    /var/log/nginx \
    /sw6 \
    /cache

USER sw6

RUN bin/console system:generate-jwt-secret

EXPOSE 8000

ENTRYPOINT [ "/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf" ]

HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8000/fpm-ping
