#!/bin/sh

set -e

DOCKER_TAG=2022.05
tmpdir="$(mktemp -d)"
curl -sSLo "${tmpdir}/dote" https://github.com/chrisstaite/DoTe/releases/latest/download/dote_arm64

cat > "${tmpdir}/Dockerfile" <<EOF
FROM pihole/pihole:${DOCKER_TAG}
ENV DOTE_OPTS="-s 127.0.0.1:5053"
COPY dote /opt/dote
RUN chmod +x /opt/dote && echo -e  "#!/bin/sh\n/opt/dote \\\$DOTE_OPTS -d\n" > /etc/cont-init.d/10-dote.sh
EOF

podman pull pihole/pihole:${DOCKER_TAG}
podman build -t pihole:latest --format docker -f "${tmpdir}/Dockerfile" "${tmpdir}"
rm -rf "${tmpdir}"

chmod +r /mnt/data/etc-pihole/* /mnt/data/pihole/* /mnt/data/pihole/etc-dnsmasq.d/*

set +e

podman stop pihole
podman rm pihole
podman run -d --network dns --restart always \
    --name pihole \
    -e TZ="$(cat /mnt/data/system/timezone)" \
    -v "/mnt/data/etc-pihole:/etc/pihole" \
    -v "/mnt/data/pihole/etc-dnsmasq.d:/etc/dnsmasq.d" \
    -v "/mnt/data/pihole/hosts:/etc/hosts:ro" \
    --dns=127.0.0.1 \
    --hostname pihole \
    --cap-add=NET_ADMIN \
    --cap-add=SYS_NICE \
    -e DOTE_OPTS="-s 127.0.0.1:5053 --forwarder 1.1.1.1:853 --connections 10 --hostname cloudflare-dns.com --pin XdhSFdS2Zao99m31qAd/19S0SDzT2D52btXyYWqnJn4=" \
    -e VIRTUAL_HOST="pihole" \
    -e PROXY_LOCATION="pihole" \
    -e ServerIP="192.168.6.254" \
    -e PIHOLE_DNS_="127.0.0.1#5053" \
    -e IPv6="False" \
    -e SKIPGRAVITYONBOOT=1 \
    -e DBIMPORT=yes \
    pihole:latest

sleep 5 # Allow Pi-hole to start up

if ! curl --connect-timeout 0.5 -fsL 192.168.6.254/admin -o /dev/null; then
    code=$?
    echo 'Pi-hole deployment unsuccessful!'
    exit ${code}
fi
