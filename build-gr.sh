#!/bin/bash
TOP=/tmp/build-gr
SRC_ISO=$TOP/ubuntu-20.04.3-desktop-amd64.iso
TGT_ISO=$TOP/ubuntu-20.04.3-gnuradio-amd64.iso

TMPFILE=`mktemp`

exithandler()
{
    if [ -n "$TMPFILE" ] ; then
	rm -f $TMPFILE
    fi
    echo "Done."
}
die()
{
    echo $*
    exit 1
}
cleanup()
{
    umount $TOP/livecd/squashfs
    umount /tmp/livecd
    umount $TOP/livecd/custom/proc
    umount $TOP/livecd/custom/sys
    rm -rf $TOP/livecd
    rmdir /tmp/livecd
}
trap exithandler EXIT
[ $UID -eq 0 ] || die "Must be run as root"
if [ "$1" = "-f" ] ; then
    echo "FORCING CLEAN-UP"
    read -p "Press enter to continue..." BLARF
    set -x
    cleanup
    set +x
fi
mount | grep -q livecd && die "livecd is mounted, aborting"
[ -d /tmp/livecd ] && die "/tmp/livecd exists, aborting"
[ -d $TOP/livecd ] && die "$TOP/livecd exists, aborting"
set -x
mkdir /tmp/livecd || die "line $LINENO"
mount -o loop $SRC_ISO /tmp/livecd || die "line $LINENO"
mkdir -p $TOP/livecd/cd || die "line $LINENO"
rsync --exclude=/casper/filesystem.squashfs -a /tmp/livecd/ $TOP/livecd/cd || die "line $LINENO"
mkdir $TOP/livecd/squashfs  $TOP/livecd/custom || die "line $LINENO"
modprobe squashfs || die "line $LINENO"
mount -t squashfs -o loop /tmp/livecd/casper/filesystem.squashfs $TOP/livecd/squashfs/ || die "line $LINENO"
cp -a $TOP/livecd/squashfs/* $TOP/livecd/custom || die "line $LINENO"
# network access (temporary, local, for package installation)
if [ -f $TOP/livecd/custom/etc/resolv.conf ] ; then
    mv $TOP/livecd/custom/etc/resolv.conf $TOP/livecd/custom/etc/resolv.conf.orig
fi
if [ -f $TOP/livecd/custom/etc/hosts ] ; then
    mv $TOP/livecd/custom/etc/hosts $TOP/livecd/custom/etc/hosts.orig
fi
cp /etc/resolv.conf /etc/hosts $TOP/livecd/custom/etc/
# sources - locally specified and those specified in the source ISO
cat $TOP/livecd/custom/etc/apt/sources.list /etc/apt/sources.list | egrep -v '(^$|^#)' | sort | uniq >$TMPFILE || die "line $LINENO"
cp $TMPFILE $TOP/livecd/custom/etc/apt/sources.list
cp `dirname $0`/build-gr-inside.sh $TOP/livecd/custom
chroot $TOP/livecd/custom /build-gr-inside.sh
# manifest files
chmod +w $TOP/livecd/cd/casper/filesystem.manifest || die "line $LINENO"
chroot $TOP/livecd/custom dpkg-query -W --showformat='${Package} ${Version}\n' > $TOP/livecd/cd/casper/filesystem.manifest || die "line $LINENO"
cp $TOP/livecd/cd/casper/filesystem.manifest $TOP/livecd/cd/casper/filesystem.manifest-desktop || die "line $LINENO"
# regenerate squashfs
mksquashfs $TOP/livecd/custom $TOP/livecd/cd/casper/filesystem.squashfs || die "line $LINENO"
# update MD5 sums
rm $TOP/livecd/cd/md5sum.txt || die "line $LINENO"
pushd $TOP/livecd/cd || die "line $LINENO"
find . -type f -exec md5sum {} + > $TMPFILE || die "line $LINENO"
popd
cp $TMPFILE $TOP/livecd/cd/md5sum.txt || die "line $LINENO"
# create the iso
cd $TOP/livecd/cd || die "line $LINENO"
mkisofs -r -V "Ubuntu-Live GNU Radio" -b isolinux/isolinux.bin -c isolinux/boot.cat -cache-inodes -J -l -no-emul-boot -boot-load-size 4 -boot-info-table -o $TGT_ISO . || die "line $LINENO"
# unmount and clean
umount $TOP/livecd/squashfs/ || die "line $LINENO"
umount /tmp/livecd || die "line $LINENO"
rm -rf $TOP/livecd/ || die "line $LINENO"
