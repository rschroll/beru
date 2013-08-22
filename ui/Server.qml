/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

import QtQuick 2.0
import HttpServer 1.0

import "../jszip/jszip.js" as JsZip


HttpServer {
    id: server
    
    property int port: 5000
    
    Component.onCompleted: {
        while (!listen("127.0.0.1", port))
            port += 1
    }
    
    property var zipfile

    function loadFile(filename) {
        var file = filereader.read_b64(filename)
        zipfile = new JsZip.JSZip(file, {base64: true})
    }
    
    function static_file(path, response) {
        // Need to strip off leading "file://"
        var file = filereader.read_b64(Qt.resolvedUrl("../html/" + path).slice(7))
        response.writeHead(200)
        response.write_b64(file)
        response.end()
    }
    
    function component(path, response) {
        var file = zipfile.file(path.slice(1))
        //response.setHeader("Content-Type", "text/plain")
        response.writeHead(200)
        response.write_b64(file.asBase64())
        response.end()
    }
    
    onNewRequest: { // request, response
        if (request.path == "/")
            return static_file("index.html", response)
        if (request.path[1] == ".")
            return static_file(request.path.slice(2), response)
        return component(request.path, response)
    }
}
