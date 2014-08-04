#!/bin/bash

echo "import QtQuick 2.0
Item {"
while [ "$1" !=  "" ]
do
    filename=${1##*/}
    echo "property string ${filename%%.*}: \""
    base64 "$1"
    echo "\""
    shift
done
echo "}"

