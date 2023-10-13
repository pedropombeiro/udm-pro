#!/bin/bash

DATA_DIR="/data"

source ${DATA_DIR}/scripts/.export_unbound_cache_env.sh

mkdir -p ${DATA_DIR}/unbound/backup

set +e

if machinectl show "${CONTAINER}" | grep 'State=running'; then
  echo 'Saving Unbound cache...'
  machinectl shell "${CONTAINER}" /usr/sbin/unbound-control dump_cache > "${CACHE_DUMP_PATH}"
  domains=$(grep -E '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' < "${CACHE_DUMP_PATH}" | \
    sed --regexp-extended 's/([a-z0-9\-\.]+)\.\s+.*/\1/' | \
    sort | uniq | wc -l)

  [[ -s "$CACHE_DUMP_PATH" ]] && echo "Cache saved successfully (${domains} domains)" || echo 'Failed to save cache'
fi
