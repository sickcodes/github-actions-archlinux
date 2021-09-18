#!/bin/sh
set -e
wget -O /tmp/undocker.py https://raw.githubusercontent.com/sickcodes/undocker/master/undocker.py
sudo mkdir -p /rootfs
# Forked from https://hub.docker.com/r/zaoqi/github-actions-archlinux
# @ https://hub.docker.com/r/sickcodes/github-actions-archlinux
docker pull sickcodes/github-actions-archlinux
docker save sickcodes/github-actions-archlinux | sudo python3 /tmp/undocker.py -o /rootfs zaoqi/github-actions-archlinux
docker rmi sickcodes/github-actions-archlinux
rm -fr /tmp/undocker.py
sudo sh -c "
systemctl stop docker
mkdir /rootfs/old.rootfs
mount --bind / /rootfs/old.rootfs
mkdir -p /rootfs/usr/lib/modules/
cp -Lfr /lib/modules/* /rootfs/usr/lib/modules/
chroot /rootfs /bin/sh -c '
cd /old.rootfs/etc/ &&
cp -Pfr passwd group shadow hosts resolv.conf hostname sudoers sudoers.d /etc/ &&
cd /old.rootfs &&
rm -fr etc sbin bin lib usr lib64 var/mail var/spool/mail &&
cd / &&
cp -Pfr home mnt opt root run srv var /old.rootfs &&
mv etc bin lib lib64 sbin usr /old.rootfs
' &&
umount /rootfs/old.rootfs &&
rm -fr /rootfs/ &&
systemctl daemon-reexec
"
