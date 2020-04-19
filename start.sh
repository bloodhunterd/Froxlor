#!/bin/bash

# Set timezone
ln -snf "/usr/share/zoneinfo/${TZ}" etc/localtime && \
echo "${TZ}" > /etc/timezone

# Set locales
echo "${LOCALE}" >> /etc/locale.gen && \
locale-gen

# Start NSCD
service nscd start

# Start CRON
service cron start

# Execute Froxlor's CRON job
/usr/bin/nice -n 5 /usr/bin/php -q /var/www/froxlor/scripts/froxlor_master_cronjob.php --force

# Start PHP-FPM
service php${PHP_VERSION}-fpm start
service php${PHP_VERSION_2}-fpm start

# Start NGINX
service nginx start

# Show log
tail -f /var/log/nginx/error.log
