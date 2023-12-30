#!/usr/bin/env bash
#

rm -f toto-a toto-b
qemu-img create -f qcow2 toto-a 20G 
qemu-img create -f qcow2 toto-b 15G
qemu-system-x86_64 -hda toto-a -hdb toto-b -smp 8 -cpu host -vga virtio -enable-kvm -m 2048 -cdrom result/iso/nixos.iso &

