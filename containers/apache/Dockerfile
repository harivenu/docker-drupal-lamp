FROM php:7.3-apache 

MAINTAINER Hari Venu V <harivenu.v1992@gmail.com>

# Set the Drush version.
ENV DRUSH_VERSION 9.7.1

# Set the composer version.
ENV COMPOSER_VERSION 2.0.12

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
        libjpeg62-turbo-dev \
        libfreetype6-dev \
        libaio1 \
        apt-file \
        wget \
        vim \
        gnupg \
        gnupg2 \
        zip \
        git \
	npm \
        nodejs \
        memcached \
        libmemcached-tools

# Install PECLs
RUN pecl install redis \
    && pecl install geoip-1.1.1 \
    && pecl install apcu \
    && pecl install memcached \
    && pecl install timezonedb

RUN docker-php-ext-install -j$(nproc) calendar iconv bcmath xml mbstring pdo tidy gettext intl pdo pdo_mysql mysqli simplexml tokenizer xml xsl xmlwriter zip opcache exif \
    && docker-php-ext-configure zip --with-libzip \
    && docker-php-ext-enable redis geoip apcu memcached timezonedb
    
# Install SSL
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/ssl-cert-snakeoil.key -out /etc/ssl/certs/ssl-cert-snakeoil.pem -subj "/C=AT/ST=Vienna/L=Vienna/O=Security/OU=Development/CN=example.com"
RUN a2ensite default-ssl
RUN a2enmod ssl
	
# Composer installation
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version="$COMPOSER_VERSION" 

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

# Drupal Console installation
RUN curl --location --output /usr/local/bin/drupal https://drupalconsole.com/installer && chmod +x /usr/local/bin/drupal

# Install GD
RUN apt-get install -y libfreetype6-dev libjpeg62-turbo-dev
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install gd

# Drupal Checks
RUN composer global require mglaman/drupal-check && \
  ln -sf /root/.composer/vendor/mglaman/drupal-check/drupal-check /usr/local/bin/ && \
  chmod +x /usr/local/bin/drupal-check

# bz2 extenstion
RUN apt-get update && apt-get install -y libbz2-dev
RUN docker-php-ext-install bz2

# Install PECL Uploadprogress.
RUN pecl install uploadprogress && echo 'extension=uploadprogress.so' > /usr/local/etc/php/conf.d/uploadprogress.ini

# NPM install
RUN apt-get install nodejs -y

# Installing xdebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    # host.docker.internal does not work on Linux yet: https://github.com/docker/for-linux/issues/264
    # Workaround:
    # ip -4 route list match 0/0 | awk '{print $3 " host.docker.internal"}' >> /etc/hosts \
    # && echo "xdebug.remote_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
    && echo "xdebug.client_host=172.19.0.1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.log='/tmp/xdebug.log'" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# An IDE key has to be set, but anything works, at least for PhpStorm and VS Code...
ENV XDEBUG_CONFIG="xdebug.idekey='CODE'"
