#!/bin/bash

# Set timezone
ln -snf "/usr/share/zoneinfo/${TZ}" etc/localtime && echo "${TZ}" > /etc/timezone && \

# Set locales
echo "${LOCALE}" >> /etc/locale.gen && locale-gen && \

# Start Quota
#service quota start && \

# Start NSCD
service nscd start && \

# Start CRON
service cron start && \

# Execute Froxlor's CRON job
/usr/bin/nice -n 5 /usr/bin/php -q /var/www/froxlor/scripts/froxlor_master_cronjob.php --force && \

# Start PHP-FPM (old version)
service php${PHP_VERSION_OLD}-fpm start && \

# Start PHP-FPM (current version)
service php${PHP_VERSION}-fpm start && \

# Start NGINX
service nginx start && \

# Show log
tail -f /var/log/nginx/error.log
