FROM debian:jessie
MAINTAINER robs@codexsoftware.co.uk

# Using this UID / GID allows local and live file modification of web site
RUN usermod -u 1000 www-data
RUN groupmod -g 1000 www-data

RUN apt-get update && apt-get install -y php5-fpm php5-mysql php5-sqlite php5-pgsql php5-mcrypt php5-curl php5-memcached nginx supervisor cron git ssmtp

# Set up web site.
ADD nginx-default-server.conf /etc/nginx/sites-available/default
ADD domain.crt /etc/nginx/conf.d/
ADD domain.key /etc/nginx/conf.d/
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
ADD website/ /var/www/
RUN chown -R www-data.www-data /var/www/*

# Set up cron
ADD crontab /var/spool/cron/crontabs/www-data
RUN chown www-data.crontab /var/spool/cron/crontabs/www-data
RUN chmod 0600 /var/spool/cron/crontabs/www-data

# Install composer
ADD https://getcomposer.org/composer.phar /usr/bin/composer
RUN chmod 0755 /usr/bin/composer

# Configure supervisord
ADD supervisord.conf /etc/supervisor/
ADD supervisor_conf/* /etc/supervisor/conf.d/

EXPOSE 80
EXPOSE 443

ADD docker-entrypoint.sh /root/docker-entrypoint.sh
ENTRYPOINT ["/root/docker-entrypoint.sh"]