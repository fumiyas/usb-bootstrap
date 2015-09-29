#!/bin/sh

## WARNING: Work-In-Progress

set -u
set -e

dev="/dev/sdx"
mnt="/mnt/tmp"

syslinux_src_bios_dir="/usr/lib/syslinux/modules/bios"
syslinux_dir="/syslinux"

fd_src_dir="/path/to/FreeDOS"
deb_dist="http://cdn.debian.net/debian/dists"
deb_name="jessie"
deb_arch="amd64"

## Create a a single bootable FAT32 LBA partition
echo '0,,C,*' |sfdisk "$dev"
mkfs -t vfat "${dev}1"
install-mbr "$dev"

## syslinux (stage 1)
## ======================================================================

mount "${dev}1" "$mnt"
cp -a "$syslinux_src_bios_dir/chain.c32" "$mnt$syslinux_dir/"
cp -a "$syslinux_src_bios_dir/libcom32.c32" "$mnt$syslinux_dir/"
cp -a "$syslinux_src_bios_dir/libutil.c32" "$mnt$syslinux_dir/"

## FreeDOS
## ======================================================================

mkdir "$mnt/fdos"
cp -rp "$fd_src_dir"/* "$mnt/fdos/"
mv "$mnt/fdos/setup/odin/fdconfig.sys" "$mnt/"
mv "$mnt/fdos/setup/odin/command.com" "$mnt/"
#mv "$mnt/fdos/autoexec.bat" "$mnt/"

## Debian Installer
## ======================================================================

mkdir "$mnt/boot/d-i"
wget --output-file="$mnt/boot/d-i/initrd.gz" "$deb_dist/$deb_name/main/installer-$deb_arch/current/images/hd-media/initrd.gz"
wget --output-file="$mnt/boot/d-i/vmlinuz" "$deb_dist/$deb_name/main/installer-$deb_arch/current/images/hd-media/vmlinuz"

## syslinux (stage 2)
## ======================================================================

unmount "$mnt"

syslinux -d "$syslinux_dir" "${dev}1"

