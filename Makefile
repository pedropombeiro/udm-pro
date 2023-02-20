REMOTE_ON_BOOT_D = /data/on_boot.d

RSYNC_FLAGS ?= -Ravuzh --no-o
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
	rsync $(RSYNC_FLAGS) --delete ./pihole/ $(SSH_HOST):/data/
	rsync $(RSYNC_FLAGS) ./etc-pihole/ $(SSH_HOST):/data/
	ssh $(SSH_FLAGS) $(SSH_HOST) 'touch /data/etc-pihole/macvendor.db; chown -R root:root /data/etc-pihole/; chmod a+r /data/etc-pihole/* /data/pihole/* /data/pihole/etc-dnsmasq.d/*; podman container exists pihole && podman exec pihole pihole restartdns'

.PHONY: push
push:
	ssh $(SSH_FLAGS) $(SSH_HOST) 'mkdir -p $(REMOTE_ON_BOOT_D) /data/scripts /data/podman /data/etc-pihole; rm -rf $(REMOTE_ON_BOOT_D)/*.sh /data/scripts/*.sh'
	chmod +x ./on_boot.d/*.sh
	rsync $(RSYNC_FLAGS) --delete ./on_boot.d/ $(SSH_HOST):/data/
	rsync $(RSYNC_FLAGS) ./cronjobs/ ./etc-ddns-updater/ ./podman/cni/ ./scripts/ ./settings/ ./system/ $(SSH_HOST):/data/
	$(MAKE) push-dns-config
	ssh $(SSH_FLAGS) $(SSH_HOST) 'chown -R 1000 /data/etc-ddns-updater/; chmod 700 /data/etc-ddns-updater; chmod 400 /data/etc-ddns-updater/config.json'
	ssh $(SSH_FLAGS) $(SSH_HOST) '/data/scripts/upd_pihole_dote.sh'

.PHONY: install-tools
install-tools:
	ssh $(SSH_FLAGS) $(SSH_HOST) /data/scripts/download-tools.sh

.PHONY:
edit:
	vim scp://unifi//data/
