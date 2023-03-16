#!/bin/bash

if ! command -v podman >/dev/null 2>&1; then
  # initialize gpg if needed, this will create the ~/.gnupg directory with the correct permissions if it does not exist
  gpg --list-keys

  # download unifi-blueberry repo key
  gpg --no-default-keyring \
    --keyring /usr/share/keyrings/unifi-blueberry.gpg \
    --keyserver keyserver.ubuntu.com \
    --recv-keys C320FD3D3BF10DA7415B29F700CCEE392D0CA761

  # configure apt repo source
  cat <<EOT > /etc/apt/sources.list.d/unifi-blueberry.sources
Types: deb
Architectures: arm64
Signed-By: /usr/share/keyrings/unifi-blueberry.gpg
URIs: https://apt.unifiblueberry.io
Suites: stable
Components: main
EOT

  apt update
  apt install -y unifi-blueberry-addon-podman
fi

if [[ -d /volume1 ]]; then
  # If podman storage is pointing to the default internal location and the external location is available, move it there
  if grep '= "/var' /etc/containers/storage.conf >/dev/null; then
    podman container stop --all
    podman system prune --all --volumes --force
    sed --in-place --regexp-extended 's/root = "\/(run|var)/root = "\/volume1\/\1/' /etc/containers/storage.conf
  fi
fi
