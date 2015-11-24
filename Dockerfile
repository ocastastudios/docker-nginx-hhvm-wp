FROM tutum/ubuntu:trusty
MAINTAINER Ocasta Studios

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y upgrade

# Basic Requirements
RUN apt-get -y install php5-mysql php-apc curl unzip wget gawk

# Libav for video thumbnails
RUN apt-get install -y libav-tools libavcodec-extra-54 libavformat-extra-54

# Wordpress Requirements
RUN apt-get -y install php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-ming php5-ps php5-pspell php5-recode php5-redis php5-sqlite php5-tidy php5-xmlrpc php5-xsl

# ssmtp for mail
RUN apt-get -q -y install ssmtp mailutils

# supervisor installation &&
# create directory for child images to store configuration in
RUN apt-get -y install supervisor && \
  mkdir -p /var/log/supervisor

# Installs add-apt-repository
RUN apt-get -y install software-properties-common

# supervisor-stdout
RUN apt-get install -y python-pip && pip install supervisor-stdout

# nginx upgrade
RUN cd /tmp/ && wget http://nginx.org/keys/nginx_signing.key
RUN apt-key add /tmp/nginx_signing.key
RUN add-apt-repository 'deb http://nginx.org/packages/ubuntu/ trusty nginx'
RUN apt-get -y update
RUN apt-get -y install nginx

# nginx config
RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
RUN sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# HHVM install
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
RUN add-apt-repository 'deb http://dl.hhvm.com/ubuntu trusty main'
RUN apt-get -y update
RUN apt-get -y install hhvm

WORKDIR /
RUN mkdir -p /var/log/hhvm

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php
RUN chmod +x composer.phar
RUN mv composer.phar /usr/local/bin/composer

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp

# Some misc cleanup
WORKDIR /
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN rm -rf /etc/nginx/sites-enabled

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
