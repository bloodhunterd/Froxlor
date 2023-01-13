#!/bin/bash

########################################################################################################################
# Timezone
########################################################################################################################

ln -snf "/usr/share/zoneinfo/${TZ}" etc/localtime && \
echo "${TZ}" > /etc/timezone

# ======================================================================================================================
# Froxlor PHP-FPM
# ======================================================================================================================

chown -R www-data:www-data /var/www/froxlor
php /var/www/froxlor/bin/froxlor-cli froxlor:cron -f

########################################################################################################################
# Froxlor Cron
########################################################################################################################

ln -s /var/www/froxlor/bin/froxlor-cli /usr/local/bin/froxlor-cli
php /var/www/froxlor/bin/froxlor-cli froxlor:cron -r 99 # re-create cron.d-file

########################################################################################################################
# Services
########################################################################################################################

cron
named
nginx

service php${PHP_VERSION_1}-fpm start
service php${PHP_VERSION_2}-fpm start
service php${PHP_VERSION_3}-fpm start
service php${PHP_VERSION_4}-fpm start

########################################################################################################################
# Logging
########################################################################################################################

tail -f /var/log/nginx/error.log
