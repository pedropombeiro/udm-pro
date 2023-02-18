#!/bin/sh

CONTAINER=ddns-updater

# Starts a ddns-updater container that is deleted after it is stopped.
# Config stored in /data/etc-ddns-updater/config.json
if podman container exists "${CONTAINER}"; then
  podman start "${CONTAINER}"
else
  podman run -d --rm \
    --name "${CONTAINER}" \
    --security-opt=no-new-privileges \
    -p 8001:8000/tcp \
    -e LISTENING_PORT=8000 \
    -e PUBLICIP_DNS_PROVIDERS=cloudflare \
    -e LOG_CALLER=short \
    -e TZ="$(cat /data/system/timezone)" \
    -v /data/etc-ddns-updater:/updater/data \
    docker.io/qmcgaw/ddns-updater
fi
