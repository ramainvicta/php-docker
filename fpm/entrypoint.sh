#!/bin/bash
set -e

# Detect Host UID/GID (Default to 1000)
HOST_UID=$(stat -c '%u' /app/default 2>/dev/null || echo 1000)
HOST_GID=$(stat -c '%g' /app/default 2>/dev/null || echo 1000)

echo "--> Syncing 'app' user to Host UID: $HOST_UID GID: $HOST_GID"

# Re-map the static 'app' user to match your host
groupmod -g "$HOST_GID" app
usermod -u "$HOST_UID" -g "$HOST_GID" app

# Prepare environment
cp /usr/local/.bashrc /home/app/.bashrc
cp /usr/local/crontab /home/app/crontab

chown -R app:app \
    /home/app \
    /app \
    /etc/supervisor \
    /var/lib/nginx \
    /var/log/nginx \
    /var/log/supervisor \
    /run/nginx.pid

# Start Supervisor as the 'app' user
exec gosu app supervisord -n -c /etc/supervisord.conf