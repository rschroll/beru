/* Copyright 2013-2014 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

import QtQuick 2.0
import HttpServer 1.0
import Epub 1.0


HttpServer {
    id: server
    
    property int port: 5000
    
    Component.onCompleted: {
        while (!listen("127.0.0.1", port))
            port += 1
    }
    
    property var epub: EpubReader {
        id: epub
    }

    property var fileserver: FileServer {
        id: fileserver
    }

    function loadFile(filename) {
        return epub.load(filename)
    }
    
    function static_file(path, response) {
        // Need to strip off leading "file://"
        fileserver.serve(Qt.resolvedUrl("../html/" + path).slice(7), response)
    }

    function defaults(response) {
        response.setHeader("Content-Type", "application/javascript")
        response.writeHead(200)

        var styles = bookPage.getBookStyles()
        response.write("DEFAULT_STYLES = " + JSON.stringify(styles) + ";\n")

        var locus = getBookSetting("locus")
        if (locus == undefined)
            locus = null
        response.write("SAVED_PLACE = " + JSON.stringify(locus) + ";\n")

        response.end()
    }
    
    onNewRequest: { // request, response
        if (request.path == "/")
            return static_file("index.html", response)
        if (request.path == "/.bookdata.js")
            return epub.serveBookData(response)
        if (request.path == "/.defaults.js")
            return defaults(response)
        if (request.path[1] == ".")
            return static_file(request.path.slice(2), response)
        return epub.serveComponent(request.path.slice(1), response)
    }
}
