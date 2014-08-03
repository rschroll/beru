/* Copyright 2014 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

import QtQuick 2.0

// This should really be a JS library, not a QML object, but mutli-line
// strings make this so much easier!
Item {
    // From http://en.wikipedia.org/wiki/HSL_and_HSV#From_luma.2Fchroma.2Fhue
    // Note that not all values are in the RGB gamut!
    function hcy(H, C, Y) {
        var Hp = H*6,
            X = C * (1 - Math.abs(Hp % 2 - 1)),
            R = 0, G = 0, B = 0;
        if (Hp < 1) {
            R = C;
            G = X;
        } else if (Hp < 2) {
            R = X;
            G = C;
        } else if (Hp < 3) {
            G = C;
            B = X;
        } else if (Hp < 4) {
            G = X;
            B = C;
        } else if (Hp < 5) {
            R = X;
            B = C;
        } else {
            R = C;
            B = X;
        }
        var Yr = 0.30,
            Yg = 0.59,
            Yb = 0.11,
            m = Y - (Yr * R + Yg * G + Yb * B);
        try {
            return "#" + toHex(R + m) + toHex(G + m)+ toHex(B + m);
        } catch (e) {
            return "";
        }
    }

    function hcyrel(H, C, Y) {
        var Hp = H*6,
            Yr = 0.30,
            Yg = 0.59,
            Yb = 0.11,
            Ht, a, b, c;
        if (Hp < 1) {
            a = Yr; b = Yg; c = Yb;
            Ht = Hp;
        } else if (Hp < 2) {
            a = Yg; b = Yr; c = Yb;
            Ht = 2 - Hp;
        } else if (Hp < 3) {
            a = Yg; b = Yb; c = Yr;
            Ht = Hp - 2;
        } else if (Hp < 4) {
            a = Yb; b = Yg; c = Yr;
            Ht = 4 - Hp;
        } else if (Hp < 5) {
            a = Yb; b = Yr; c = Yg;
            Ht = Hp - 4;
        } else {
            a = Yr; b = Yb; c = Yg;
            Ht = 6 - Hp;
        }
        var Cmax = Math.min(Y / (a + b*Ht), (1 - Y) / (b * (1-Ht) + c));
        return hcy(H, C*Cmax, Y);
    }

    function toHex(v) {
        if ((v < 0) || (v > 1))
            throw "Out of gamut";
        v = Math.pow(v, 1/2.2);
        var s = Math.round(v * 255).toString(16);
        if (s.length == 1)
            return "0" + s;
        return s;
    }

    function hue(model) {
        return parseInt(Qt.md5(model.title).slice(0,2), 16) / 256
    }

    function textColor(model) {
        if (model.cover == "ZZZerror")
            return "black"
        return hcy(0.167, 0.051, 0.051)
    }

    function bgColor(model) {
        return hcy(hue(model), 0.25, 0.25)
    }

    function highlightColor(model) {
        if (model.cover === "ZZZerror")
            return "white"
        return hcy(hue(model), 0.35, 0.39)
    }

    function bindColor(model) {
        return hcyrel(hue(model), 0.5, 0.03)
    }

    function missingCover(model) {
        return "data:image/svg+xml," +
                svg.replace("$bgColor", bgColor(model)
                            ).replace("$textColor", textColor(model)
                                      ).replace("$highlightColor", highlightColor(model)
                                                ).replace(/\$bindColor/g, bindColor(model))
    }

    function errorCover(model) {
        return Qt.resolvedUrl("images/error_cover_full.svg")
    }

    property string svg: '<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   version="1.2"
   width="360"
   height="540"
   id="svg2">
  <rect
     width="360"
     height="540"
     x="0"
     y="0"
     id="rect3002"
     style="fill:$bgColor;fill-opacity:1;fill-rule:nonzero;stroke:#47172c;stroke-width:0.50000000000000000;stroke-linecap:round;stroke-linejoin:round;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none" />
  <rect
     style="fill:$bindColor;fill-opacity:1;fill-rule:nonzero;stroke:none"
     id="rect3768"
     width="33.75"
     height="540"
     x="0"
     y="0" />
  <path
     style="color:#000000;fill:$bindColor;fill-opacity:1;stroke:none;stroke-width:4.375;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate"
     d="M 303.75,0 360,56.25 360,0"
     id="path3770"
     inkscape:connector-curvature="0"
     sodipodi:nodetypes="ccc" />
  <path
     style="color:#000000;fill:$bindColor;stroke:none;stroke-width:4.37500000000000000;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none;stroke-dashoffset:0;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;fill-opacity:1"
     d="M 303.75,540 360,483.75 360,540"
     id="path3772"
     inkscape:connector-curvature="0" />
  <path
     id="path3816"
     d="m 89.96361,258.21875 a 2.50025,2.50025 0 0 0 -1.5,4.3125 L 97.93236,272 l -9.46875,9.46875 a 2.5190679,2.5190679 0 1 0 3.5625,3.5625 L 102.55735,274.5 l 82.375,0 c 1.01017,2.64022 3.56709,4.53125 6.5625,4.53125 2.99541,0 5.55233,-1.89103 6.5625,-4.53125 l 82.375,0 10.53125,10.53125 a 2.5190679,2.5190679 0 1 0 3.5625,-3.5625 L 285.05735,272 l 9.46875,-9.46875 a 2.5190679,2.5190679 0 1 0 -3.5625,-3.5625 L 280.43235,269.5 l -82.375,0 c -1.01017,-2.64022 -3.56709,-4.53125 -6.5625,-4.53125 -2.99541,0 -5.55233,1.89103 -6.5625,4.53125 l -82.375,0 -10.53124,-10.53125 a 2.50025,2.50025 0 0 0 -1.8125,-0.75 2.50025,2.50025 0 0 0 -0.25,0 z"
     style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:$highlightColor;fill-opacity:1;stroke:none;stroke-width:5;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans"
     inkscape:connector-curvature="0" />
  <path
     style="font-size:medium;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-indent:0;text-align:start;text-decoration:none;line-height:normal;letter-spacing:normal;word-spacing:normal;text-transform:none;direction:ltr;block-progression:tb;writing-mode:lr-tb;text-anchor:start;baseline-shift:baseline;color:#000000;fill:$textColor;fill-opacity:1;stroke:none;stroke-width:5;marker:none;visibility:visible;display:inline;overflow:visible;enable-background:accumulate;font-family:Sans;-inkscape-font-specification:Sans"
     d="M 89.71875 256.21875 A 2.50025 2.50025 0 0 0 88.21875 260.53125 L 97.6875 270 L 88.21875 279.46875 A 2.5190679 2.5190679 0 1 0 91.78125 283.03125 L 102.3125 272.5 L 184.6875 272.5 C 185.69767 275.14022 188.25459 277.03125 191.25 277.03125 C 194.24541 277.03125 196.80233 275.14022 197.8125 272.5 L 280.1875 272.5 L 290.71875 283.03125 A 2.5190679 2.5190679 0 1 0 294.28125 279.46875 L 284.8125 270 L 294.28125 260.53125 A 2.5190679 2.5190679 0 1 0 290.71875 256.96875 L 280.1875 267.5 L 197.8125 267.5 C 196.80233 264.85978 194.24541 262.96875 191.25 262.96875 C 188.25459 262.96875 185.69767 264.85978 184.6875 267.5 L 102.3125 267.5 L 91.78125 256.96875 A 2.50025 2.50025 0 0 0 89.96875 256.21875 A 2.50025 2.50025 0 0 0 89.71875 256.21875 z "
     id="path3803" />
</svg>
'
}
