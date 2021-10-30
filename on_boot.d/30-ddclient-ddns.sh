#!/bin/sh

CONTAINER=ddclient

# Starts a ddclient container that is deleted after it is stopped.
# All configs stored in /mnt/data/etc-ddclient
if podman container exists "$CONTAINER"; then
  podman start "$CONTAINER"
else
  podman run -i -d --rm \
    --name "$CONTAINER" \
    --net="host" \
    --security-opt=no-new-privileges \
    -e PUID=0 \
    -e PGID=0 \
    -e TZ=Europe/Zurich \
    -v /mnt/data/etc-ddclient:/config \
    docker.io/linuxserver/ddclient:latest
fi
