REMOTE_ON_BOOT_D = /data/on_boot.d

RSYNC_FLAGS ?= -Ravuzh --no-o
SCP_FLAGS ?= -O -o LogLevel=Error
SSH_FLAGS ?= -o RemoteCommand=none -o LogLevel=error
SSH_HOST ?= root@192.168.16.1

.PHONY: update
update:
	curl -L https://raw.githubusercontent.com/unifi-utilities/unifios-utilities/main/cni-plugins/05-install-cni-plugins.sh -o ./on_boot.d/05-install-cni-plugins.sh
	curl -L https://raw.githubusercontent.com/unifi-utilities/unifios-utilities/main/dns-common/on_boot.d/10-dns.sh -o ./on_boot.d/10-dns.sh
	curl -L https://raw.githubusercontent.com/pedropombeiro/udm-utilities/master/run-pihole/custom_pihole_dote.sh -o ./scripts/upd_pihole_dote.sh
	chmod +x ./on_boot.d/*.sh ./scripts/*.sh

.PHONY: push-dns-config
push-dns-config:
	rsync $(RSYNC_FLAGS) --delete ./pihole/ $(SSH_HOST):/data/
	rsync $(RSYNC_FLAGS) ./etc-pihole/ $(SSH_HOST):/data/
	ssh $(SSH_FLAGS) $(SSH_HOST) 'touch /data/etc-pihole/macvendor.db; chown -R root:1000 /data/etc-pihole/; chmod -R g+w /data/etc-pihole/; chmod a+r /data/etc-pihole/* /data/pihole/* /data/pihole/etc-dnsmasq.d/*; podman container exists pihole && podman restart pihole'
	ssh $(SSH_FLAGS) $(SSH_HOST) 'chown -R 1000 /data/etc-ddns-updater/; chmod 700 /data/etc-ddns-updater; chmod 400 /data/etc-ddns-updater/config.json'

.PHONY: push-config
push-config:
	ssh $(SSH_FLAGS) $(SSH_HOST) 'mkdir -p $(REMOTE_ON_BOOT_D) /data/scripts /data/podman; rm -rf $(REMOTE_ON_BOOT_D)/*.sh /data/scripts/*.sh'
	chmod +x ./on_boot.d/*.sh
	rsync $(RSYNC_FLAGS) --delete ./on_boot.d/ $(SSH_HOST):/data/
	rsync $(RSYNC_FLAGS) ./cronjobs/ ./etc-ddns-updater/ ./podman/cni/ ./scripts/ ./settings/ ./system/ $(SSH_HOST):/data/
	$(MAKE) push-dns-config
	ssh $(SSH_FLAGS) $(SSH_HOST) '$(REMOTE_ON_BOOT_D)/25-add-cron-jobs.sh'

.PHONY: push
push:
	$(MAKE) push-config
	ssh $(SSH_FLAGS) $(SSH_HOST) '/data/scripts/upd_pihole_dote.sh'

.PHONY: install-tools
install-tools:
	ssh $(SSH_FLAGS) $(SSH_HOST) /data/scripts/download-tools.sh

.PHONY:
edit:
	vim scp://unifi//data/
