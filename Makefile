.PHONY: update
update:
	curl -L https://raw.githubusercontent.com/boostchicken/udm-utilities/master/podman-update/01-podman-update.sh -o ./on_boot.d/01-podman-update.sh
	curl -L https://raw.githubusercontent.com/boostchicken/udm-utilities/master/container-common/on_boot.d/05-container-common.sh -o ./on_boot.d/05-container-common.sh
	curl -L https://raw.githubusercontent.com/boostchicken/udm-utilities/master/cni-plugins/05-install-cni-plugins.sh -o ./on_boot.d/05-install-cni-plugins.sh
        curl -L https://raw.githubusercontent.com/renedis/ubnt-auto-fan-speed/main/on_boot.d/11-ubnt-auto-fan-speed.sh -o ./on_boot.d/11-ubnt-auto-fan-speed.sh
	chmod +x *.sh
