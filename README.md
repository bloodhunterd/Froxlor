[![Release](https://img.shields.io/github/v/release/bloodhunterd/froxlor-docker?include_prereleases&style=for-the-badge)](https://github.com/bloodhunterd/froxlor-docker/releases)
[![Docker Build](https://img.shields.io/docker/cloud/build/bloodhunterd/froxlor?style=for-the-badge)](https://hub.docker.com/r/bloodhunterd/froxlor)
[![Docker Pulls](https://img.shields.io/docker/pulls/bloodhunterd/froxlor?style=for-the-badge)](https://hub.docker.com/r/bloodhunterd/froxlor)
[![License](https://img.shields.io/github/license/bloodhunterd/froxlor-docker?style=for-the-badge)](https://github.com/bloodhunterd/froxlor-docker/blob/master/LICENSE)

[![ko-fi](https://www.ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/P5P51U5SZ)

# Froxlor Docker

Docker image for Froxlor Server Management Panel.

## Deployment

### Installation

Download the distributed Docker Compose file and adjust it for your needs.

[![Docker Compose](https://img.shields.io/github/size/bloodhunterd/froxlor-docker/docker-compose.dist.yml?label=Docker%20Compose&style=for-the-badge)](https://github.com/bloodhunterd/froxlor-docker/blob/master/docker-compose.dist.yml)

Download Froxlor from the Froxlor website and mount it into the container for individually setup.

[![Froxlor website](https://img.shields.io/badge/Froxlor-Website-blue?style=for-the-badge)](https://https://froxlor.org/)

### Configuration

| ENV | Values¹ | Default | Description
|--- |--- |--- |---
| TZ | [PHP: List of supported timezones - Manual](https://www.php.net/manual/en/timezones.php) | Europe/Berlin | Timezone.

### Ports

| Port | Description
|--- |---
| 53 | Bind DNS.
| 80 | HTTP port.
| 443 | HTTPS port.

### Volumes

| Volume | Path | Read only | Description
|--- |--- |--- |---
| Froxlor | /var/www/froxlor/ | &#10008; | Froxlor Server Management Panel. *Need to persist to use the build in update process.*
| Customers | /var/customers/ | &#10008; | Froxlor customer web, mail and log contents.
| SSL certificates | /etc/ssl/froxlor/ | &#10008; | SSL certificates.
&#10004; Yes &#10008; No

## Update

Please note the [changelog](https://github.com/bloodhunterd/froxlor-docker/blob/master/CHANGELOG.md) to check for configuration changes before updating.

```bash
docker-compose pull
docker-compose up -d
```

## Build With

* [Froxlor](https://froxlor.org/)
* [NGINX](https://www.nginx.com/)
* [MariaDB](https://mariadb.org/)
* [PHP](https://www.php.net/)
* [BIND](https://www.isc.org/bind/)
* [Let's Encrypt](https://letsencrypt.org/)
* [Debian](https://www.debian.org/)
* [Docker](https://www.docker.com/)

## Authors

* [BloodhunterD](https://github.com/bloodhunterd)

## License

This project is licensed under the MIT - see [LICENSE.md](https://github.com/bloodhunterd/froxlor-docker/blob/master/LICENSE) file for details.
