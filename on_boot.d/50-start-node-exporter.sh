#!/bin/sh

CONTAINER=node-exporter

# Starts a ddclient container that is deleted after it is stopped.
# All configs stored in /mnt/data/ddclient
if podman container exists "$CONTAINER"; then
  podman start "$CONTAINER"
else
  podman run -d --rm --name "node-exporter" --net="host" --pid="host" -v "/:/host:ro,rslave" quay.io/prometheus/node-exporter:latest --path.rootfs=/host
fi
