#!/bin/sh

### Add iptables rules to redirect port 53 traffic (tcp+udp)
### IPv4 DNS traffic is redirected to $IPV4_IP on port $IPV4_PORT

IPV4_IP=192.168.6.254
IPV4_PORT=53

for intfc in br0 br26 br36 br46 br56 br66; do
  if [ -d "/sys/class/net/${intfc}" ]; then
    for proto in udp tcp; do
      prerouting_rule="PREROUTING -i ${intfc} -p ${proto} ! -s ${IPV4_IP} ! -d ${IPV4_IP} --dport 53 -j DNAT --to ${IPV4_IP}:${IPV4_PORT}"
      iptables -t nat -C ${prerouting_rule} || iptables -t nat -A ${prerouting_rule}
    done
  fi
done
