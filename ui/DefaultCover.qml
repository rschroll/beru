/* Copyright 2014 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

import QtQuick 2.0

// This should really be a JS library, not a QML object, but mutli-line
// strings make this so much easier!
Item {
    function toHex(v) {
        var s = Math.round(v * 256).toString(16)
        if (s.length == 1)
            return "0" + s
        return s
    }

    function hue(model) {
        return parseInt(Qt.md5(model.title).slice(0,2), 16) / 256
    }

    function textColor(model) {
        if (model.cover == "ZZZerror")
            return "black"
        return Qt.hsla(hue(model), 0.44, 0.32, 1)
    }

    function getColor(model) {
        var color = Qt.hsla(hue(model), 0.6, 0.68, 1)
        return "#" + toHex(color.r) + toHex(color.g)+ toHex(color.b)
    }

    function missingCover(model) {
        return "data:image/svg+xml," + svg.replace("$color", getColor(model))
    }

    function errorCover(model) {
        return Qt.resolvedUrl("images/error_cover_full.svg")
    }

    property string svg: '<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   version="1.2"
   width="360"
   height="540"
   id="svg2">
  <defs
     id="defs4" />
  <metadata
     id="metadata7">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <rect
     width="360"
     height="540"
     x="0"
     y="0"
     id="rect3002"
     style="fill:$color;fill-opacity:1;fill-rule:nonzero;stroke:#47172c;stroke-width:0.5;stroke-linecap:round;stroke-linejoin:round;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none" />
  <path
     d="m 202.5,270 a 22.5,22.5 0 1 1 -45,0 22.5,22.5 0 1 1 45,0 z"
     id="path3774"
     style="fill:#212121;fill-opacity:0.34042556;fill-rule:nonzero;stroke:none" />
  <path
     d="m 202.5,270 a 22.5,22.5 0 1 1 -45,0 22.5,22.5 0 1 1 45,0 z"
     transform="matrix(0.75,0,0,0.75,-16.875,67.5)"
     id="path3776"
     style="fill:#212121;fill-opacity:0.34042556;fill-rule:nonzero;stroke:none" />
  <path
     d="m 202.5,270 a 22.5,22.5 0 1 1 -45,0 22.5,22.5 0 1 1 45,0 z"
     transform="matrix(0.5,0,0,0.5,-22.5,135)"
     id="path3778"
     style="fill:#212121;fill-opacity:0.34042556;fill-rule:nonzero;stroke:none" />
  <path
     d="m 202.5,270 a 22.5,22.5 0 1 1 -45,0 22.5,22.5 0 1 1 45,0 z"
     transform="matrix(0.25,0,0,0.25,-16.875,202.5)"
     id="path3780"
     style="fill:#212121;fill-opacity:0.34042556;fill-rule:nonzero;stroke:none" />
  <path
     d="m 202.5,270 a 22.5,22.5 0 1 1 -45,0 22.5,22.5 0 1 1 45,0 z"
     transform="matrix(0.25,0,0,0.25,286.875,202.5)"
     id="path3782"
     style="fill:#212121;fill-opacity:0.34042556;fill-rule:nonzero;stroke:none" />
  <path
     d="m 202.5,270 a 22.5,22.5 0 1 1 -45,0 22.5,22.5 0 1 1 45,0 z"
     transform="matrix(0.5,0,0,0.5,202.5,135)"
     id="path3784"
     style="fill:#212121;fill-opacity:0.34042556;fill-rule:nonzero;stroke:none" />
  <path
     d="m 202.5,270 a 22.5,22.5 0 1 1 -45,0 22.5,22.5 0 1 1 45,0 z"
     transform="matrix(0.75,0,0,0.75,106.875,67.5)"
     id="path3786"
     style="fill:#212121;fill-opacity:0.34042556;fill-rule:nonzero;stroke:none" />
</svg>
'
}
