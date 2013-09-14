#!/bin/bash

rm -r click/
mkdir click
for dir in Epub File FontList HttpServer html ui apparmor
do
    cp -r $dir click/
done
for file in beru beru.desktop beru.svg manifest.json COPYING README.md
do
    cp $file click/
done

click build click
