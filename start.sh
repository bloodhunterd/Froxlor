#!/bin/bash

# Set timezone
ln -snf "/usr/share/zoneinfo/${TZ}" etc/localtime && \
echo "${TZ}" > /etc/timezone

# Start NSCD
service nscd start

# Start CRON
service cron start

# Start PHP-FPM processes
service php${PHP_VERSION_SFO}-fpm start
service php${PHP_VERSION_PREV}-fpm start
service php${PHP_VERSION_MAIN}-fpm start

# Start NGINX
service nginx start

# Run Cron
/usr/bin/nice -n 5 /usr/bin/php -q /var/www/froxlor/scripts/froxlor_master_cronjob.php --force

# Show log
tail -f /var/log/nginx/error.log
