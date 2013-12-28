#!/bin/bash

# Version can only be a.b.c for numbers a,b,c!
# Thus, we use even revisions for restricted versions and odd revisions for
# versions with file system access.
read MAJ MIN REV < VERSION

# If the first argument to the script starts with an 'a', build the version
# with filesystem access.
if [ "${1:0:1}" == "a" ]
then
    SUFFIX=".access"
    REV=$(( REV + 1 ))
else
    SUFFIX=""
fi
VERSION="$MAJ.$MIN.$REV"
ARCH="$(dpkg-architecture -qDEB_HOST_ARCH)"

DIR="beru_$VERSION"
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
