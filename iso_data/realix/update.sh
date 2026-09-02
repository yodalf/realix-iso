#!/usr/bin/env bash
#
# Usage: update.sh [switch|boot]   (default: switch)
#
# The whole script lives inside main() so that bash parses it completely
# before running anything. The `cp` below overwrites this very file, and bash
# reads scripts lazily, so without the wrapper a changed update.sh derails
# itself mid-run. The explicit `exit` keeps bash from reading past main.

main() {
    set -euo pipefail
    local action="${1:-switch}"

    cd /etc/nixos

    if [[ ! -e /etc/nixos/realix-iso ]]; then
        git clone https://github.com/yodalf/realix-iso.git
    else
        git -C realix-iso pull
    fi

    rm -f flake.lock
    cp -r realix-iso/iso_data/realix/* .

    # Override with our own home config if we have one
    if [[ -e /home/realo/.config/home-manager/home.nix ]]; then
        cp /home/realo/.config/home-manager/home.nix /etc/nixos/realo-home.nix
    fi

    # `switch` is refused by the pre-switch checks when critical components
    # change (e.g. dbus -> dbus-broker); use `update.sh boot` and reboot then.
    nixos-rebuild "$action" --impure --flake /etc/nixos#gizmo

    if [[ $action == boot ]]; then
        echo "New configuration installed; it becomes active after a reboot."
    fi
    exit 0
}

main "$@"
