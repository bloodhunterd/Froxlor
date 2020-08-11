#!/bin/bash

# Set timezone
ln -snf "/usr/share/zoneinfo/${TZ}" etc/localtime && \
echo "${TZ}" > /etc/timezone

service cron start

service php${PHP_VERSION_1}-fpm start
service php${PHP_VERSION_2}-fpm start
service php${PHP_VERSION_3}-fpm start

service nginx start

sleep 10

# Run Froxlor Cron
/usr/bin/nice -n 5 /usr/bin/php -q /var/www/froxlor/scripts/froxlor_master_cronjob.php --force

# Show log
tail -f /var/log/nginx/error.log
