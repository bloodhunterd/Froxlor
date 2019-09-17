#!/bin/bash

# Set timezone
ln -snf "/usr/share/zoneinfo/${TZ}" etc/localtime && echo "${TZ}" > /etc/timezone

# Set locales
echo "${LOCALE}" >> /etc/locale.gen && locale-gen

#service quota start

service nscd start

service cron start

/usr/bin/nice -n 5 /usr/bin/php -q /var/www/froxlor/scripts/froxlor_master_cronjob.php --force

service php${PHP_VERSION}-fpm start

service nginx start

# Start dummy process
tail -f /dev/null
