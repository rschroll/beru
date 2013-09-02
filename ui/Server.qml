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
        return epub.load(filename)
    }
    
    function static_file(path, response) {
        // Need to strip off leading "file://"
        fileserver.serve(Qt.resolvedUrl("../html/" + path).slice(7), response)
    }

    function defaults(response) {
        var defaults = {
            textColor: "#222",
            fontFamily: "Default",
            lineHeight: "Default",
            fontScale: 1,
            background: "url(.background_paper@30.png)",
            margin: 0,
            marginv: 0
        }
        var targetwidth = 60
        var widthgu = width/units.gu(1)
        if (widthgu > targetwidth)
            // Set the margins to give us the target width, but no more than 30%.
            defaults.margin = Math.round(Math.min(50 * (1 - targetwidth/widthgu), 30))

        var saveddefault = getSetting("defaultBookStyle")
        var savedvals = {}
        if (saveddefault != null)
            savedvals = JSON.parse(saveddefault)
        for (var prop in savedvals)
            if (prop in defaults)
                defaults[prop] = savedvals[prop]

        if (savedvals.marginv == undefined && widthgu > targetwidth)
            // Set the vertical margins to be the same as the horizontal, but no more than 5%.
            marginv = Math.min(marginh, 5)

        response.setHeader("Content-Type", "application/javascript")
        response.writeHead(200)
        response.write("DEFAULT_STYLES = " + JSON.stringify(defaults) + ";\n")

        var locus = getBookSettings("locus")
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
