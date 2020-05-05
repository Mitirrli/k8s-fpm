FROM php:7.4-fpm


MAINTAINER Hampster <phper.blue@gmail.com>

# Install general packages
RUN sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list && \
    sed -i 's/security-cdn.debian.org/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list && \
    apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libxpm-dev \
    libvpx-dev \
	libfreetype6-dev \
	libjpeg62-turbo-dev \
	libmcrypt-dev \
	libcurl4-gnutls-dev \
	pkg-config \
	gcc \
	make \
	autoconf \
	libc-dev \
    libxml2-dev \
    librabbitmq-dev \
    libssh-dev \
    unzip \
    default-mysql-client \
    zlib1g-dev \
    libicu-dev \
    g++ \
    wget \
    gnupg \
    software-properties-common \
    openssh-client \
    git-core \
    libzip-dev \
    libonig-dev \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install gd \
    && :\
    && apt-get install -y libicu-dev \
    && docker-php-ext-install intl \
    && :\
    && apt-get install -y libxml2-dev \
    && apt-get install -y libxslt-dev \
    && docker-php-ext-install soap \
    && docker-php-ext-install xsl \
    && docker-php-ext-install xmlrpc \
    && :\
    && apt-get install -y libbz2-dev \
    && docker-php-ext-install bz2 \
    && docker-php-ext-install zip \
    && docker-php-ext-install pcntl \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install exif \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install calendar \
    && docker-php-ext-install sockets \
    && docker-php-ext-install gettext \
    && docker-php-ext-install shmop \
    && docker-php-ext-install sysvmsg \
    && docker-php-ext-install sysvsem \
    && docker-php-ext-install sysvshm \
    && docker-php-ext-install opcache

# Install PHP redis
RUN pecl install -o -f redis \
&& rm -rf /tmp/pear \
&&  echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini


RUN apt-get install -y \
        librabbitmq-dev \
        libssh-dev \
    && docker-php-ext-install \
        bcmath \
        sockets \
    && pecl install amqp \
    && docker-php-ext-enable amqp

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
	&& composer config -g repo.packagist composer https://mirrors.aliyun.com/composer 

# 创建慢查询目录
RUN mkdir /usr/local/log/

# 复制配置文件到 /usr/local
COPY etc /usr/local/etc

# Use the default production configuration
COPY php.ini "$PHP_INI_DIR/php.ini"

# Override with custom opcache settings
COPY config/opcache.ini $PHP_INI_DIR/conf.d/

CMD ["php-fpm", "-R"]