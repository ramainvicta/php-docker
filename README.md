# PHP FPM Docker Images

Production-ready Docker images for PHP FPM (8.0, 8.1, 8.4), bundled with Nginx, Supervisor, Bun, Composer, and essential development tools. Designed for robust web application hosting with dynamic user remapping for seamless local development.

## Features

-   **Multiple PHP Versions:** 8.0, 8.1, 8.4 (Debian-based)
-   **Nginx:** Unprivileged, reverse proxy ready
-   **Supervisor:** Process manager for multi-service orchestration
-   **Bun:** JavaScript runtime & package manager
-   **Composer:** PHP dependency manager
-   **Supercronic:** Reliable cron jobs
-   **LibreOffice, Ghostscript, MS Fonts:** For document processing
-   **Dynamic UID/GID remapping:** `app` user matches host permissions
-   **Pre-installed PHP extensions:** `gd`, `intl`, `bcmath`, `zip`, `bz2`, `opcache`, `exif`, `pdo_mysql`, `mysqli`, `pgsql`, `ldap`, `redis`, `imagick`, and more

## Requirements

-   Docker (tested with 20.10+)
-   Bash shell (for build script)
-   Linux or macOS recommended

## Building Images

Use the provided `build.sh` script to interactively build any supported PHP version:

```bash
./build.sh
```

You will be prompted to select a PHP version (8.0, 8.1, or 8.4) and whether to use Docker's `--no-cache` option.

Alternatively, build manually:

```bash
docker build -t ramainvicta/php:8.4-fpm -f fpm/v8.4/Dockerfile .
```

## Usage

```bash
docker run -it --rm \
    -v $(pwd)/app:/app/default \
    -p 8080:80 \
    ramainvicta/php:8.4-fpm
```

-   Mount your application code to `/app/default`.
-   The container remaps the `app` user to match your host's UID/GID for seamless file permissions.

## Directory Structure

```
.
├── build.sh
├── fpm/
│   ├── .bashrc
│   ├── crontab
│   ├── default.ini
│   ├── entrypoint.sh
│   └── v8.0/
│       └── Dockerfile
│   └── v8.1/
│       └── Dockerfile
│   └── v8.4/
│       └── Dockerfile
├── nginx/
│   ├── default.conf
│   ├── conf.d/
│   └── fragments/
├── supervisor/
│   ├── supervisord.conf
│   └── conf.d/
└── README.md
```

## Entrypoint

The `entrypoint.sh` script:

-   Syncs the `app` user/group to match your host's UID/GID.
-   Prepares environment and permissions.
-   Launches Supervisor as the `app` user.

## Working Directory

The default working directory inside the container is `/app/default`. All PHP, Nginx, and Supervisor processes operate from this directory.

## Customization

You can customize the image by mounting your own configuration directories using `docker run` or Docker Compose:

-   **PHP:** Mount custom `.ini` files to `/usr/local/etc/php/conf.user.d`
-   **Supervisor:** Mount custom config files to `/etc/supervisor/conf.user.d`
-   **SSH:** Mount your SSH keys/config to `/home/app/.ssh`

Example with `docker run`:

```bash
docker run -it --rm \
    -v $(pwd)/php-config:/usr/local/etc/php/conf.user.d \
    -v $(pwd)/supervisor-config:/etc/supervisor/conf.user.d \
    -v ~/.ssh:/home/app/.ssh \
    ramainvicta/php:8.4-fpm
```

## License

MIT

---

**Maintainer:** Yudhistira Ramadhan (<ramainvicta@email.com>)
