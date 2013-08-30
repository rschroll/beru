/* Copyright 2013 Robert Schroll
 *
 * styleManager file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

DEFAULT_STYLES = {
    textColor: "#222",
    fontFamily: "Default",
    lineHeight: "Default",
    fontScale: 1,
    background: "url(.background_paper@30.png)",
    margin: 0
}

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
        var res = "body { color: " + styles.textColor + "; ";
        if (styles.fontFamily != "Default")
            res += "font-family: '" + styles.fontFamily + "'; ";
        if (styles.lineHeight != "Default")
            res += "line-height: " + styles.lineHeight + "; ";
        return res + "}";
    },

    updateOuter: function (styles) {
        var outerCSS = "div.monelem_page { background: " + styles.background + "; } " +
                "div.monelem_sheaf { left: -webkit-calc(1em + " + styles.margin + "%); " +
                "right: -webkit-calc(1em + " + styles.margin + "%); }"
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
    }
}
