#!/bin/bash
# Get DataDir location
DATA_DIR="/data"
case "$(ubnt-device-info firmware || true)" in
1*)
    DATA_DIR="/mnt/data"
    ;;
2*)
    DATA_DIR="/data"
    ;;
3*)
    DATA_DIR="/data"
    ;;
*)
    echo "ERROR: No persistent storage found." 1>&2
    exit 1
    ;;
esac

# Check if the directory exists
if [ ! -d "${DATA_DIR}/pihole" ]; then
    # If it does not exist, create the directory
    mkdir -p "${DATA_DIR}/pihole"
    mkdir -p "${DATA_DIR}/pihole/etc"
    echo "Directory '${DATA_DIR}/pihole' created."
else
    # If it already exists, print a message
    echo "Directory '${DATA_DIR}/pihole' already exists. Moving on."
fi
set -e

DOCKER_IMAGE=pombeirp/pihole-unbound
DOCKER_TAG=latest

echo 'Pulling new Pi-hole base image...'
podman pull ${DOCKER_IMAGE}:${DOCKER_TAG}

chmod +r ${DATA_DIR}/etc-pihole/* ${DATA_DIR}/pihole/* ${DATA_DIR}/pihole/etc-dnsmasq.d/*
chmod 0664 ${DATA_DIR}/etc-pihole/gravity.db
rm -f ${DATA_DIR}/etc-pihole/macvendor.db
touch ${DATA_DIR}/etc-pihole/macvendor.db
chown -R root:1000 ${DATA_DIR}/etc-pihole/
mkdir -p ${DATA_DIR}/etc-pihole/migration_backup/
chmod 0755 ${DATA_DIR}/etc-pihole/migration_backup/
touch ${DATA_DIR}/etc-pihole/pihole-FTL.conf
chmod 0664 ${DATA_DIR}/etc-pihole/pihole-FTL.conf
chown root:1000 ${DATA_DIR}/etc-pihole/pihole-FTL.conf
rm -rf ${DATA_DIR}/unbound/backup
mkdir -p ${DATA_DIR}/unbound/backup

podman run --rm \
  -v "${DATA_DIR}/unbound/etc:/etc/unbound:ro" \
  --entrypoint unbound-checkconf \
  ${DOCKER_IMAGE}:${DOCKER_TAG}

if [[ ! -f ${DATA_DIR}/unbound/etc/unbound_server.pem ]]; then
  echo 'Generating certificate for unbound_exporter'
  podman run --rm \
    -v "${DATA_DIR}/unbound/etc:/etc/unbound" \
    --entrypoint unbound-control-setup \
    ${DOCKER_IMAGE}:${DOCKER_TAG}
fi

set +e

CACHE_DUMP_PATH=${DATA_DIR}/unbound/backup/.cache_dump
if podman container exists pihole; then
  echo 'Saving Unbound cache...'
  podman exec pihole unbound-control dump_cache > $CACHE_DUMP_PATH
  [[ -s $CACHE_DUMP_PATH ]] && echo 'Cache saved successfully' || echo 'Failed to save cache'
  echo 'Stopping Pi-hole...'
  podman stop pihole
  echo 'Removing Pi-hole...'
  podman rm pihole
fi

echo 'Starting new Pi-hole version...'
podman run -d --network dns --restart always \
    --name pihole \
    -e TZ="$(cat ${DATA_DIR}/system/timezone)" \
    -v "${DATA_DIR}/etc-pihole:/etc/pihole" \
    -v "${DATA_DIR}/pihole/etc-dnsmasq.d/03-user.conf:/etc/dnsmasq.d/03-user.conf" \
    -v "${DATA_DIR}/pihole/hosts:/etc/hosts:ro" \
    -v "${DATA_DIR}/unbound/etc/:/etc/unbound/" \
    -v "${DATA_DIR}/unbound/backup/:/var/tmp/unbound/" \
    --dns=127.0.0.1 \
    --hostname pihole \
    --cap-add=SYS_NICE \
    --env-file=${DATA_DIR}/scripts/pihole-unbound.env \
    ${DOCKER_IMAGE}:${DOCKER_TAG}

echo 'Waiting for new Pi-hole version to start...'
sleep 5 # Allow Pi-hole to start up

if curl --connect-timeout 0.5 -fsL 192.168.6.254/admin -o /dev/null; then
  if [[ -s ${CACHE_DUMP_PATH} ]]; then
    echo 'Restoring Unbound cache...'
    podman exec -i pihole unbound-control load_cache < $CACHE_DUMP_PATH
  fi
  podman system prune --all --volumes
else
  code=$?
  echo 'Pi-hole deployment unsuccessful!'
  exit ${code}
fi
