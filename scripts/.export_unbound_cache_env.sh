#!/bin/bash

DATA_DIR="/data"
CONTAINER=debian-dns

if machinectl show ${CONTAINER} | grep 'State=running'; then
  suffix=$(machinectl shell ${CONTAINER} /usr/bin/sh -c 'echo "-$(unbound-control get_option num-threads)-$(unbound-control get_option msg-cache-size)-$(unbound-control get_option rrset-cache-size)"' | sed -e 's/[[:space:]]*$//')
  CACHE_DUMP_PATH="${DATA_DIR}/unbound/backup/.cache_dump${suffix}"

  export CACHE_DUMP_PATH
fi

export DATA_DIR
export CONTAINER
