#!/bin/bash

DATA_DIR="/data"
CONTAINER=pihole
CACHE_DUMP_PATH=${DATA_DIR}/unbound/backup/.cache_dump

if [[ -s ${CACHE_DUMP_PATH} ]]; then
  echo 'Restoring Unbound cache...'
  podman exec -i ${CONTAINER} unbound-control load_cache < $CACHE_DUMP_PATH
fi
