#!/bin/bash

# Version can only be a.b.c for numbers a,b,c!
# Thus, we use even revisions for restricted versions and odd revisions for
# versions with file system access.
read MAJ MIN REV < VERSION

ARCH="$(dpkg-architecture -qDEB_HOST_ARCH)"
# Create versions with and without file system access
for i in 0 1
do
    REV=$(( REV + i ))
    [ $i == 1 ] && SUFFIX=".access" || SUFFIX=""
    VERSION="$MAJ.$MIN.$REV"

    DIR="beru-$VERSION"
    mkdir $DIR
    for dir in Epub File FontList HttpServer html ui apparmor
    do
        cp -r $dir $DIR
    done
    for file in beru beru.desktop beru.svg COPYING README.md
    do
        cp $file $DIR
    done
    sed -e "s/@ARCH@/$ARCH/g" \
        -e "s/@VERSION@/$VERSION/g" \
        -e "s/@SUFFIX@/$SUFFIX/g" < manifest.json.in > $DIR/manifest.json

    click build $DIR
    tar -czf "beru_${VERSION}_$ARCH.tar.gz" $DIR
    rm -r $DIR
done
