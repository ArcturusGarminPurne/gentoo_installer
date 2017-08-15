#! /bin/bash
#  ins.sh
#  
#  Copyright 2017 Arcturus Garmin Purne <arcturus@arcturus-Macbook>
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  
#  


##.....default value.....##
	boot=
	swap=
	root=
	rf=
	stmd=
	cpu=native
	vdcd=nvidia
	nm=tux
	nnm=homenetwork
	wi=eth0
	dhcp=y
##.............................##



function strtgntstllr() {
	cat $(dirname ${BASH_SOURCE[0]})/TLG/g_ilg
	cd /
	return
}
function chrtst() {
	echo "
	export boot=$boot
	export root=$root
	export swap=$swap
	export rf=$rf
	export stmd=$stmd
	export cpu=$cpu
	export vdcd=$vdcd
	export nm=$nm
	export nnm=$nnm
	export wi=$wi
	export dhcp=$dhcp
	" >> /mnt/gentoo/etc/profile
}

function gtmkeknl() {
	cd $(dirname ${BASH_SOURCE[0]})/
	chmod +x conf.sh
	cd /mnt/gentoo
	return
}
function gtstpknl() {
	cd /mnt/gentoo
	wget -c -r -np -k -L -p http://mirrors.163.com/gentoo/releases/amd64/autobuilds/current-stage3-amd64"$stmd"/
	cp http://mirrors.163.com/gentoo/releases/amd64/autobuilds/current-stage3-amd64"$stmd"/stage3-amd64"$stmd"-*.tar.bz2 ins.tar.bz2
	tar xvjpf ins.tar.bz2 --xattrs --numeric-owner
	rm -r mirrors.163.com/ ins.tar.bz2	##clean
	sed -i 's/CFLAGS=\"-O2 -pipe\"/CFLAGS=\"-march="$cpu" -O2 -pipe\"/g' /mnt/gentoo/etc/portage/make.conf
	mirrorselect -i -o >> etc/portage/make.conf
	echo "MAKEOPTS=-j3
VIDEO_CARDS=\""$vdcd"\"" >> etc/portage/make.conf
	read -p "Edit make.conf? [y/n] : " yn
	if [ yn == y ];then
		nano -w etc/portage/make.conf
	fi
	mkdir etc/portage/repos.conf
	cp usr/share/portage/config/repos.conf etc/portage/repos.conf/gentoo.conf
	cp -L /etc/resolv.conf etc/
	mount -t proc /proc proc
	mount -R /sys sys
	mount --make-rslave sys
	mount -R /dev dev
	mount --make-rslave dev
	return
}
initgnt() {
	read -p "Type the disk which is going to mount on /boot : " boot
	read -p "Type the disk which is going to be swap : " swap
	read -p "Type the disk which is going to mount on / : " root
	read -p "format it? [y/n] : " yn
	if [ yn == y ];then
		read -p  "choose the filesystem you like:
1) reiserfs
2) ext4
3) ext3
4) ext2
5) jfs
6) xfs
7) btrfs
8) f2fs
>" rf
	else
		read -p "What's your filesystem on / ?
1) reiserfs
2) ext4
3) ext3
4) ext2
5) jfs
6) xfs
7) btrfs
8) f2fs
9) vfat (fat)
10) ntfs
11) other
>" fr
		if [fr == 9 || fr == 10 || fr == 11 ];then
			read -p "You must format it.choose the filesystem you like:
1) reiserfs
2) ext4
3) ext3
4) ext2
5) jfs
6) xfs
7) btrfs
8) f2fs
>" rf
		fi
	fi
	case $rf in
		1) rf=reiserfs_;;
		2) rf=ext4_;;
		3) rf=ext3_;;
		4) rf=ext2_;;
		5) rf=jfs_;;
		6) rf=xfs_;;
		7) rf=btrfs_;;
		8) rf=f2fs_;;
		*) echo "The disk do not format! (Enter)";;
	esac
	read -p "What do you desire as your init system? [type -systemd to use systemd or enter for default(OpenRC)] " stmd
	read -p "Your CPU core codenamed? [some CPU core codenamed like ivybridge,haswell,etc.] " cpu
	read -p "Your video card : [like intel,nvidia or nv,etc.] " vdcd
	read -p "How do you wanna compile the kernel?
1)		Use \"genkernel all\"
2)		Use \"genkernel menuconfig all\"
3)		I'll setup the config file myself
4)		Use the kernel config file of Archlinux
5)		Use the kernel config file of Ubuntu
6)		Use other kernel config files from Internet
>" knl
	read -p "Set the hostname : " nm
	read -p "Set the domin name : " nnm
	ip link
	read -p "Choose the default interface : " wi
	read -p "Do you use dhcp? [y/n] : " dhcp
	mkswap $swap
	swapon $swap
	mkfs.${rf/_/} $root
	mkfs.fat -F32 $boot
	return 
}
function gntmnt() {
	rm -r /mnt/gentoo
	mkdir /mnt/gentoo
	mkdir /mnt/gentoo/boot
	umount $root
	umount $boot
	mount $root /mnt/gentoo
	mount $boot /mnt/gentoo/boot
	return
}
##---------------start here {*^~^*}---------------##
strtgntstllr
initgnt
gntmnt
gtstpknlknl
gtmkeknl
chrtst
chroot /mnt/gentoo $(dirname ${BASH_SOURCE[0]})/chrt.sh		##CHROOTING!!              ! >_< !
