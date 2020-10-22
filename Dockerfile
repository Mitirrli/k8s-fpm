FROM php:7.4.11-fpm-alpine

MAINTAINER Hampster <phper.blue@gmail.com>

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

# Install PHP redis
RUN pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini

# Add gd library
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/

RUN docker-php-ext-install gd bcmath pdo_mysql mysqli opcache pcntl

# Install composer
RUN wget https://mirrors.aliyun.com/composer/composer.phar -O /usr/local/bin/composer \
    && chmod a+x /usr/local/bin/composer \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer

# 创建慢查询目录
RUN mkdir /usr/local/log/

# 复制配置文件到 /usr/local
COPY etc /usr/local/etc

# Use the default production configuration
COPY config/php.ini "$PHP_INI_DIR/php.ini"

# Override with custom settings
COPY config/opcache.ini $PHP_INI_DIR/conf.d/
COPY config/expose_php.ini $PHP_INI_DIR/conf.d/
COPY config/upload.ini $PHP_INI_DIR/conf.d/

CMD ["php-fpm", "-R"]
