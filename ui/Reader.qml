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

    property string fileType: ""
    property var currentReader: {
        switch (fileType) {
        case "EPUB":
            return epub
        case "CBZ":
            return cbz
        case "PDF":
            return pdf
        default:
            return undefined
        }
    }
    property bool pictureBook: currentReader !== epub
    property string error: {
        if (currentReader === undefined)
            return i18n.tr("Could not determine file type.\n\n" +
                           "Remember, Beru can only open EPUB, PDF, and CBZ files without DRM.")
        else
            return i18n.tr("Could not parse file.\n\n" +
                           "Although it appears to be a %1 file, it could not be parsed by Beru.").arg(fileType)
    }

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

    function load(filename) {
        fileType = filesystem.fileType(filename)
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
