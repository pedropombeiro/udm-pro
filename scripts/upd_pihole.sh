#!/bin/sh

set -e

DOCKER_TAG=2022.11.1

chmod +r /mnt/data/etc-pihole/* /mnt/data/pihole/* /mnt/data/pihole/etc-dnsmasq.d/*
chmod 0664 /mnt/data/etc-pihole/gravity.db
rm -f /mnt/data/etc-pihole/macvendor.db
touch /mnt/data/etc-pihole/macvendor.db
chown 999:999 /mnt/data/etc-pihole/macvendor.db
chmod 0755 /mnt/data/etc-pihole/migration_backup/
chmod 0664 /mnt/data/etc-pihole/pihole-FTL.conf
chown 999:0 /mnt/data/etc-pihole/pihole-FTL.conf

set +e

# Change to boostchicken/pihole:latest for DoH
# Change to boostchicken/pihole-dote:latest for DoTE
IMAGE=pihole/pihole:$DOCKER_TAG

podman pull $IMAGE
echo 'Stopping Pi-hole'
podman stop pihole
echo 'Removing Pi-hole'
podman rm pihole
echo 'Starting new Pi-hole version'
podman run -d --network dns --restart always \
    --name pihole \
    -e TZ="$(cat /mnt/data/system/timezone)" \
    -v "/mnt/data/etc-pihole:/etc/pihole" \
    -v "/mnt/data/pihole/etc-dnsmasq.d:/etc/dnsmasq.d" \
    -v "/mnt/data/pihole/hosts:/etc/hosts:ro" \
    --dns=127.0.0.1 \
    --dns=1.1.1.1 \
    --dns=1.0.0.1 \
    --hostname pihole \
    -e VIRTUAL_HOST="pihole" \
    -e PROXY_LOCATION="pihole" \
    -e ServerIP="192.168.6.254" \
    -e PIHOLE_DNS_="1.1.1.1;1.0.0.1" \
    -e IPv6="False" \
    -e SKIPGRAVITYONBOOT=1 \
    -e DBIMPORT=yes \
    $IMAGE

echo 'Waiting for new Pi-hole version to start'
sleep 5 # Allow Pi-hole to start up

if curl --connect-timeout 0.5 -fsL 192.168.6.254/admin -o /dev/null; then
  docker system prune
else
  code=$?
  echo 'Pi-hole deployment unsuccessful!'
  exit ${code}
fi
