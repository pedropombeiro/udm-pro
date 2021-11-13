#!/bin/sh

set -e

if ! iptables-save | grep '\--log-prefix "\[' > /dev/null; then
  /mnt/data/on_boot.d/10-dns.sh
  /mnt/data/on_boot.d/30-ipt-enable-logs-launch.sh
else
  echo "iptables already contains log prefixes, ignoring."
fi
