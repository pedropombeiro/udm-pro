#!/bin/sh

CONTAINER=ddns-updater

# Starts a ddns-updater container that is deleted after it is stopped.
# Config stored in /mnt/data/etc-ddns-updater/config.json
if podman container exists "${CONTAINER}"; then
  podman start "${CONTAINER}"
else
  podman run -i -d --rm \
    --name "${CONTAINER}" \
    --net="host" \
    --security-opt=no-new-privileges \
    -e LISTENING_PORT=8001 \
    -e LOG_CALLER=short \
    -e TZ=Europe/Zurich \
    --env-file /mnt/data/on_boot.d/files/.30-ddns-updater.env \
    -v /mnt/data/etc-ddns-updater:/updater/data \
    docker.io/qmcgaw/ddns-updater
fi
