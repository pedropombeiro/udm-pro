#!/bin/bash

CONTAINER=ddns-updater

# Retry docker container creation until successful due to observed error:
# WARN[0000] Failed to load cached network config: network podman not found in CNI cache, falling back to loading network podman from disk
# WARN[0000] 1 error occurred:
# 	* plugin type="bridge" failed (delete): cni plugin bridge failed: running [/sbin/iptables -t nat -D POSTROUTING -s 10.88.0.78 -j CNI-6f218673df70a25fcab6e344 -m comment --comment name: "podman" id: "f5fdd863b71870b2a024c53612e7c0efae4ba546766d9e384bd63f50d8dcc7fb" --wait]: exit status 2: iptables v1.6.2: Couldn't load target `CNI-6f218673df70a25fcab6e344':No such file or directory
#
# Try `iptables -h' or 'iptables --help' for more information.
#
#
# Error: unable to start container "f5fdd863b71870b2a024c53612e7c0efae4ba546766d9e384bd63f50d8dcc7fb": plugin type="bridge" failed (add): cni plugin bridge failed: failed to set bridge addr: could not set bridge's mac: invalid argument
max_retry=10
counter=0

until [[ $counter -eq $max_retry ]]
do
  ((counter++))

  # Starts a ddns-updater container that is deleted after it is stopped.
  # Config stored in /data/etc-ddns-updater/config.json
  if podman container exists "${CONTAINER}"; then
    podman start "${CONTAINER}" && break
  else
    podman run -d \
      --name "${CONTAINER}" \
      --security-opt=no-new-privileges \
      -p 8001:8000/tcp \
      -e LISTENING_PORT=8000 \
      -e PUBLICIP_DNS_PROVIDERS=cloudflare \
      -e LOG_CALLER=short \
      -e TZ="$(cat /data/system/timezone)" \
      -v /data/etc-ddns-updater:/updater/data \
      docker.io/qmcgaw/ddns-updater && break
  fi

  sleep 30
done
