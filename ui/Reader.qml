/* Copyright 2015 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

import QtQuick 2.0
import Epub 1.0


Item {
    id: reader

    signal contentsReady(var contents)

    property var currentReader

    EpubReader {
        id: epub
        onContentsReady: reader.contentsReady(contents)
    }

    CBZReader {
        id: cbz
        onContentsReady: reader.contentsReady(contents)
    }

    function isCBZ(filename) {
        return (filename.slice(-4) == ".cbz")
    }

    function load(filename) {
        currentReader = isCBZ(filename) ? cbz : epub
        return currentReader.load(filename)
    }

    function hash() {
        return currentReader.hash
    }

    function title() {
        return currentReader.title
    }

    function serveBookData(response) {
        currentReader.serveBookData(response)
    }

    function serveComponent(filename, response) {
        currentReader.serveComponent(filename, response)
    }

    function getCoverInfo(thumbsize, fullsize) {
        return currentReader.getCoverInfo(thumbsize, fullsize)
    }
}
