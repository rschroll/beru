/* Copyright 2013 Robert Schroll
 *
 * styleManager file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

styleManager = {
    cookieName: "",
    reader: null,

    init: function (title) {
        styleManager.cookieName = "monocle.stylesaver." + title.toLowerCase().replace(/[^a-z0-9]/g, '');

        var styles = styleManager.loadCookie();
        if (styles == null)
            styles = DEFAULT_STYLES;
        styleManager.sendStyles(styles);
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
        var outerCSS = "div.monelem_page { background: " + styles.background + "; } " +
                "div.monelem_sheaf { left: -webkit-calc(1em + " + styles.margin + "%); " +
                "right: -webkit-calc(1em + " + styles.margin + "%); " +
                "top: -webkit-calc(1em + " + DEFAULT_STYLES.marginv + "%); " +
                "bottom: -webkit-calc(1em + " + 2*DEFAULT_STYLES.marginv + "%); }";
        var styleElement = document.getElementById("appliedStyles");
        styleElement.replaceChild(document.createTextNode(outerCSS), styleElement.firstChild);
    },

    updateStyles: function (styles) {
        styleManager.updateOuter(styles);
        styleManager.reader.formatting.updatePageStyles(styleManager.reader.formatting.properties.initialStyles,
                                                        styleManager.iframeCSS(styles), true);
        styleManager.reader.formatting.setFontScale(styles.fontScale, true);

        styleManager.saveCookie(styles);
    },

    sendStyles: function (styles) {
        Messaging.sendMessage("Styles", styles);
    },

    resetToDefault: function () {
        styleManager.updateStyles(DEFAULT_STYLES);
        styleManager.sendStyles(DEFAULT_STYLES);
    },

    setDefault: function (styles) {
        DEFAULT_STYLES = styles;
    },

    loadCookie: function() {
        if (!document.cookie)
            return null;
        var regex = new RegExp(styleManager.cookieName + "=(.+?)(;|$)");
        var matches = document.cookie.match(regex);
        if (matches)
            return JSON.parse(decodeURIComponent(matches[1]));
        return null;
    },

    saveCookie: function(styles) {
        var d = new Date();
        d.setTime(d.getTime() + 365*24*60*60*1000);
        var value = encodeURIComponent(JSON.stringify(styles))
        document.cookie = styleManager.cookieName + "=" + value +
                "; expires=" + d.toGMTString() + "; path=/";
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
