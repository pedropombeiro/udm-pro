REMOTE_ON_BOOT_D = /data/on_boot.d

SCP_FLAGS ?= -O -o LogLevel=Error
SSH_FLAGS ?= -o RemoteCommand=none -o LogLevel=error
SSH_HOST ?= root@192.168.16.1

.PHONY: update
update:
	curl -L https://raw.githubusercontent.com/unifi-utilities/unifios-utilities/main/container-common/on_boot.d/05-container-common.sh -o ./on_boot.d/05-container-common.sh
	curl -L https://raw.githubusercontent.com/unifi-utilities/unifios-utilities/main/cni-plugins/05-install-cni-plugins.sh -o ./on_boot.d/05-install-cni-plugins.sh
	curl -L https://raw.githubusercontent.com/unifi-utilities/unifios-utilities/main/dns-common/on_boot.d/10-dns.sh -o ./on_boot.d/10-dns.sh
	chmod +x ./on_boot.d/*.sh

.PHONY: push-dns-config
push-dns-config:
	scp $(SCP_FLAGS) -r ./pihole/* $(SSH_HOST):/data/pihole/
	scp $(SCP_FLAGS) ./etc-pihole/* $(SSH_HOST):/data/etc-pihole/
	ssh $(SSH_FLAGS) $(SSH_HOST) 'touch /data/etc-pihole/macvendor.db; chown -R root:root /data/etc-pihole/; chmod a+r /data/etc-pihole/* /data/pihole/* /data/pihole/etc-dnsmasq.d/*; podman exec pihole pihole restartdns'

.PHONY: push
push:
	ssh $(SSH_FLAGS) $(SSH_HOST) 'mkdir -p $(REMOTE_ON_BOOT_D) /data/scripts /data/system /data/podman/cni /data/etc-ddns-updater /data/pihole /data/etc-pihole /data/pihole/etc-dnsmasq.d /data/cronjobs /data/settings/profile/global.profile.d; rm -rf $(REMOTE_ON_BOOT_D)/*.sh /data/scripts/*.sh /data/pihole/* /data/cronjobs/* /data/settings/profile/global.profile.d/*'
	chmod +x ./on_boot.d/*.sh
	scp $(SCP_FLAGS) ./on_boot.d/*.sh $(SSH_HOST):$(REMOTE_ON_BOOT_D)/
	scp $(SCP_FLAGS) ./scripts/*.sh $(SSH_HOST):/data/scripts/
	scp $(SCP_FLAGS) ./system/* $(SSH_HOST):/data/system/
	scp $(SCP_FLAGS) ./etc-ddns-updater/* $(SSH_HOST):/data/etc-ddns-updater/
	scp $(SCP_FLAGS) ./podman/cni/* $(SSH_HOST):/data/podman/cni/
	scp $(SCP_FLAGS) ./cronjobs/* $(SSH_HOST):/data/cronjobs/
	scp $(SCP_FLAGS) ./settings/profile/global.profile.d/* $(SSH_HOST):/data/settings/profile/global.profile.d/
	$(MAKE) push-dns-config
	ssh $(SSH_FLAGS) $(SSH_HOST) 'chown -R 1000 /data/etc-ddns-updater/; chmod 700 /data/etc-ddns-updater; chmod 400 /data/etc-ddns-updater/config.json'
	ssh $(SSH_FLAGS) $(SSH_HOST) '/data/scripts/upd_pihole_dote.sh'

.PHONY:
edit:
	vim scp://unifi//data/
