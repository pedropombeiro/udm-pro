#!/bin/bash

DATA_DIR="/data"

source ${DATA_DIR}/scripts/.export_unbound_cache_env.sh

rm -rf ${DATA_DIR}/unbound/backup
mkdir -p ${DATA_DIR}/unbound/backup

set +e

if podman container exists ${CONTAINER}; then
  echo 'Saving Unbound cache...'
  suffix=$(podman exec ${CONTAINER} sh -c 'echo "-$(unbound-control get_option num-threads)-$(unbound-control get_option msg-cache-size)-$(unbound-control get_option rrset-cache-size)"')
  podman exec ${CONTAINER} unbound-control dump_cache >  "${CACHE_DUMP_PATH}"
  [[ -s $CACHE_DUMP_PATH ]] && echo 'Cache saved successfully' || echo 'Failed to save cache'
fi
