#!/bin/bash

if [[ -d /volume1 ]]; then
  # If podman storage is pointing to the default internal location and the external location is available, move it there
  if grep '= "/var' /etc/containers/storage.conf >/dev/null; then
    podman container stop --all
    podman system prune --all --volumes --force
    sed --in-place --regexp-extended 's/root = "\/(run|var)/root = "\/volume1\/\1/' /etc/containers/storage.conf
  fi
fi
