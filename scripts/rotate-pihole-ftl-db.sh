#!/bin/sh

set -e

docker stop pihole && \
  mv /mnt/data/etc-pihole/pihole-FTL.db /mnt/data/etc-pihole/pihole-FTL_$(date +"%m-%y").db
docker start pihole

