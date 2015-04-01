/* Copyright 2013-2014 Robert Schroll
 *
 * styleManager file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

styleManager = {
    cookieName: "",
    reader: null,

    init: function (title) {
        var styles = DEFAULT_STYLES;
        styleManager.updateOuter(styles);
        return {stylesheet: styleManager.iframeCSS(styles), fontScale: styles.fontScale};
    },

    iframeCSS: function (styles) {
        var res = "body { color: " + styles.textColor + "; background: transparent; ";
        if (styles.fontFamily != "Default")
            res += "font-family: '" + styles.fontFamily + "'; ";
        if (styles.lineHeight != "Default")
            res += "line-height: " + styles.lineHeight + "; ";
        return styleManager.fontFaces() + res + "}";
    },

    updateOuter: function (styles) {
        var bumper = styles.bumper + "em + ";
        var outerCSS = "div.monelem_page { background: " + styles.background + "; } " +
                "div.monelem_sheaf { left: -webkit-calc(" + bumper + styles.margin + "%); " +
                "right: -webkit-calc(" + bumper + styles.margin + "%); " +
                "top: -webkit-calc(" + bumper + DEFAULT_STYLES.marginv + "%); " +
                "bottom: -webkit-calc(" + bumper + 2*DEFAULT_STYLES.marginv + "%); }";
        var styleElement = document.getElementById("appliedStyles");
        styleElement.replaceChild(document.createTextNode(outerCSS), styleElement.firstChild);
    },

    updateStyles: function (styles) {
        styleManager.updateOuter(styles);
        styleManager.reader.formatting.updatePageStyles(styleManager.reader.formatting.properties.initialStyles,
                                                        styleManager.iframeCSS(styles), true);
        styleManager.reader.formatting.setFontScale(styles.fontScale, true);
    },

    fontFaces: function() {
        var res = "";
        var families = ["Bitstream Charter", "URW Bookman L", "URW Gothic L"];
        for (var k=0; k<families.length; k++) {
            var family = families[k];
            for (var i=0; i<2; i++) {
                for (var b=0; b<2; b++) {
                    var fontname = family + (b ? " Bold": "") + (i ? " Italic" : "");
                    res += "@font-face { font-family: '" + family + "'; " +
                            "font-style: " + (i ? "italic" : "normal") +"; " +
                            "font-weight: " + (b ? "bold" : "normal") + "; " +
                            "src: local('" + fontname + "'), url('/.fonts/" + fontname + ".ttf'); }\n"
                }
            }
        }
        return res;
    }
}
