#!/bin/bash

VERSION=1.9.0
ARCH=$(arch)

# update links as needed
TIGERVNC="https://storage.googleapis.com/app_archive/tigervnc/tigervnc-$VERSION.$ARCH.tar.gz"

# Grab tarballs on x86_64, install in place to an location that needs pathing
cd /usr/local/lib/nimbix_desktop
wget --content-disposition "$TIGERVNC"
