#!/bin/bash

DATA_DIR=/data
CONTAINER=unbound

# Starts an unbound container that is used by Pi-Hole.
if [[ ! -f ${DATA_DIR}/unbound/etc/unbound_server.pem ]]; then
  echo 'Generating certificate for unbound_exporter'
  podman run --rm \
    -v "${DATA_DIR}/unbound/etc/:/etc/unbound/" \
    --entrypoint unbound-control-setup \
    alpinelinux/unbound:latest
fi

if [[ ! -s ${DATA_DIR}/unbound/lib/root.hints ]]; then
  mkdir -p "${DATA_DIR}/unbound/lib"
  wget https://www.internic.net/domain/named.root -q -O "${DATA_DIR}/unbound/lib/root.hints"
fi

if podman container exists "${CONTAINER}"; then
  podman start "${CONTAINER}"
else
  podman run -d --network host --restart always \
    --name "${CONTAINER}" \
    -e TZ="$(cat /data/system/timezone)" \
    -v "${DATA_DIR}/unbound/etc/:/etc/unbound/" \
    -v "${DATA_DIR}/unbound/lib/root.hints:/var/lib/unbound/root.hints:ro" \
    -v "${DATA_DIR}/unbound/backup/:/var/tmp/unbound/" \
    alpinelinux/unbound:latest
fi

${DATA_DIR}/scripts/restore_unbound_cache.sh
