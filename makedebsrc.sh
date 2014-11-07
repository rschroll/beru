#!/bin/bash
RELEASES="trusty utopic vivid"
PPA="ppa:rschroll/beru"
NAME="beru"

# Version can only be a.b.c for numbers a,b,c!
# Thus, we use even revisions for restricted versions and odd revisions for
# versions with file system access.
read MAJ MIN REV < VERSION
# Only make version with file system access for debs
REV=$(( REV + 1 ))
VERSION="$MAJ.$MIN.$REV"
DIR="beru-$VERSION/"
TARFILE="beru_$VERSION.orig.tar.gz"

git archive --prefix=$DIR HEAD | gzip > ../$TARFILE
cd ..
tar -xf $TARFILE
cd $DIR

# Adapted from http://bobthegnome.blogspot.com/2012/12/a-script-for-supporting-multiple-ubuntu.html
ORIG_RELEASE=`head -1 debian/changelog | sed 's/.*) \(.*\);.*/\1/'`
for RELEASE in $RELEASES ;
do
    cp debian/changelog debian/changelog.backup
    sed -i "s/${ORIG_RELEASE}/${RELEASE}/;s/-0)/-0~${RELEASE}1)/" debian/changelog
    debuild -S
    dput ${PPA} ../${NAME}_${VERSION}-0~${RELEASE}1_source.changes
    mv debian/changelog.backup debian/changelog
done
cd ..
rm -r $DIR
