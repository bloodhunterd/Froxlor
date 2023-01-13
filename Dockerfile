FROM debian:stable-slim

# ======================================================================================================================
# Package versions
# ======================================================================================================================

# MariaDB
ARG MARIADB_VERSION=10.10

# NGINX
ARG NGINX_VERSION=1.23.*

# PHP
ENV PHP_VERSION_1=7.4
ENV PHP_VERSION_2=8.0
ENV PHP_VERSION_3=8.1
ENV PHP_VERSION_4=8.2

# ======================================================================================================================
# Configuration
# ======================================================================================================================

# Timezone
ENV TZ=Europe/Berlin

# ======================================================================================================================
# Ports
# ======================================================================================================================

# NGINX
EXPOSE 80
EXPOSE 443

# BIND
EXPOSE 53

# ======================================================================================================================
# Base packages
# ======================================================================================================================

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    apt-listchanges \
    apt-transport-https \
    ca-certificates

RUN sed -i 's/http:/https:/g' /etc/apt/sources.list

RUN apt-get update && \
    apt-get upgrade -y --no-install-recommends

RUN apt-get install -y --no-install-recommends \
    curl \
    dirmngr \
    gnupg2 \
    locales \
    locales-all \
    logrotate \
    lsb-release \
    software-properties-common \
    syslog-ng \
    unattended-upgrades \
    wget

# ======================================================================================================================
# Sources
# ======================================================================================================================

RUN curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add - && \
    sh -c 'echo "deb https://nginx.org/packages/mainline/debian $(lsb_release -cs) nginx" > /etc/apt/sources.list.d/nginx.list'

RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'

RUN wget -O /etc/apt/trusted.gpg.d/mariadb_release_signing_key.asc https://mariadb.org/mariadb_release_signing_key.asc && \
    sh -c 'echo "deb https://mirror.netcologne.de/mariadb/repo/${MARIADB_VERSION}/debian $(lsb_release -sc) main" > /etc/apt/sources.list.d/mariadb.list'

RUN apt-get update

# ======================================================================================================================
# Froxlor service packages
# ======================================================================================================================

RUN apt-get install -y --no-install-recommends \
    awstats \
    bind9 \
    cron \
    letsencrypt \
    libnss-extrausers \
    mariadb-client \
    nginx=${NGINX_VERSION} \
    nscd

# ======================================================================================================================
# PHP
# ======================================================================================================================

