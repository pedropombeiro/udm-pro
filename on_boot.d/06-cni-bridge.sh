#!/bin/sh

## Create network bridge for CNI
if ! ip link show cni0 > /dev/null 2>&1; then
    ip link add cni0 type bridge
fi
