#!/bin/sh

iptables-save > /mnt/data/iptables.bak
iptables-restore --test --verbose < /mnt/data/iptables.bak
