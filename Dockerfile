FROM debian:stable-slim

# Froxlor
ARG VERSION=0.10.15

# Timezone
ENV TZ Europe/Berlin

# PHP
ENV PHP_VERSION_SFO 7.2
ENV PHP_VERSION_PREV 7.3
ENV PHP_VERSION_MAIN 7.4

# NGINX
EXPOSE 80
EXPOSE 443

# Update and upgrade package repositories
RUN apt-get update && \
    apt-get upgrade -y --no-install-recommends

# Install required packages
RUN apt-get install -y --no-install-recommends \
	apt-utils \
    wget \
    curl \
    locales \
    locales-all \
    gnupg2 \
    dirmngr \
    lsb-release \
    ca-certificates \
    apt-transport-https \
    software-properties-common \
    unattended-upgrades \
    apt-listchanges

# Configure NGINX repository
RUN echo "deb http://nginx.org/packages/mainline/debian `lsb_release -cs` nginx" \
    | tee /etc/apt/sources.list.d/nginx.list && \
    curl -fsSL https://nginx.org/keys/nginx_signing.key \
    | apt-key add -

# Configure PHP repository
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'

# Configure MariaDB repository
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8 && \
    add-apt-repository 'deb [arch=amd64] http://ftp.hosteurope.de/mirror/mariadb.org/repo/10.4/debian buster main'

# Update package repositories
RUN apt-get update

# Install NGINX, MariaDB, AwStats, Cron and Let's Encrypt
RUN apt-get install -y --no-install-recommends \
    nginx \
    mariadb-client \
    awstats \
    cron \
    nscd \
    letsencrypt \
    logrotate \
    libnss-extrausers

# Install PHP versions
RUN apt-get install -y --no-install-recommends \
    php${PHP_VERSION_SFO} \
    php${PHP_VERSION_SFO}-fpm \
    php${PHP_VERSION_SFO}-common \
    php${PHP_VERSION_SFO}-bcmath \
    php${PHP_VERSION_SFO}-bz2 \
    php${PHP_VERSION_SFO}-cli \
    php${PHP_VERSION_SFO}-curl \
    php${PHP_VERSION_SFO}-gd \
    php${PHP_VERSION_SFO}-imap \
    php${PHP_VERSION_SFO}-intl \
    php${PHP_VERSION_SFO}-json \
    php${PHP_VERSION_SFO}-mbstring \
    php${PHP_VERSION_SFO}-mysql \
    php${PHP_VERSION_SFO}-opcache \
    php${PHP_VERSION_SFO}-xml \
    php${PHP_VERSION_SFO}-zip \
    php${PHP_VERSION_PREV} \
    php${PHP_VERSION_PREV}-fpm \
    php${PHP_VERSION_PREV}-common \
    php${PHP_VERSION_PREV}-bcmath \
    php${PHP_VERSION_PREV}-bz2 \
    php${PHP_VERSION_PREV}-cli \
    php${PHP_VERSION_PREV}-curl \
    php${PHP_VERSION_PREV}-gd \
    php${PHP_VERSION_PREV}-imap \
    php${PHP_VERSION_PREV}-intl \
    php${PHP_VERSION_PREV}-json \
    php${PHP_VERSION_PREV}-mbstring \
    php${PHP_VERSION_PREV}-mysql \
    php${PHP_VERSION_PREV}-opcache \
    php${PHP_VERSION_PREV}-xml \
    php${PHP_VERSION_PREV}-zip \
    php${PHP_VERSION_MAIN} \
    php${PHP_VERSION_MAIN}-fpm \
    php${PHP_VERSION_MAIN}-common \
    php${PHP_VERSION_MAIN}-bcmath \
    php${PHP_VERSION_MAIN}-bz2 \
    php${PHP_VERSION_MAIN}-cli \
    php${PHP_VERSION_MAIN}-curl \
    php${PHP_VERSION_MAIN}-gd \
    php${PHP_VERSION_MAIN}-imap \
    php${PHP_VERSION_MAIN}-intl \
    php${PHP_VERSION_MAIN}-json \
    php${PHP_VERSION_MAIN}-mbstring \
    php${PHP_VERSION_MAIN}-mysql \
    php${PHP_VERSION_MAIN}-opcache \
    php${PHP_VERSION_MAIN}-xml \
    php${PHP_VERSION_MAIN}-zip

# Configure AWStats
RUN cp /usr/share/awstats/tools/awstats_buildstaticpages.pl /usr/bin/ && \
    mv /etc/awstats//awstats.conf /etc/awstats//awstats.model.conf && \
    sed -i.bak 's/^DirData/# DirData/' /etc/awstats//awstats.model.conf && \
    sed -i.bak 's|^\\(DirIcons=\\).*$|\\1\\"/awstats-icon\\"|' /etc/awstats//awstats.model.conf && \
    rm /etc/cron.d/awstats

# Configure libnss-extrausers
RUN mkdir -p /var/lib/extrausers && \
    touch /var/lib/extrausers/passwd && \
    touch /var/lib/extrausers/group && \
    touch /var/lib/extrausers/shadow

# Create Froxlor user and group
RUN addgroup --gid 9999 froxlorlocal && \
    adduser --no-create-home --uid 9999 --ingroup froxlorlocal --shell /bin/false --disabled-password --gecos '' froxlorlocal && \
    adduser www-data froxlorlocal

# Create Froxlor web, customers and SSL directories
RUN mkdir -p /var/www && \
    mkdir -p /var/customers/logs && \
    mkdir -p /var/customers/mail && \
    mkdir -p /var/customers/webs && \
    mkdir -p /var/customers/tmp && \
    mkdir -p /etc/ssl/froxlor

# Download Froxlor
RUN cd /var/www/ && \
    wget https://files.froxlor.org/releases/froxlor-${VERSION}.tar.gz && \
    tar xvfz froxlor-${VERSION}.tar.gz && \
    rm froxlor-${VERSION}.tar.gz && \
    chown -R froxlorlocal:froxlorlocal /var/www/froxlor/

# Add NGINX configuration
COPY ./etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./etc/nginx/fastcgi_params /etc/nginx/fastcgi_params
COPY ./etc/nginx/acme.conf /etc/nginx/acme.conf
COPY ./etc/nginx/conf.d/ /etc/nginx/conf.d/

# Add Cron configuration
COPY ./etc/cron.d/froxlor /etc/cron.d/froxlor

# Add log rotation configuration
COPY ./etc/logrotate.d/froxlor /etc/logrotate.d/froxlor

# Add nsswitch configuration
COPY ./etc/nsswitch.conf /etc/nsswitch.conf

# Add entrypoint
COPY ./start.sh /start.sh

ENTRYPOINT ["bash", "/start.sh"]
