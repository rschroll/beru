/* Copyright 2013 Robert Schroll
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
        epub.load(filename)
    }
    
    function static_file(path, response) {
        // Need to strip off leading "file://"
        fileserver.serve(Qt.resolvedUrl("../html/" + path).slice(7), response)
    }
    
    onNewRequest: { // request, response
        if (request.path == "/")
            return static_file("index.html", response)
        if (request.path == "/.bookdata.js")
            return epub.serveBookData(response)
        if (request.path[1] == ".")
            return static_file(request.path.slice(2), response)
        return epub.serveComponent(request.path.slice(1), response)
    }
}
