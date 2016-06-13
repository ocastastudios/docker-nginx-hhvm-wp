FROM ubuntu:trusty
MAINTAINER Ocasta Studios

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y upgrade && \
    apt-get -y install wget software-properties-common && \
    cd /tmp/ && wget http://nginx.org/keys/nginx_signing.key && \
    apt-key add /tmp/nginx_signing.key && \
    add-apt-repository 'deb http://nginx.org/packages/ubuntu/ trusty nginx' && \
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449 && \
    add-apt-repository 'deb http://dl.hhvm.com/ubuntu trusty main' && \
    apt-get -y update && \
    apt-get -y install  php5-mysqlnd php-apc curl unzip wget gawk git && \
    apt-get install -y libav-tools libavcodec-extra-54 libavformat-extra-54 && \
    apt-get -y install php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-ming && \
    apt-get -y install php5-ps php5-pspell php5-recode php5-redis php5-sqlite php5-tidy php5-xmlrpc php5-xsl && \
    apt-get -q -y install ssmtp mailutils && \
    apt-get -y install supervisor && \
    mkdir -p /var/log/supervisor && \
    apt-get install -y python-pip && pip install supervisor-stdout && \
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
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp && \
    composer require aaemnnosttv/wp-cli-dotenv-command && \
    mkdir -p /var/www && \
    git clone --recursive --depth 1 https://github.com/roots/bedrock.git /var/www/public_html && \
    cd /var/www/public_html && \
    composer install

# Map local files
ADD conf/hhvm /etc/hhvm
ADD conf/nginx/sites-enabled/host.conf /etc/nginx/conf.d/default.conf

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
ENTRYPOINT ["supervisord"]
CMD ["--configuration=/etc/supervisor.conf"]


