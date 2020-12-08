ARG PHPVERSION=8.0.0-fpm-alpine
FROM php:${PHPVERSION}

LABEL NAME="PHP-FPM"
LABEL VERSION=${PHPVERSION}
LABEL MAINTAINER="Hampster <phper.blue@gmail.com>"

# Change source
RUN echo http://mirrors.aliyun.com/alpine/v3.12/main > /etc/apk/repositories \
    && echo http://mirrors.aliyun.com/alpine/v3.12/community >> /etc/apk/repositories

RUN apk add --no-cache autoconf \
    gcc g++ make \
    oniguruma-dev \
    curl-dev \
    libxml2-dev \
    libzip-dev \
    libpng-dev freetype \
    libpng \
    libjpeg-turbo \
    freetype-dev \
    libpng-dev \
    jpeg-dev \
    libjpeg \
    libjpeg-turbo-dev

# Install redis
ARG REDISVERSION=5.3.2
RUN curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/${REDISVERSION}.tar.gz \
    && tar xfz /tmp/redis.tar.gz \
    && rm -r /tmp/redis.tar.gz \
    && mkdir -p /usr/src/php/ext \
    && mv phpredis-${REDISVERSION} /usr/src/php/ext/phpredis

RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install gd bcmath pdo_mysql mysqli opcache phpredis

# Install composer
RUN wget https://mirrors.aliyun.com/composer/composer.phar -O /usr/local/bin/composer \
    && chmod a+x /usr/local/bin/composer \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer

# Mkdir slow query directory
RUN mkdir /usr/local/log/

# Copy configuration to /usr/local 
COPY etc /usr/local/etc

# Use the default production configuration
COPY config/php.ini "$PHP_INI_DIR/php.ini"

# Override with custom settings
COPY config/opcache.ini $PHP_INI_DIR/conf.d/
COPY config/expose_php.ini $PHP_INI_DIR/conf.d/
COPY config/upload.ini $PHP_INI_DIR/conf.d/

EXPOSE 9000

CMD [ "php-fpm", "-R" ]