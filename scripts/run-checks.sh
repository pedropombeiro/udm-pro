#!/bin/bash

set -e

SCRIPTS=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

source "${SCRIPTS}/colors.sh"

function print_op() {
  printf "${CYAN}%s${NC}\n" "- $1"
}

function print_op_stay() {
  printf "${CYAN}%-60s${NC} " "- $1..."
}

function print_ok() {
  printf "${GREEN}%s${NC} %s\n" '✅ OK' "$1"
}

function print_failure() {
  printf "${RED}%s${NC}\n" "$1"
}

any_failed=0
is_running_in_ui=$(uname -a | grep ui-alpine >/dev/null && echo 1 || echo 0)

print_op_stay "Checking if Prometheus Node Exporter is running"
if curl --fail --silent http://unifi:9100/metrics >/dev/null; then
  print_ok "http://unifi:9100/metrics"
else
  if [[ $is_running_in_ui -eq 1 ]]; then
    apt-get install -y prometheus-node-exporter
  fi
  if curl --fail --silent http://unifi:9100/metrics >/dev/null; then
    print_failure "Prometheus Node Exporter is not running (fixed - make sure to fix arguments in /etc/systemd/system/multi-user.target.wants/prometheus-node-exporter.service)"
  else
    print_failure "Prometheus Node Exporter is not running"
  fi
  any_failed=1
fi

print_op_stay "Checking DNS resolver"
if dig microsoft.com @192.168.6.254 | grep "status: NOERROR" >/dev/null; then
  print_ok "DNS resolver working as expected"
else
  echo
  print_failure "DNS resolver not working as expected!"
  any_failed=1
fi

print_op_stay "Checking root.hints"
if [[ -f /data/unbound/lib/root.hints ]]; then
  print_ok "/data/unbound/lib/root.hints is present"
else
  echo
  print_failure "/data/unbound/lib/root.hints is not missing, fixing"
  wget https://www.internic.net/domain/named.root -q -O "/data/unbound/lib/root.hints" >/dev/null 2>&1 && \
    chown "/data/unbound/lib/root.hints" --reference=/data/unbound/lib
  if [[ ! -f /data/unbound/lib/root.hints ]]; then
    any_failed=1
  fi
fi

for svc in on_boot ddns-updater promtail; do
  print_op_stay "Checking ${svc} service"
  if systemctl status "${svc}.service" >/dev/null; then
    print_ok "${svc}.service is running"
  else
    echo
    print_failure "${svc} is not running, fixing"
    systemctl enable "${svc}.service" && systemctl start "${svc}.service"
    sleep 5
    if ! systemctl status "${svc}.service" >/dev/null; then
      any_failed=1
    fi
  fi
done

print_op_stay "Checking promtail"
if pgrep promtail >/dev/null; then
  print_ok "promtail is running"
else
  echo
  print_failure "promtail is not running"
  any_failed=1
fi

print_op_stay "Checking if neovim is in PATH"
if which nvim >/dev/null; then
  print_ok "neovim present in PATH"
else
  if [[ $is_running_in_ui -eq 1 ]]; then
    apt-get install -y neovim
  fi
  if which nvim >/dev/null; then
    print_failure "Neovim is not installed (fixed)"
  else
    print_failure "Neovim is not installed"
  fi
  any_failed=1
fi

if [[ $any_failed -eq 1 ]]; then
  printf "${YELLOW}%s${NC}\n" "⚠️  Checks finished with errors/warnings!"
  (exit 1)
else
  printf "${GREEN}%s${NC}\n" "✅ Checks finished!"
fi
