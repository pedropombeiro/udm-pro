#!/bin/bash

DATA_DIR="/data"

source ${DATA_DIR}/scripts/.export_unbound_cache_env.sh

mkdir -p ${DATA_DIR}/unbound/backup

set +e

if machinectl show "${CONTAINER}" | grep 'State=running'; then
  echo 'Saving Unbound cache...'
  machinectl shell "${CONTAINER}" /usr/sbin/unbound-control dump_cache > "${CACHE_DUMP_PATH}"
  domains=$( grep --extended-regexp '^msg ([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}\. IN (A|AAAA|CNAME)' < "${CACHE_DUMP_PATH}" | \
    sed --regexp-extended 's/^msg (.*)\..+IN\s.*/\1/' | \
    wc -l)

  [[ -s "$CACHE_DUMP_PATH" ]] && echo "Cache saved successfully (${domains} domains)" || echo 'Failed to save cache'
fi
