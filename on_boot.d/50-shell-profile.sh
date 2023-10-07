#!/bin/bash

## Configure shell profile
PROFILE_SOURCE=/data/settings/profile/global.profile.d
PROFILE_TARGET=/etc/profile.d

device_info() {
  /usr/bin/ubnt-device-info "$1"
}

# Modify login banner (motd)
cat >/etc/motd <<EOF
Welcome to UniFi Dream Machine!
(c) 2010-$(date +%Y) Ubiquiti Inc. | http://www.ui.com

Model:       $(device_info model)
Version:     $(device_info firmware)
MAC Address: $(device_info mac)
EOF

# Copy all global profile scripts (for all users) from `/data/settings/profile/global.profile.d/` directory
mkdir -p ${PROFILE_SOURCE}
cp -rf ${PROFILE_SOURCE}/* ${PROFILE_TARGET}
