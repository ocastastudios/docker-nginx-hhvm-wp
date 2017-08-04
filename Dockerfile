FROM ubuntu:xenial
MAINTAINER Ocasta Studios

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y upgrade && \
    apt-get -y install wget software-properties-common && \
    cd /tmp/ && wget http://nginx.org/keys/nginx_signing.key && \
    apt-key add /tmp/nginx_signing.key && \
    add-apt-repository 'deb http://nginx.org/packages/ubuntu/ xenial nginx' && \
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449 && \
    add-apt-repository 'deb http://dl.hhvm.com/ubuntu xenial main' && \
    apt-get -y update && \
    apt-get -y install curl unzip wget gawk git && \
    apt-get install -y libav-tools libavcodec-extra libavformat-dev ghostscript libgs-dev imagemagick && \
    apt-get -y install php-curl php-gd php-intl php-pear php-imagick php-imap php-mcrypt php-memcache && \
    apt-get -y install php-pspell php-recode php-redis php-sqlite3 php-tidy php-xmlrpc php-xsl && \
    apt-get -q -y install ssmtp mailutils && \
    apt-get -y install supervisor && \
    mkdir -p /var/log/supervisor && \
    apt-get install -y python-pip && pip install supervisor-stdout && \
    apt-get -y install php7.0-mysql mysql-client && \
    apt-get -y install nginx && \
    sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf && \
    sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf && \
    echo "daemon off;" >> /etc/nginx/nginx.conf && \
    apt-get -y install hhvm && \
    mkdir -p /var/log/hhvm && \
    apt-get -y remove software-properties-common python-pip && \
    apt-get -y autoremove && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -rf /etc/nginx/sites-enabled && \
    cd /tmp && \
    mkdir -p /var/log/hhvm && \
    curl -sS https://getcomposer.org/installer | php && \
    chmod +x composer.phar && \
    mv composer.phar /usr/local/bin/composer && \
    wget -O php-wpcli_1.1.0_all.deb https://github.com/wp-cli/builds/raw/gh-pages/deb/php-wpcli_1.1.0_all.deb && \
    dpkg -i php-wpcli_1.1.0_all.deb && \
    mv /usr/bin/wp /usr/local/bin/wp && \
    composer require aaemnnosttv/wp-cli-dotenv-command && \
    mkdir -p /var/www && \
    git clone --recursive --depth 1 https://github.com/roots/bedrock.git /var/www/public_html && \
    cd /var/www/public_html && \
    composer install

# Map local files
ADD conf/hhvm /etc/hhvm
ADD conf/nginx/sites-enabled/host.conf /etc/nginx/conf.d/default.conf
ADD conf/healthcheck/healthcheck.php /var/www/healthcheck.php

# Add the wp-cron trigger cron job.
ADD ["conf/cron.d/wp-cron-trigger","/etc/cron.d/wp-cron-trigger"]

# Add config scripts used in supervisor
ADD scripts /usr/local/bin/scripts
RUN chmod +x /usr/local/bin/scripts/*

# Supervisor base configuration
ADD supervisor.conf /etc/supervisor.conf

# Add the supervisord configuration file for hhvm
ADD supervisor.confd /etc/supervisor/conf.d/

# Set supervisord to launch upon the start of the container
ENTRYPOINT ["/usr/local/bin/scripts/docker_entrypoint.sh"]
CMD ["/usr/bin/supervisord", "--configuration=/etc/supervisor.conf"]


