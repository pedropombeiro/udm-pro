REMOTE_ON_BOOT_D = /mnt/data/on_boot.d

SCP_FLAGS ?= -o LogLevel=Error
SSH_FLAGS ?= -o RemoteCommand=none -o LogLevel=error
SSH_HOST ?= unifi

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
	scp $(SCP_FLAGS) -r ./pihole/* $(SSH_HOST):/mnt/data/pihole/
	scp $(SCP_FLAGS) ./etc-pihole/* $(SSH_HOST):/mnt/data/etc-pihole/
	ssh $(SSH_FLAGS) $(SSH_HOST) 'chmod a+r /mnt/data/etc-pihole/* /mnt/data/pihole/* /mnt/data/pihole/etc-dnsmasq.d/*; docker exec pihole pihole restartdns'

.PHONY: push
push:
	ssh $(SSH_FLAGS) $(SSH_HOST) 'mkdir -p $(REMOTE_ON_BOOT_D) /mnt/data/scripts /mnt/data/podman/cni /mnt/data/etc-ddns-updater /mnt/data/pihole /mnt/data/etc-pihole /mnt/data/pihole/etc-dnsmasq.d /mnt/data/cronjobs; rm -rf $(REMOTE_ON_BOOT_D)/*.sh $(REMOTE_ON_BOOT_D)/files/* /mnt/data/scripts/*.sh /mnt/data/pihole/* /mnt/data/scripts/ipt-enable-logs /mnt/data/cronjobs/*'
	chmod +x ./on_boot.d/*.sh
	scp $(SCP_FLAGS) ./on_boot.d/*.sh $(SSH_HOST):$(REMOTE_ON_BOOT_D)/
	scp $(SCP_FLAGS) -r ./on_boot.d/files $(SSH_HOST):$(REMOTE_ON_BOOT_D)/
	scp $(SCP_FLAGS) ./scripts/*.sh $(SSH_HOST):/mnt/data/scripts/
	scp $(SCP_FLAGS) -r ./scripts/ipt-enable-logs $(SSH_HOST):/mnt/data/scripts/
	scp $(SCP_FLAGS) ./etc-ddns-updater/* $(SSH_HOST):/mnt/data/etc-ddns-updater/
	scp $(SCP_FLAGS) ./podman/cni/* $(SSH_HOST):/mnt/data/podman/cni/
	scp $(SCP_FLAGS) ./cronjobs/* $(SSH_HOST):/mnt/data/cronjobs/
	$(MAKE) push-dns-config
	ssh $(SSH_FLAGS) $(SSH_HOST) '/mnt/data/scripts/upd_pihole_dote.sh'

.PHONY:
edit:
	vim scp://unifi//mnt/data/

.PHONY:
refresh-ipt:
	ssh $(SSH_FLAGS) $(SSH_HOST) /mnt/data/scripts/refresh-iptables.sh

.PHONY: push-ipt
push-ipt:
	ssh $(SSH_FLAGS) $(SSH_HOST) 'mkdir -p /mnt/data/scripts; rm -rf /mnt/data/scripts/ipt-enable-logs'
	scp $(SCP_FLAGS) -r ./scripts/ipt-enable-logs $(SSH_HOST):/mnt/data/scripts/
