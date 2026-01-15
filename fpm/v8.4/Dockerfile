# --- 1. BASE IMAGE & METADATA ---
# Using Debian-based PHP 8.4-FPM for performance and stability
FROM php:8.4-fpm
LABEL maintainer="Yudhistira Ramadhan <ramainvicta@email.com>"

# --- 2. USER CONFIGURATION ---
# We create a static 'app' user. The entrypoint will dynamically remap 
# this user's UID/GID at runtime to match your host folder permissions.
RUN groupadd -r app && useradd -r -m -s /bin/bash -g app app

# --- 3. ENVIRONMENT & SCAN DIRECTORY ---
# PHP_INI_SCAN_DIR includes system defaults + custom folder.
# BUN_INSTALL and PATH are configured so 'bun' is globally accessible.
ENV PHP_INI_SCAN_DIR=:/usr/local/etc/php/conf.user.d
ENV HOME=/home/app
ENV BUN_INSTALL=/usr/local
ENV PATH="$BUN_INSTALL/bin:$PATH"

# --- 4. SYSTEM & REPOSITORY SETUP ---
# Enable 'contrib' and 'non-free' for fonts and proprietary tools
RUN . /etc/os-release && \
    echo "deb http://deb.debian.org/debian ${VERSION_CODENAME} contrib non-free" > /etc/apt/sources.list.d/contrib.list && \
    apt-get update && apt-get -y upgrade && \
    apt-get install -y --no-install-recommends \
    bash git openssh-client sshpass rsync wget nano curl procps telnet \
    unzip cabextract zlib1g-dev \
    libzip-dev libbz2-dev libxml2-dev libpq-dev libfreetype6-dev \
    libjpeg62-turbo-dev libpng-dev libldap2-dev libmagickwand-dev \
    nginx supervisor gosu \
    libreoffice ghostscript fontconfig ttf-mscorefonts-installer && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# --- 5. PHP EXTENSION INSTALLATION ---
RUN docker-php-ext-configure gd --with-jpeg --with-freetype && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu && \
    docker-php-ext-install -j$(nproc) \
    pcntl gd iconv intl bcmath zip bz2 \
    opcache exif pdo_mysql mysqli pdo_pgsql pgsql ldap && \
    pecl install redis imagick && \
    docker-php-ext-enable redis imagick

# --- 6. BUN, COMPOSER & RUNTIME TOOLS ---
# Install Bun (JavaScript runtime & package manager)
RUN curl -fsSL https://bun.sh/install | bash && \
    # Composer for PHP dependency management
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    # Supercronic for high-reliability cron jobs
    curl -fsSLO "https://github.com/aptible/supercronic/releases/download/v0.2.33/supercronic-linux-amd64" && \
    chmod +x "supercronic-linux-amd64" && mv "supercronic-linux-amd64" /usr/local/bin/supercronic

# --- 7. NGINX & SUPERVISOR CONFIGURATION ---
# Adjusting Nginx for unprivileged execution
RUN touch /run/nginx.pid && \
    sed -i '/^user/d' /etc/nginx/nginx.conf && \
    sed -i '/sendfile/s/on;/off;/' /etc/nginx/nginx.conf

# Restore Nginx fragments and configs
COPY nginx/default.conf /etc/nginx/sites-enabled/default
COPY nginx/conf.d /etc/nginx/conf.d
COPY nginx/fragments /etc/nginx/fragments

# Restore Supervisor config and handle placeholder
RUN mkdir -p /etc/supervisor/conf.user.d
RUN echo '' > /etc/supervisor/supervisord.pid
COPY supervisor/supervisord.conf /etc/supervisord.conf
COPY supervisor/conf.d /etc/supervisor/conf.d

# Match PHP-FPM socket permissions to 'app' user
RUN sed -i "s/listen.owner = .*/listen.owner = app/" /usr/local/etc/php-fpm.d/www.conf && \
    sed -i "s/listen.group = .*/listen.group = app/" /usr/local/etc/php-fpm.d/www.conf

# --- 8. WORKSPACE & ENTRYPOINT ---
RUN mkdir -p /app/default
WORKDIR /app/default

# Copy boot scripts and shell configurations
COPY fpm/default.ini /usr/local/etc/php/conf.d/99-overrides.ini
COPY fpm/entrypoint.sh /usr/local/entrypoint.sh
COPY fpm/crontab /usr/local/crontab
COPY fpm/.bashrc /usr/local/.bashrc
RUN chmod +x /usr/local/entrypoint.sh

# Entrypoint fixes permissions then drops to 'app' via gosu
USER root
ENTRYPOINT ["/usr/local/entrypoint.sh"]