#! /bin/bash
#  conf.sh
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
function grubt() {
	echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf
	emerge sys-boot/grub:2
	printf "\n\nIf GRUB2 was somehow emerged without enabling GRUB_PLATFORMS=\"efi-64\", the line (as shown above) can be added to make.conf then and dependencies for the world package set re-calculated by passing the --update --newuse options to emerge:"
	read -p "

read it carefully and press enter key"
	grub-install --target=x86_64-efi --efi-directory=/boot
	printf  "\n\nSome motherboard manufacturers seem to only support the /efi/boot/ directory location for the .EFI file in the EFI System Partition (ESP). The GRUB installer can perform this operation automatically with the --removable option. Verify the ESP is mounted before running the following commands. Presuming the ESP is mounted at /boot (as suggested earlier), execute:
grub-install --target=x86_64-efi --efi-directory=/boot --removable
This creates the default directory defined by the UEFI specification, and then copies the grubx64.efi file to the 'default' EFI file location defined by the same specification.
"
	read -p "

read it carefully and press enter key"
	if [ stmd == ];then
		ln -sf /proc/self/mounts /etc/mtab
		systemd-machine-id-setup
		echo 'GRUB_CMDLINE_LINUX=\"init=/usr/lib/systemd/systemd\"' >> /etc/default/grub
	fi
	grub-mkconfig -o /boot/grub/grub.cfg
	return
}
function config() {
	emerge  sys-kernel/linux-firmware
	sed -i 's/hostname=\"localhost\"/hostname=\"$nm\"/g' /etc/conf.d/hostname
	echo "dns_domain_lo=\"$nnm\"" > /etc/conf.d/net
	emerge --noreplace net-misc/netifrc
	if [ $dhcp == y ];then
		echo "config_$wi=\"dhcp\"" >> /etc/conf.d/net
	else
		echo "config_$wi=\"192.168.0.2 netmask 255.255.255.0 brd 192.168.0.255\" routes_$wi=\"default via 192.168.0.1\"" >> /etc/conf.d/net
	fi
	cd /etc/init.d
	ln -s net.lo net.$wi
	rc-update add net.$wi default
	emerge sys-apps/pcmciautils
	passwd
	if [ stmd == ];then
		nano -w /etc/rc.conf
	fi
	sed -i 's/clock=\"UTC\"/clock=\"local\"/g' /etc/conf.d/hwclock
	read -p "dhcpcd or networkmanager [d/n]" dn
	if [dn == d ];then
		emerge -a net-misc/dhcpcd
	else
		emerge -a networkmanager
		etc-update --automode -3
		if [ stmd == ];then
			systemctl start NetworkManager
			systemctl enable NetworkManager
			systemctl enable NetworkManager-wait-online.service
		else
			rc-update del dhcpcd default
			rc-service NetworkManager start
			rc-update add NetworkManager default
		fi
	fi
	emerge app-admin/sysklogd
	emerge sys-process/cronie
	emerge sys-apps/mlocate
	if [ stmd == ];then
		rc-update add sshd default
		rc-update add sysklogd default
		rc-update add cronie default
	else
		crontab /etc/crontab
	fi
	printf "\n\nIf serial console access is needed (which is possible in case of remote servers), uncomment the serial console section in /etc/inittab:# SERIAL CONSOLES s0:12345:respawn:/sbin/agetty 9600 ttyS0 vt100 s1:12345:respawn:/sbin/agetty 9600 ttyS1 vt100"
	read -p "

read it carefully and press enter key"
	if [ rf != jfs_ ];then
		emerge sys-fs/${rf/_/progs}
	else
		emerge sys-fs/jfsutils
	fi
	sys-fs/dosfstools
	return
}
function cmplknl() {
	case $knl in
		1)	genkernel all;;
		2)	genkernel menuconfig all;;
		3) cd /usr/src/linux
			read -p "Ready? (Enter)"
			make menuconfig
			make -j8 && make modules_install			##Suppose your CPU has 2 cores
			make install
			read -p "D'you wanna use lvm and mdadm? [y/n] : " yn
			if [ yn == y ];then
				genkernel --lvm --mdadm --install initramfs
			else
				genkernel --install initramfs
			fi;;
		4) cd /usr/src/linux
			cp $(dirname ${BASH_SOURCE[0]})/CONFIG_FILES/*-Arch.config .config
			read -p "Just do some simple sittings (Enter)"
			make menuconfig
			make -j8 && make modules_install
			make install
			read -p "D'you wanna use lvm and mdadm? [y/n] : " yn
			if [ yn == y ];then
				genkernel --lvm --mdadm --install initramfs
			else
				genkernel --install initramfs
			fi;;
		5) cd /usr/src/linux
			cp $(dirname ${BASH_SOURCE[0]})/CONFIG_FILES/*-Ubuntu.config .config
			read -p "Just do some simple sittings (Enter)"
			make menuconfig
			make -j8 && make modules_install
			make install
			read -p "D'you wanna use lvm and mdadm? [y/n] : " yn
			if [ yn == y ];then
				genkernel --lvm --mdadm --install initramfs
			else
				genkernel --install initramfs
			fi;;
		6) cd /usr/src/linux
			read -p "Give me the link?      >" lk
			wget $lk -O .config
			read -p "Alright...Ready? (Enter)"
			make menuconfig
			make -j8 && make modules_install
			make install
			read -p "D'you wanna use lvm and mdadm? [y/n] : " yn
			if [ yn == y ];then
				genkernel --lvm --mdadm --install initramfs
			else
				genkernel --install initramfs
			fi;;
	return
}
updt_SYS() {
	emerge -uvDN @world
	read -p "Where are you? (like \"Asia/Shanghai\" etc.) " timez
	echo "$timez" > /etc/timezone
	emerge --config sys-libs/timezone-data 
	echo "en_GB.UTF-8 UTF-8
ru_RU.UTF-8 UTF-8
zh_TW.UTF-8 UTF-8
zh_CN.UTF-8 UTF-8" >> /etc/locale.gen
	locale-gen
	eselect locale list
	read -p "Choose a language: " lg
	eselect locale set $lg
	read -p "Do you want to use ~amd64? [y/n] : " yn
	if [ yn == y ];then
		echo "sys-kernel/gentoo-sources ~amd64" > /etc/portage/package.accept_keywords
	fi
	emerge gentoo-sources genkernel
	ls -l /usr/src/linux
	return
}
function prfleslct() {
	eselect profile list
	read -p "select one : " num
	eselect profile set $num
	return
}
function updt_emerge() {
	emerge-webrsync
	emerge --sync
	return
}
function fstab() {
	echo "$boot		/boot	vfat	defaults	0 2
$swap		none	swap	sw	0 0
$root	/	$rf	noatime	0 1
/dev/cdrom	/mnt/cdrom	auto	noauto,user	0 0" >> /etc/fstab
	read -p "Edit /mnt/gentoo/fstab? [y/n] : " yn
	if [ yn == y ];then
		nano -w /etc/fstab
	fi
	return
}
##---------------START TO CONFIG---------------##
source /etc/profile		##To use the variables have alreadt defined in the previous file.
fstab
updt_emerge
prfleslct
updt_SYS
cmplknl
config
grubt
