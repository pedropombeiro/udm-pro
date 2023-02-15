#!/bin/sh

CONTAINER=ddns-updater

# Starts a ddns-updater container that is deleted after it is stopped.
# Config stored in /data/etc-ddns-updater/config.json
if podman container exists "${CONTAINER}"; then
  podman start "${CONTAINER}"
else
  podman run -i -d --rm \
    --name "${CONTAINER}" \
    --net="host" \
    --security-opt=no-new-privileges \
    -e ROOT_URL=/ddns \
    -e LISTENING_PORT=8001 \
    -e PUBLICIP_DNS_PROVIDERS=cloudflare \
    -e LOG_CALLER=short \
    -e TZ="$(cat /data/system/timezone)" \
    -v /data/etc-ddns-updater:/updater/data \
    docker.io/qmcgaw/ddns-updater
fi
