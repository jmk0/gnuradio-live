#!/bin/bash

# This script executes all the commands that must be done inside a
# chroot session.

set -x
die()
{
    echo $*
    exit 1
}
cleanup()
{
    apt-get clean
    rm -rf /tmp/*
    mv /etc/hosts.orig /etc/hosts
    mv /etc/resolv.conf.orig /etc/resolv.conf
    umount /proc/
    umount /sys/
}
trap cleanup EXIT
# pseudo filesystems
mount -t proc none /proc/ || die "line $LINENO"
mount -t sysfs none /sys/ || die "line $LINENO"
add-apt-repository -y ppa:gnuradio/gnuradio-releases || die "line $LINENO"
apt-get -y update || die "line $LINENO"
apt-get -y dist-upgrade || die "line $LINENO"
apt-get -y install gnuradio gqrx-sdr airspy python3-packaging || die "line $LINENO"
mkdir -p /etc/skel/Desktop || die "line $LINENO"
printf '[Desktop Entry]\nVersion=1.0\nName=GNU Radio Companion\nComment=Do that Radio\nGenericName=gnuradio\nExec=gnuradio-companion\nTerminal=false\nX-MultipleArgs=false\nType=Application\nCategories=Internet;\n' > /etc/skel/Desktop/gnuradio.desktop || die "line $LINENO"
chmod a+x /etc/skel/Desktop/gnuradio.desktop || die "line $LINENO"

