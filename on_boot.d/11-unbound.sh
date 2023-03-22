#!/bin/bash

DATA_DIR=/data
CONTAINER=unbound
IMAGE=alpinelinux/unbound:latest

# Starts an unbound container that is used by Pi-Hole.
if [[ ! -f ${DATA_DIR}/unbound/etc/unbound_server.pem ]]; then
  echo 'Generating certificate for unbound_exporter'
  podman run --rm \
    -v "${DATA_DIR}/unbound/etc/:/etc/unbound/" \
    --entrypoint unbound-control-setup \
    ${IMAGE}
fi

if [[ ! -s ${DATA_DIR}/unbound/lib/root.hints ]]; then
  mkdir -p "${DATA_DIR}/unbound/lib"
  wget https://www.internic.net/domain/named.root -q -O "${DATA_DIR}/unbound/lib/root.hints"
fi

if [[ ! -f ${DATA_DIR}/unbound/lib/root.key ]]; then
  echo 'Generating root trust anchor for DNSSEC validation'
  podman run --rm \
    -e TZ="$(cat /data/system/timezone)" \
    -v "${DATA_DIR}/unbound/etc/:/etc/unbound/" \
    -v "${DATA_DIR}/unbound/lib/:/var/lib/unbound/" \
    --entrypoint '' \
    ${IMAGE} \
    sh -c 'chown -R unbound /var/lib/unbound && unbound-anchor -a /var/lib/unbound/root.key -r /var/lib/unbound/root.hints'
fi

if podman container exists "${CONTAINER}"; then
  podman start "${CONTAINER}"
else
  podman run -d --network host --restart always \
    --name "${CONTAINER}" \
    -e TZ="$(cat /data/system/timezone)" \
    -v "${DATA_DIR}/unbound/etc/:/etc/unbound/" \
    -v "${DATA_DIR}/unbound/lib/:/var/lib/unbound/" \
    -v "${DATA_DIR}/unbound/backup/:/var/tmp/unbound/" \
    ${IMAGE}
fi

${DATA_DIR}/scripts/restore_unbound_cache.sh
