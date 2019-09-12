FROM php:7.3-apache 

MAINTAINER Hari Venu V <harivenu.v1992@gmail.com>

# Set the Drush version.
ENV DRUSH_VERSION 9.7.1

# Enable rewrite headers
RUN a2enmod rewrite headers

# Intall mysqli php extention
RUN docker-php-ext-install mysqli

# Setup Debian
RUN apt-get upgrade && apt-get update && ACCEPT_EULA=Y && apt-get install -y \
        unzip \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libmemcached-dev \
        libzip-dev \
        libgeoip-dev \
        libxml2-dev \
        libxslt-dev \
        libtidy-dev \
        libssl-dev \
        zlib1g-dev \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libaio1 \
        apt-file \
        wget \
        vim \
        gnupg \
        gnupg2 \
        zip \
        git

# Install PECLs
RUN pecl install redis \
    && pecl install geoip-1.1.1 \
    && pecl install apcu \
    && pecl install memcached \
    && pecl install timezonedb

RUN docker-php-ext-install -j$(nproc) calendar iconv bcmath xml gd mbstring pdo tidy gettext intl pdo pdo_mysql mysqli simplexml tokenizer xml xsl xmlwriter zip opcache exif \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-gd --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure zip --with-libzip \
    && docker-php-ext-enable redis geoip apcu memcached timezonedb
	
# Composer installation
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Drush using Composer.
RUN composer global require drush/drush:"$DRUSH_VERSION" --prefer-dist

# Making drush as global command
RUN ln -s /root/.composer/vendor/drush/drush/drush /usr/local/bin/

# MySQL client installation
RUN apt-get update && apt-get install -y mariadb-client && rm -rf /var/lib/apt

# Mailhog
RUN curl --location --output /usr/local/bin/mhsendmail https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 && \
    chmod +x /usr/local/bin/mhsendmail

RUN echo 'sendmail_path="/usr/local/bin/mhsendmail --smtp-addr=mailhog:1025 --from=no-reply@docker.dev"' > /usr/local/etc/php/conf.d/mailhog.ini

# Copy php.ini file to container
COPY /conf/php.ini /usr/local/etc/php/
