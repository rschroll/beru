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
sed s/@ARCH@/$(dpkg-architecture -qDEB_HOST_ARCH)/ < manifest.json.in > click/manifest.json

click build click
