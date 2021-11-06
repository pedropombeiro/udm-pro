REMOTE_ON_BOOT_D = /mnt/data/on_boot.d

.PHONY: update
update:
	curl -L https://raw.githubusercontent.com/boostchicken/udm-utilities/master/podman-update/01-podman-update.sh -o ./on_boot.d/01-podman-update.sh
	curl -L https://raw.githubusercontent.com/boostchicken/udm-utilities/master/container-common/on_boot.d/05-container-common.sh -o ./on_boot.d/05-container-common.sh
	curl -L https://raw.githubusercontent.com/boostchicken/udm-utilities/master/cni-plugins/05-install-cni-plugins.sh -o ./on_boot.d/05-install-cni-plugins.sh
	curl -L https://raw.githubusercontent.com/boostchicken/udm-utilities/master/dns-common/on_boot.d/10-dns.sh -o ./on_boot.d/10-dns.sh
	curl -L https://raw.githubusercontent.com/renedis/ubnt-auto-fan-speed/main/on_boot.d/11-ubnt-auto-fan-speed.sh -o ./on_boot.d/11-ubnt-auto-fan-speed.sh
	chmod +x ./on_boot.d/*.sh

.PHONY: push-dns-config
push-dns-config:
	scp -r ./pihole/* unifi:/mnt/data/pihole/
	ssh unifi 'docker exec -ti pihole pihole restartdns'

.PHONY: push
push:
	ssh -o RemoteCommand=none unifi 'mkdir -p $(REMOTE_ON_BOOT_D) /mnt/data/scripts /mnt/data/podman/cni /mnt/data/etc-ddns-updater /mnt/data/pihole /mnt/data/etc-pihole /mnt/data/pihole/etc-dnsmasq.d; rm -rf $(REMOTE_ON_BOOT_D)/*.sh /mnt/data/scripts/*.sh /mnt/data/pihole/*'
	chmod +x ./on_boot.d/*.sh
	scp ./on_boot.d/*.sh unifi:$(REMOTE_ON_BOOT_D)/
	scp -r ./on_boot.d/files unifi:$(REMOTE_ON_BOOT_D)/
	scp ./scripts/*.sh unifi:/mnt/data/scripts/
	scp ./etc-ddns-updater/* unifi:/mnt/data/etc-ddns-updater/
	scp ./podman/cni/* unifi:/mnt/data/podman/cni/
	scp -r ./pihole/* unifi:/mnt/data/pihole/
	scp ./etc-pihole/* unifi:/mnt/data/etc-pihole/
	ssh -o RemoteCommand=none unifi 'chmod +r /mnt/data/etc-pihole/*'
