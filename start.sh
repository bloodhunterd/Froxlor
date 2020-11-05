#!/bin/bash

# Set timezone
ln -snf "/usr/share/zoneinfo/${TZ}" etc/localtime && \
echo "${TZ}" > /etc/timezone

service cron start

# Start DNS service
service bind9 start

# Start webserver service
service nginx start

# Start PHP services
service php${PHP_VERSION_1}-fpm start
service php${PHP_VERSION_2}-fpm start
service php${PHP_VERSION_3}-fpm start

# Run Froxlor Cron
/usr/bin/nice -n 5 /usr/bin/php -q /var/www/froxlor/scripts/froxlor_master_cronjob.php --force

# Take some time to breath
sleep 5

# Start PHP services again, if they failed on the first time
service php${PHP_VERSION_1}-fpm start
service php${PHP_VERSION_2}-fpm start
service php${PHP_VERSION_3}-fpm start

# Show log
tail -f /var/log/nginx/error.log
