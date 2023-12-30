#!/usr/bin/env bash
#

cd /etc/nixos

if [[ ! -e /etc/nixos/realix-iso ]]; then
    git clone https://github.com/yodalf/realix-iso.git
else
    cd realix-iso
    git pull
    cd ..
fi

rm -f flake.lock
cp -r realix-iso/iso_data/realix/* .

# Override with our own home config if we have one
if [[ -e /home/realo/.config/home-manager/home.nix ]]; then
    cp /home/realo/.config/home-manager/home.nix /etc/nixos/realo-home.nix
fi

nixos-rebuild switch --impure --flake /etc/nixos#gizmo

