#!/bin/bash

pihole_ip='192.168.6.254'

m=$(dig @${pihole_ip} www.google.com | grep 'status:')
ping -c 1 ${pihole_ip} >/dev/null
echo "$m" | grep 'status: NOERROR'
