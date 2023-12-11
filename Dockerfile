FROM php:8-cli-alpine

RUN  apk update \
  && apk add wget \
  && apk add git \
  && apk add unzip \
  && rm -rf /var/lib/apk/lists/* \
  && docker-php-ext-install pcntl

WORKDIR /tmp/
COPY composer-install.sh composer-install.sh
RUN chmod +x /tmp/composer-install.sh \
  && /tmp/composer-install.sh \
  && rm -f /tmp/composer-install.sh

WORKDIR /usr/share/weatherflux
COPY . .
RUN composer instal --no-interaction --no-cache
RUN mkdir config
RUN cp ./config-blank.json ./config/config.json
RUN mkdir logs

VOLUME /usr/share/weatherflux/config
VOLUME /usr/share/weatherflux/logs
EXPOSE 50222/udp

HEALTHCHECK --interval=5m --timeout=10s --start-period=10s --retries=2 \
  CMD php /usr/share/weatherflux/weatherflux.php status -h

ENTRYPOINT php /usr/share/weatherflux/weatherflux.php start -c
