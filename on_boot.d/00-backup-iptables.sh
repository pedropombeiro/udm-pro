#!/bin/sh

iptables-save > /data/iptables.bak
iptables-restore --test --verbose < /data/iptables.bak
