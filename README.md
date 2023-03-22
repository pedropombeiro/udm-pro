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
