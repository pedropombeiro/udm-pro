#!/bin/bash

DATA_DIR="/data"
CONTAINER=pihole
CACHE_DUMP_PATH=${DATA_DIR}/unbound/backup/.cache_dump

rm -rf ${DATA_DIR}/unbound/backup
mkdir -p ${DATA_DIR}/unbound/backup

set +e

if podman container exists ${CONTAINER}; then
  echo 'Saving Unbound cache...'
  podman exec ${CONTAINER} unbound-control dump_cache > $CACHE_DUMP_PATH
  [[ -s $CACHE_DUMP_PATH ]] && echo 'Cache saved successfully' || echo 'Failed to save cache'
fi
