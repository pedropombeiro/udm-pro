#!/bin/bash

DATA_DIR="/data"
CONTAINER=debian-dns

if machinectl show ${CONTAINER} | grep 'State=running'; then
  CACHE_DUMP_PATH="${DATA_DIR}/unbound/backup/.cache_dump"

  export CACHE_DUMP_PATH
fi

export DATA_DIR
export CONTAINER
