#!/bin/bash

DATA_DIR="/data"
CONTAINER=unbound

if podman container exists ${CONTAINER}; then
  suffix=$(podman exec ${CONTAINER} sh -c 'echo "-$(unbound-control get_option num-threads)-$(unbound-control get_option msg-cache-size)-$(unbound-control get_option rrset-cache-size)"')
  CACHE_DUMP_PATH="${DATA_DIR}/unbound/backup/.cache_dump${suffix}"

  export CACHE_DUMP_PATH
fi

export DATA_DIR
export CONTAINER
