# UDM Pro tools

## Abstract

The [UDM Pro](https://github.com/pedropombeiro/udm-pro) repo contains configuration for the UDM Pro which makes it
easier to manage and more performant.
It is based on [udm-utilities](https://github.com/boostchicken/udm-utilities).

The customizations built on top of the utilities provide the following services:

- DDNS updater: periodic service and web dashboard to update the DDNS record in DuckDNS;
- Node exporter: Prometheus node exporter allowing the Prometheus server on the NAS to retrieve metrics;
- Unbound: Fully recursive DNS caching + verifying resolver to serve as the upstream resolver for Pi-hole. Includes
  periodic prefetching of most used DNS records;
- Unbound exporter: exporter on TCP port 9167 allowing the Prometheus server on the NAS to retrieve metrics about
  Unbound on TCP port 8953;
- Pi-hole: Ad-blocking recursive caching DNS provider which delegates the DNS queries to Unbound on UDP port 5335.

### Prometheus Node Exporter

Install with `apt-get`:

```shell
apt install -y prometheus-node-exporter
```

Edit the `/etc/systemd/system/multi-user.target.wants/prometheus-node-exporter.service` file to disable a couple of
unsupported exports:

```text
ExecStart=/usr/bin/prometheus-node-exporter $ARGS --no-collector.pressure --no-collector.rapl
```

Reload the unit:

```shell
systemctl daemon-reload && systemctl restart prometheus-node-exporter.service
```

### Create VM for Pi-hole/Unbound

SSH into the UDM Pro, and follow the instructions in
<https://github.com/unifi-utilities/unifios-utilities/tree/main/nspawn-container> (including the MACVLAN steps).

```shell
apt install -y prometheus-node-exporter # Install the Prometheus Node Exporter
mkdir -p /volume1/etc/pihole/ /volume1/var/log/pihole/
```

Inside the debian-dns container:

```shell
echo 'pihole' > /etc/hostname
# Allow SQLite to create a journal file for changes inside the same directory as the gravity.db file
chmod g+w /external/etc/pihole
chown -R pihole:pihole /external/etc/pihole

apt -y install curl
curl -sSL https://install.pi-hole.net | PIHOLE_SKIP_OS_CHECK=true bash
```

### Unbound

Inside the debian-dns container (`machinectl shell debian-dns`):

```shell
# https://docs.pi-hole.net/guides/dns/unbound/#setting-up-pi-hole-as-a-recursive-dns-server-solution

apt-get install unbound unbound-anchor
chown -R unbound:unbound /var/lib/unbound
curl -s https://www.internic.net/domain/named.root | sudo -h pihole -u unbound tee /var/lib/unbound/root.hints
sudo -h pihole -u unbound unbound-control-setup

# Generate root trust anchor for DNSSEC validation
sudo -h pihole -u unbound unbound-anchor -a "/var/lib/unbound/root.key"

sudo -h pihole service unbound restart

systemctl enable unbound-exporter
systemctl start unbound-exporter
```

At the end, run `apt clean` to remove caches from installed packages.

## Knowledge base

If you see the following error:

```text
Failed to get shell PTY: Unit container-shell@1.service was already loaded or has a fragment file.
```

It means that a shell session was not properly terminated. Run the following command on the host to restart the unit:

```shell
systemctl -M debian-dns try-restart container-shell@1.service
```
