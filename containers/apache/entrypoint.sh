#!/usr/bin/env bash
set -e

start_app(){
    echo "The apache started";
    source /etc/apache2/envvars
    /usr/sbin/apache2ctl -D FOREGROUND
}

start_memcached() {
    echo "The memcached started";
    /etc/init.d/memcached start;
}

setup_cron() {
    /etc/init.d/cron start;
    echo "The cron starting."
}

CONTAINER_FIRST_STARTUP="CONTAINER_FIRST_STARTUP"
if [ ! -e /$CONTAINER_FIRST_STARTUP ]; then
    touch /$CONTAINER_FIRST_STARTUP

    echo "Copying default XDEBUG ini"
    cp /home/xdebug/xdebug-default.ini /usr/local/etc/php/conf.d/xdebug.ini

    if [[ $MODES == *"profile"* ]]; then
        echo "Appending profile ini"
        echo "$(cat /home/xdebug/xdebug-profile.ini)" >> /usr/local/etc/php/conf.d/xdebug.ini
    fi

    if [[ $MODES == *"debug"* ]]; then
        echo "Appending debug ini"
        echo "$(cat /home/xdebug/xdebug-debug.ini)" >> /usr/local/etc/php/conf.d/xdebug.ini

        echo "Setting Client Host to: $CLIENT_HOST"
        sed -i -e 's/xdebug.client_host = localhost/xdebug.client_host = '"${CLIENT_HOST}"'/g' /usr/local/etc/php/conf.d/xdebug.ini

        echo "Setting Client Port to: $CLIENT_PORT"
        sed -i -e 's/xdebug.client_port = 9003/xdebug.client_port = '"${CLIENT_PORT}"'/g' /usr/local/etc/php/conf.d/xdebug.ini

        echo "Setting IDE Key to: $IDEKEY"
        sed -i -e 's/xdebug.idekey = docker/xdebug.idekey = '"${IDEKEY}"'/g' /usr/local/etc/php/conf.d/xdebug.ini
    fi

    if [[ $MODES == *"trace"* ]]; then
        echo "Appending trace ini"
        echo "$(cat /home/xdebug/xdebug-trace.ini)" >> /usr/local/etc/php/conf.d/xdebug.ini
    fi

    if [[ "off" == $MODES || -z $MODES ]]; then
        echo "Disabling XDEBUG";
        cp /home/xdebug/xdebug-off.ini /usr/local/etc/php/conf.d/xdebug.ini
    else
        echo "Setting XDEBUG mode: $MODES"
        echo "xdebug.mode = $MODES" >> /usr/local/etc/php/conf.d/xdebug.ini
    fi;

    # Create xdebug log folder.
    FILE=/var/log/xdebug/xdebug-log.log
    if test ! -f "$FILE"; then
        echo "Creating xdebug-logs.";
        mkdir /var/log/xdebug;
        echo '' > /var/log/xdebug/xdebug-log.log;
        chmod -R 777 /var/log/xdebug;
    fi

    if [[ "NOFOLDER" == $APP_FOLDER || -z $APP_FOLDER ]]; then
        echo "No Folder for app, default app path would be www:/var/www/html"
    else
        echo "Updating APP FOLDER.";
        sed -i "s/^[ \t]*DocumentRoot \/var\/www\/html$/DocumentRoot \/var\/www\/html\/"${APP_FOLDER}"/" /etc/apache2/sites-available/000-default.conf;
        sed -i "s/^[ \t]*DocumentRoot \/var\/www\/html$/DocumentRoot \/var\/www\/html\/"${APP_FOLDER}"/" /etc/apache2/sites-available/default-ssl.conf;
    fi;

    # Overright memcached.
    cp /home/memcached/memcached.conf /etc/memcached.conf;

    if [[ "enable" == $APP_CRON || -z $APP_CRON ]]; then
        setup_cron
        crontab /home/cron/cron_scheduler.txt;
        chmod +x /home/cron/cron.sh;
    fi;

    if [[ "enable" == $APP_MEMCACHED || -z $APP_MEMCACHED ]]; then
        start_memcached
    fi;

    # Making composer with global scope.
    echo 'export PATH="$PATH:$(composer config -g home)/vendor/bin"' >> /root/.bashrc

    start_app
else
    start_app
fi