RUN apt-get install -y --no-install-recommends \
    php${PHP_VERSION_1} \
    php${PHP_VERSION_1}-common \
    php${PHP_VERSION_1}-bcmath \
    php${PHP_VERSION_1}-bz2 \
    php${PHP_VERSION_1}-cli \
    php${PHP_VERSION_1}-curl \
    php${PHP_VERSION_1}-fpm \
    php${PHP_VERSION_1}-gd \
    php${PHP_VERSION_1}-gmp \
    php${PHP_VERSION_1}-imagick \
    php${PHP_VERSION_1}-imap \
    php${PHP_VERSION_1}-intl \
    php${PHP_VERSION_1}-json \
    php${PHP_VERSION_1}-mbstring \
    php${PHP_VERSION_1}-mysql \
    php${PHP_VERSION_1}-opcache \
    php${PHP_VERSION_1}-xml \
    php${PHP_VERSION_1}-zip \
    php${PHP_VERSION_2} \
    php${PHP_VERSION_2}-common \
    php${PHP_VERSION_2}-bcmath \
    php${PHP_VERSION_2}-bz2 \
    php${PHP_VERSION_2}-cli \
    php${PHP_VERSION_2}-curl \
    php${PHP_VERSION_2}-fpm \
    php${PHP_VERSION_2}-gd \
    php${PHP_VERSION_2}-gmp \
    php${PHP_VERSION_2}-imagick \
    php${PHP_VERSION_2}-imap \
    php${PHP_VERSION_2}-intl \
    php${PHP_VERSION_2}-mbstring \
    php${PHP_VERSION_2}-mysql \
    php${PHP_VERSION_2}-opcache \
    php${PHP_VERSION_2}-xml \
    php${PHP_VERSION_2}-zip \
    php${PHP_VERSION_3} \
    php${PHP_VERSION_3}-common \
    php${PHP_VERSION_3}-bcmath \
    php${PHP_VERSION_3}-bz2 \
    php${PHP_VERSION_3}-cli \
    php${PHP_VERSION_3}-curl \
    php${PHP_VERSION_3}-fpm \
    php${PHP_VERSION_3}-gd \
    php${PHP_VERSION_3}-gmp \
    php${PHP_VERSION_3}-imagick \
    php${PHP_VERSION_3}-imap \
    php${PHP_VERSION_3}-intl \
    php${PHP_VERSION_3}-mbstring \
    php${PHP_VERSION_3}-mysql \
    php${PHP_VERSION_3}-opcache \
    php${PHP_VERSION_3}-xml \
    php${PHP_VERSION_3}-zip \
    php${PHP_VERSION_4} \
    php${PHP_VERSION_4}-common \
    php${PHP_VERSION_4}-bcmath \
    php${PHP_VERSION_4}-bz2 \
    php${PHP_VERSION_4}-cli \
    php${PHP_VERSION_4}-curl \
    php${PHP_VERSION_4}-fpm \
    php${PHP_VERSION_4}-gd \
    php${PHP_VERSION_4}-gmp \
    php${PHP_VERSION_4}-imagick \
    php${PHP_VERSION_4}-imap \
    php${PHP_VERSION_4}-intl \
    php${PHP_VERSION_4}-mbstring \
    php${PHP_VERSION_4}-mysql \
    php${PHP_VERSION_4}-opcache \
    php${PHP_VERSION_4}-xml \
    php${PHP_VERSION_4}-zip

# ======================================================================================================================
# AWStats
# ======================================================================================================================

RUN cp /usr/share/awstats/tools/awstats_buildstaticpages.pl /usr/bin/ && \
    mv /etc/awstats//awstats.conf /etc/awstats//awstats.model.conf && \
    sed -i.bak 's/^DirData/# DirData/' /etc/awstats//awstats.model.conf && \
    sed -i.bak 's|^\\(DirIcons=\\).*$|\\1\\"/awstats-icon\\"|' /etc/awstats//awstats.model.conf && \
    rm /etc/cron.d/awstats

# ======================================================================================================================
# Lib extrausers
# ======================================================================================================================

RUN mkdir -p /var/lib/extrausers && \
    touch /var/lib/extrausers/passwd && \
    touch /var/lib/extrausers/group && \
    touch /var/lib/extrausers/shadow

# ======================================================================================================================
# BIND DNS
# ======================================================================================================================

RUN echo "include \"/etc/bind/froxlor_bind.conf\";" >> /etc/bind/named.conf.local && \
    touch /etc/bind/froxlor_bind.conf && \
    chown bind:0 /etc/bind/froxlor_bind.conf && \
    chmod 0644 /etc/bind/froxlor_bind.conf

# ======================================================================================================================
# Froxlor user and group
# ======================================================================================================================

RUN groupadd -f froxlorlocal && \
    useradd -s /bin/false -g froxlorlocal froxlorlocal && \
    adduser www-data froxlorlocal

# ======================================================================================================================
# Froxlor directories
# ======================================================================================================================

RUN mkdir -p /var/www && \
    mkdir -p /var/customers/logs && \
    mkdir -p /var/customers/mail && \
    mkdir -p /var/customers/webs && \
    mkdir -p /var/customers/tmp && \
    mkdir -p /etc/ssl/froxlor

# ======================================================================================================================
# Filesystem
# ======================================================================================================================

COPY ./src/ /

# ======================================================================================================================
# Entrypoint
# ======================================================================================================================

ENTRYPOINT ["bash", "/start.sh"]
