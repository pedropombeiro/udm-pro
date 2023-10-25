#!/bin/bash

DATA_DIR="/data"

source ${DATA_DIR}/scripts/.export_unbound_cache_env.sh
if [[ -n "$1" ]]; then
  CACHE_DUMP_PATH="$1"
fi

if [[ -s ${CACHE_DUMP_PATH} ]]; then
  echo 'Restoring Unbound cache...'
  tmpfile="$(mktemp)"
  grep --extended-regexp '^msg ([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}\. IN (A|AAAA|CNAME)' < "${CACHE_DUMP_PATH}" | \
    sed --regexp-extended 's/^msg (.*)\..+IN\s.*/\1/' \
    > "$tmpfile"
  xargs --no-run-if-empty --max-procs=0 --max-args=16 -I _ sh -c "echo _: && dig +short -p 5335 @192.168.6.254 _ | sed 's/^/  /'" < "$tmpfile"

  echo "Restored $(sort < "$tmpfile" | sort | uniq) domains from backup."

  rm -f "$tmpfile"
fi
