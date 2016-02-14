#!/bin/sh

if [ ! -f "/etc/arch-mirror/config.yml" ]; then
  echo "No config file found, copying default one..."
  cp /etc/arch-mirror.config.default.yml /etc/arch-mirror/config.yml
  mkdir /etc/arch-mirror/logs
fi

if [ ! -f "/var/mirror/lastupdate" ]; then
  echo "Empty mirror ! Creating initial lastupdate..."
  echo "0" > /var/mirror/lastupdate
fi

exec "$@"
