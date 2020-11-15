#!/bin/bash

# ===================================================
# Set timezone
# ===================================================

ln -snf "/usr/share/zoneinfo/${TZ}" etc/localtime && \
echo "${TZ}" > /etc/timezone

# ===================================================
# Start services
# ===================================================

service cron start

service bind9 start

service nginx start

service php${PHP_VERSION_1}-fpm start
service php${PHP_VERSION_2}-fpm start
service php${PHP_VERSION_3}-fpm start

# ===================================================
# Run Froxlor Cron
# ===================================================

/usr/bin/nice -n 5 /usr/bin/php -q /var/www/froxlor/scripts/froxlor_master_cronjob.php --force

sleep 5

# ===================================================
# Start PHP services again
# ===================================================

service php${PHP_VERSION_1}-fpm start
service php${PHP_VERSION_2}-fpm start
service php${PHP_VERSION_3}-fpm start

# ===================================================
# Log output
# ===================================================

tail -f /var/log/nginx/error.log
