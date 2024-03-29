#!/bin/bash

# ======================================================================================================================
# Timezone
# ======================================================================================================================

ln -fns "/usr/share/zoneinfo/${TZ}" etc/localtime && echo "${TZ}" > /etc/timezone

# ======================================================================================================================
# Froxlor
# ======================================================================================================================

# PHP-FPM
chown -R froxlorlocal:froxlorlocal /var/www/froxlor/
php /var/www/froxlor/bin/froxlor-cli froxlor:cron --force

# Cron
ln -fns /var/www/froxlor/bin/froxlor-cli /usr/local/bin/froxlor-cli
php /var/www/froxlor/bin/froxlor-cli froxlor:cron --run-task 99

# ======================================================================================================================
# Services
# ======================================================================================================================

cron
named
nginx

service php${PHP_VERSION_1}-fpm start
service php${PHP_VERSION_2}-fpm start
service php${PHP_VERSION_3}-fpm start
service php${PHP_VERSION_4}-fpm start

# ======================================================================================================================
# Logging
# ======================================================================================================================

tail -f /var/log/nginx/error.log
