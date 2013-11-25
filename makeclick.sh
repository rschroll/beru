#!/bin/bash

rm -r click/
mkdir click
for dir in Epub File FontList HttpServer html ui apparmor
do
    cp -r $dir click/
done
for file in beru beru.desktop beru.svg COPYING README.md
do
    cp $file click/
done

ARCH=`uname -m`
if [ "$ARCH" = "armv7l" ]
    then ARCH="armhf"
elif [ "$ARCH" = "x86_64" ]
    then ARCH="amd64"
elif [ "$ARCH" = "i686" ]
    then ARCH="i386"
fi
sed s/ARCH/$ARCH/ < manifest.json > click/manifest.json

click build click
