REMOTE_ON_BOOT_D := '/data/on_boot.d'
RSYNC_FLAGS := '-Ravuzh --no-o'
SCP_FLAGS := '-O -o LogLevel=Error'
SSH_FLAGS := '-o RemoteCommand=none -o LogLevel=error'
SSH_HOST := 'root@192.168.16.1'

default $FZF_DEFAULT_OPTS='--preview-window hidden':
    @just --choose

update:
    curl -L https://raw.githubusercontent.com/unifi-utilities/unifios-utilities/main/cni-plugins/05-install-cni-plugins.sh -o ./on_boot.d/05-install-cni-plugins.sh
    curl -L https://raw.githubusercontent.com/unifi-utilities/unifios-utilities/main/dns-common/on_boot.d/10-dns.sh -o ./on_boot.d/10-dns.sh
    curl -L https://raw.githubusercontent.com/pedropombeiro/udm-utilities/master/run-pihole/custom_pihole_dote.sh -o ./scripts/upd_pihole_dote.sh
    chmod +x ./on_boot.d/*.sh ./scripts/*.sh

_ssh cmd:
    ssh {{ SSH_FLAGS }} {{ SSH_HOST }} '{{ cmd }}'

_rsync +args:
    rsync {{ RSYNC_FLAGS }} {{ args }}

dns_config_cmd := '''
  touch /data/etc-pihole/macvendor.db
  chown -R root:1000 /data/etc-pihole/
  chmod -R g+w /data/etc-pihole/
  chmod a+r /data/etc-pihole/* /data/pihole/* /data/pihole/etc-dnsmasq.d/*
  podman container exists pihole && podman restart pihole
  chown -R 1000 /data/etc-ddns-updater/
  chmod 700 /data/etc-ddns-updater
  chmod 400 /data/etc-ddns-updater/config.json
'''

@push-dns-config:
    just _rsync --delete ./pihole/ {{ SSH_HOST }}:/data/
    just _rsync ./etc-pihole/ {{ SSH_HOST }}:/data/
    just _ssh '{{ dns_config_cmd }}'

prepare_data_dir_cmd := '''
    mkdir -p {{ REMOTE_ON_BOOT_D }} /data/scripts /data/podman
    rm -rf {{ REMOTE_ON_BOOT_D }}/*.sh /data/scripts/*.sh
'''

push-config:
    @just _ssh '{{ prepare_data_dir_cmd }}'
    chmod +x ./on_boot.d/*.sh
    @just _rsync --delete ./on_boot.d/ {{ SSH_HOST }}:/data/
    @just _rsync ./cronjobs/ ./etc-ddns-updater/ ./podman/cni/ ./scripts/ ./settings/ ./system/ {{ SSH_HOST }}:/data/
    just push-dns-config
    @just _ssh '{{ REMOTE_ON_BOOT_D }}/25-add-cron-jobs.sh'

push: push-config (_ssh '/data/scripts/upd_pihole_dote.sh')

install-tools: (_ssh '/data/scripts/download-tools.sh')

edit:
    vim scp://unifi//data/
