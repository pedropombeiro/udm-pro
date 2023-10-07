#!/bin/bash

DATA_DIR="/data"

source ${DATA_DIR}/scripts/.export_unbound_cache_env.sh

rm -rf ${DATA_DIR}/unbound/backup
mkdir -p ${DATA_DIR}/unbound/backup

set +e

if machinectl show ${CONTAINER} | grep 'State=running'; then
  echo 'Saving Unbound cache...'
  machinectl shell ${CONTAINER} /usr/sbin/unbound-control dump_cache > "${CACHE_DUMP_PATH}"
  [[ -s $CACHE_DUMP_PATH ]] && echo 'Cache saved successfully' || echo 'Failed to save cache'
fi
