REMOTE_ON_BOOT_D := '/data/on_boot.d'
RSYNC_FLAGS := '-Ravuzh --no-o'
SCP_FLAGS := '-O -o LogLevel=Error'
SSH_FLAGS := '-o RemoteCommand=none -o LogLevel=error'
SSH_HOST := 'root@192.168.16.1'

default $FZF_DEFAULT_OPTS='--preview-window hidden':
    @just --choose

_ssh cmd:
    ssh {{ SSH_FLAGS }} {{ SSH_HOST }} '{{ cmd }}'

_rsync +args:
    rsync {{ RSYNC_FLAGS }} {{ args }}

dns_config_cmd := '''
  touch /data/etc-pihole/macvendor.db
  chown -R root:1000 /data/etc-pihole/
  chmod -R g+w /data/etc-pihole/
  chmod a+r /data/etc-pihole/* /data/pihole/* /data/pihole/etc-dnsmasq.d/*
  chmod -R a+r /data/unbound/etc
  chown -R 1000 /data/etc-ddns-updater/
  chmod 700 /data/etc-ddns-updater
  chmod 400 /data/etc-ddns-updater/config.json
'''

@push-dns-config:
    just _rsync --delete --force --exclude='*.pem' --exclude='*.cert' --exclude='*.key' ./unbound/etc {{ SSH_HOST }}:/data/
    just _rsync --delete ./pihole/ {{ SSH_HOST }}:/data/
    just _rsync ./etc-pihole/ {{ SSH_HOST }}:/data/
    just _ssh '{{ dns_config_cmd }}'
    # just unbound-reload

prepare_data_dir_cmd := '''
    mkdir -p {{ REMOTE_ON_BOOT_D }} /data/scripts
    rm -rf {{ REMOTE_ON_BOOT_D }}/*.sh /data/scripts/*.sh
'''

unbound cmd:
    @just _ssh 'podman exec unbound unbound-control {{ cmd }}'

unbound-reload: (unbound 'reload_keep_cache')

unbound-stats: (unbound 'stats_noreset')

unbound-test-dnssec:
    @just _ssh 'dig -p 5335 dnssec-failed.org +dnssec | grep SERVFAIL >/dev/null && echo "DNSSEC validation is working" || echo "DNSSEC validation is not working"'

push-config:
    @just _ssh '{{ prepare_data_dir_cmd }}'
    chmod +x ./on_boot.d/*.sh
    @just _rsync --delete ./on_boot.d/ {{ SSH_HOST }}:/data/
    @just _rsync ./cronjobs/ ./custom ./etc-ddns-updater/ ./opt/ ./scripts/ ./settings/ ./system/ {{ SSH_HOST }}:/data/
    @just _rsync --no-relative ./etc-systemd/ {{ SSH_HOST }}:/etc/systemd/
    just push-dns-config
    @just _ssh '{{ REMOTE_ON_BOOT_D }}/25-add-cron-jobs.sh'

push: push-config

install-tools: (_ssh '/data/scripts/download-tools.sh')

edit:
    vim scp://unifi//data/
