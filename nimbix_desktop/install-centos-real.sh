#!/bin/bash -ex

# assumes install-centos-tiger.sh was run first -- XX old assumption
ARCH=$(arch)

# update links
#REALVNC_VER=6.2.1
#REALVNC="https://www.realvnc.com/download/file/vnc.files/VNC-Server-$REALVNC_VER-Linux-x64.rpm"
REALVNC="https://www.realvnc.com/download/file/vnc.files/VNC-5.3.2-Linux-x64-RPM.tar.gz"

VGL64VER=2.6.1
VGL64="https://downloads.sourceforge.net/project/virtualgl/$VGL64VER/VirtualGL-${VGL64VER}.x86_64.rpm"
VGL32="https://downloads.sourceforge.net/project/virtualgl/$VGL64VER/VirtualGL-${VGL64VER}.i386.rpm"
#VGL64SRC="https://downloads.sourceforge.net/project/virtualgl/$VGL64VER/VirtualGL-$VGL64VER.tar.gz"

# Get CentOS release version
VERSION_ID=$(cat /etc/system-release-cpe | awk -F: '{print $5}')

if [ $VERSION_ID -gt 7 ]; then
    dnf --enablerepo=epel group -y install "Xfce" "base-x" "Fonts"
    dnf -y install perl wget pygtk2 firefox net-tools \
           xorg-x11-fonts-Type1 \
           xorg-x11-fonts-misc xorg-x11-fonts-75dpi xorg-x11-fonts-100dpi \
           xorg-x11-fonts-ISO8859-1-100dpi xorg-x11-fonts-ISO8859-1-75dpi

       #xauth gnome-icon-theme xkeyboard-config glx-utils xorg-x11-utils
       # compat-libstdc++-33 numpy python-pip ImageMagick-devel xorg-x11-apps xcb-util xcb-util-keysyms
else
  yum -y groupinstall Xfce
  yum -y groupinstall Fonts
  yum -y install perl wget xauth pygtk2 gnome-icon-theme xorg-x11-fonts-Type1 \
         xorg-x11-fonts-misc xorg-x11-fonts-75dpi xorg-x11-fonts-100dpi \
         xkeyboard-config firefox net-tools glx-utils xorg-x11-utils \
         xorg-x11-fonts-ISO8859-1-100dpi xorg-x11-fonts-ISO8859-1-75dpi \
         compat-libstdc++-33 numpy python-pip ImageMagick-devel xorg-x11-apps \
         xcb-util xcb-util-keysyms
fi

if [ ${VERSION_ID} -gt 6 ]; then
    yum -y install ristretto
fi

#curl $REALVNC >/tmp/$(basename $REALVNC)
wget --content-disposition -O - "$REALVNC"|tar -C /tmp -xzf -
rm -f /usr/bin/Xvnc
yum -y install /tmp/VNC-Server-*-Linux-x64.rpm || \
    yum -y update /tmp/VNC-Server-*-Linux-x64.rpm
rm -f /tmp/VNC-*.rpm
ln -sf /usr/bin/Xvnc-realvnc /usr/bin/Xvnc

if [ "$ARCH" != "x86_64" ]; then
    yum -y install VirtualGL
else
    cd /tmp
    wget --content-disposition "$VGL64"
    wget --content-disposition "$VGL32"
    yum -y install VirtualGL*.rpm || yum -y update VirtualGL*.rpm
    rm -f VirtualGL*.rpm
fi

dirname=$(dirname $0)
[ "$dirname" = "." ] && dirname=$(pwd)
mkdir -p /etc/NAE
cp ${dirname}/help-real.html /etc/NAE/help.html

yum clean all

pip2 install --no-cache-dir Wand

[ -f /etc/init.d/NetworkManager ] && /sbin/chkconfig NetworkManager off
[ -f /etc/xdg/autostart/xfce-polkit.desktop ] && \
    rm -f /etc/xdg/autostart/xfce-polkit.desktop

. ${dirname}/postinstall-real.sh