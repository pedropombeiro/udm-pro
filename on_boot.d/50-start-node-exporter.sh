#!/bin/sh

podman run -d --rm --name "node-exporter" --net="host" --pid="host" -v "/:/host:ro,rslave" quay.io/prometheus/node-exporter:latest --path.rootfs=/host
