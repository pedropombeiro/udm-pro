#!/bin/bash

DATA_DIR="/data"

source ${DATA_DIR}/scripts/.export_unbound_cache_env.sh

if [[ -s ${CACHE_DUMP_PATH} ]]; then
  echo 'Restoring Unbound cache...'
  tmpfile="$(mktemp)"
  grep -E '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' < "${CACHE_DUMP_PATH}" | \
    sed --regexp-extended 's/([a-z0-9\-\.]+)\.\s+.*/\1/' | \
    sort | uniq > "$tmpfile"
  xargs --no-run-if-empty --max-procs=0 --max-args=16 -I _ sh -c "echo _: && dig +short -p 5335 @192.168.6.254 _ | sed 's/^/  /'" < "$tmpfile"

  echo "Restored $(wc -l < "$tmpfile") domains from backup."

  rm -f "$tmpfile"
fi
