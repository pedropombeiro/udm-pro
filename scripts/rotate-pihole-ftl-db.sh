#!/bin/sh

set -e

podman stop pihole && \
  mv /data/etc-pihole/pihole-FTL.db /data/etc-pihole/pihole-FTL_$(date +"%m-%y").db
podman start pihole
