#!/bin/bash

# CONTAINER=multicast-relay
#
# # kill all instances of avahi-daemon (UDM spins an instance up even with mDNS services disabled)
# killall avahi-daemon
#
# # Starts a multicast-relay container that is deleted after it is stopped.
# if podman container exists "${CONTAINER}"; then
#   podman start "${CONTAINER}"
# else
#   podman run -d \
#     --name "${CONTAINER}" \
#     --net="host" \
#     --security-opt=no-new-privileges \
#     --restart=always \
#     -e OPTS="--noSonosDiscovery" \
#     -e INTERFACES="eth8 br46 br56 br76 br96" \
#     -e TZ="$(cat /data/system/timezone)" \
#     scyto/multicast-relay
# fi
