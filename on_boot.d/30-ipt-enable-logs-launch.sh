#!/bin/sh

set -e

if ! iptables-save | grep '\--log-prefix "\[' > /dev/null; then
  /mnt/data/scripts/ipt-enable-logs.sh | iptables-restore -c
fi
