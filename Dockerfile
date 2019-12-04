FROM debian:stable-slim

# Time and location
ENV TZ=Europe/Berlin
ENV LOCALE="de_DE.UTF-8 UTF-8"

# PHP
ENV PHP_VERSION_OLD="7.3"
ENV PHP_VERSION="7.4"

# Froxlor
ENV FRX_VERSION="0.10.8"

# Webserver
EXPOSE 80
EXPOSE 443

# Update and upgrade package repositories
RUN apt-get update && apt-get upgrade -y --no-install-recommends

# Install required packages
RUN apt-get install -y --no-install-recommends \
	apt-utils \
    wget \
    curl \
    locales \
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

# Install NGINX, MariaDB, AWStats and Quota
RUN apt-get install -y --no-install-recommends \
    nginx \
    mariadb-client \
    awstats \
    quota \
    quotatool

# Configure AWStats
RUN cp /usr/share/awstats/tools/awstats_buildstaticpages.pl /usr/bin/ && \
    mv /etc/awstats//awstats.conf /etc/awstats//awstats.model.conf && \
    sed -i.bak 's/^DirData/# DirData/' /etc/awstats//awstats.model.conf && \
    sed -i.bak 's|^\\(DirIcons=\\).*$|\\1\\"/awstats-icon\\"|' /etc/awstats//awstats.model.conf && \
    rm /etc/cron.d/awstats

# Install PHP (old version)
RUN apt-get install -y --no-install-recommends \
    php${PHP_VERSION_OLD} \
    php${PHP_VERSION_OLD}-fpm \
    php${PHP_VERSION_OLD}-common \
    php${PHP_VERSION_OLD}-bcmath \
    php${PHP_VERSION_OLD}-bz2 \
    php${PHP_VERSION_OLD}-cli \
    php${PHP_VERSION_OLD}-curl \
    php${PHP_VERSION_OLD}-gd \
    php${PHP_VERSION_OLD}-imap \
    php${PHP_VERSION_OLD}-intl \
    php${PHP_VERSION_OLD}-json \
    php${PHP_VERSION_OLD}-mbstring \
    php${PHP_VERSION_OLD}-mysql \
    php${PHP_VERSION_OLD}-opcache \
    php${PHP_VERSION_OLD}-xml \
    php${PHP_VERSION_OLD}-zip

# Install PHP (current version)
RUN apt-get install -y --no-install-recommends \
    php${PHP_VERSION} \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-common \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-bz2 \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-imap \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-json \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-opcache \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-zip

# Install additional packages
RUN apt-get install -y --no-install-recommends \
    cron \
    nscd \
    letsencrypt \
    logrotate \
    libnss-extrausers

# Configure cron
COPY ./etc/cron.d/froxlor /etc/cron.d/froxlor

# Configure logrotate
COPY ./etc/logrotate.d/froxlor /etc/logrotate.d/froxlor

# Configure libnss-extrausers
RUN mkdir -p /var/lib/extrausers && \
    touch /var/lib/extrausers/passwd && \
    touch /var/lib/extrausers/group && \
    touch /var/lib/extrausers/shadow

COPY ./etc/nsswitch.conf /etc/nsswitch.conf

# Create Froxlor user and group
RUN addgroup --gid 9999 froxlorlocal && \
    adduser --no-create-home --uid 9999 --ingroup froxlorlocal --shell /bin/false --disabled-password --gecos '' froxlorlocal && \
    adduser www-data froxlorlocal

# Create Froxlor web and customers directories
RUN mkdir -p /var/www && \
    mkdir -p /var/customers/logs && \
    mkdir -p /var/customers/mail && \
    mkdir -p /var/customers/webs && \
    mkdir -p /var/customers/tmp

# Create Froxlor / Let's Encrypt SSL directory
RUN mkdir -p /etc/ssl/froxlor

# Download Froxlor
RUN cd /var/www/ && \
    wget https://files.froxlor.org/releases/froxlor-${FRX_VERSION}.tar.gz && \
    tar xvfz froxlor-${FRX_VERSION}.tar.gz && \
    rm froxlor-${FRX_VERSION}.tar.gz && \
    chown -R froxlorlocal:froxlorlocal /var/www/froxlor/

# Add NGINX configuration
COPY ./etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./etc/nginx/fastcgi_params /etc/nginx/fastcgi_params
COPY ./etc/nginx/acme.conf /etc/nginx/acme.conf
COPY ./etc/nginx/conf.d/ /etc/nginx/conf.d/

COPY ./start.sh /start.sh

ENTRYPOINT ["bash", "/start.sh"]
