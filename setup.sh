#!/bin/sh

## WARNING: Work-In-Progress

set -u
set -e

dev="/dev/sdb"
mnt="/mnt/tmp"

fd_src_dir="/path/to/FreeDOS"
deb_dist="http://cdn.debian.net/debian/dists"
deb_name="wheezy"
deb_arch="amd64"

## Create a a single bootable FAT32 LBA partition
echo '0,,C,*' |sfdisk "$dev"
mkfs -t vfat "${dev}1"
install-mbr "$dev"

mount "${dev}1" "$mnt"
mkdir "$mnt/boot"
mkdir "$mnt/boot/syslinux"
cp /usr/lib/syslinux/chain.c32 "$mnt/boot/syslinux"

## FreeDOS
## ======================================================================

mkdir "$mnt/FreeDOS"
cp -rp "$fd_src_dir"/* "$mnt/FreeDOS/"
mv "$mnt/FreeDOS/setup/odin/fdconfig.sys" "$mnt/"
mv "$mnt/FreeDOS/setup/odin/command.com" "$mnt/"
#mv "$mnt/FreeDOS/autoexec.bat" "$mnt/"

## Debian Installer
## ======================================================================

mkdir "$mnt/boot/d-i"
wget --output-file="$mnt/boot/d-i/initrd.gz" "$deb_dist/$deb_name/main/installer-$deb_arch/current/images/hd-media/initrd.gz"
wget --output-file="$mnt/boot/d-i/vmlinuz" "$deb_dist/$deb_name/main/installer-$deb_arch/current/images/hd-media/vmlinuz"

## syslinux
## ======================================================================

syslinux -d boot "${dev}1"

