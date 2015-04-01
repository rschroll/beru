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
    property bool pictureBook: currentReader !== epub

    EpubReader {
        id: epub
        onContentsReady: reader.contentsReady(contents)
    }

    CBZReader {
        id: cbz
        onContentsReady: reader.contentsReady(contents)
    }

    PDFReader {
        id: pdf
        onContentsReady: reader.contentsReady(contents)
        width: mainView.width
        height: mainView.height
    }

    function getReader(filename) {
        if (filename.slice(-4) == ".cbz")
            return cbz;
        if (filename.slice(-4) == ".pdf")
            return pdf;
        if (filename.slice(-5) == ".epub")
            return epub;
        return undefined;
    }

    function load(filename) {
        currentReader = getReader(filename)
        if (currentReader === undefined)
            return false
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
