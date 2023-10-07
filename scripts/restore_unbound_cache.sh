#!/bin/bash

DATA_DIR="/data"

source ${DATA_DIR}/scripts/.export_unbound_cache_env.sh

if [[ -s ${CACHE_DUMP_PATH} ]]; then
  echo 'Restoring Unbound cache...'
  systemd-run --pipe --machine ${CONTAINER} unbound-control load_cache < "${CACHE_DUMP_PATH}"
fi
