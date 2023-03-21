#!/bin/bash

CONTAINER=unbound_exporter

# Starts a unbound_exporter container that is deleted after it is stopped.
if podman container exists "${CONTAINER}"; then
  podman start "${CONTAINER}"
else
  podman run -d --name "${CONTAINER}" \
    --network container:unbound \
    -e UNBOUND_HOST='tcp://localhost:8953' \
    -v /data/unbound/etc:/etc/unbound:ro \
    rsprta/unbound_exporter

  podman exec unbound_exporter apk add curl # Needed for HEALTHCHECK
fi
