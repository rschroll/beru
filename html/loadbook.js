// Load the XML file at path from the sever, and then call the callback with
// the XML document as the argument.
function loadXMLComponent(path, callback) {
    var request = new XMLHttpRequest();
    console.log(document.location.href + path)
    request.open("GET", document.location.href + path);
    request.onload = function () {
        console.log("Callback")
        callback(request.responseXML);
    }
    request.send();
}

// Get the directory portion of path.  The path separator is '/', for
// use with zip files.
function getDir(path) {
    return path.split('/').slice(0,-1).join('/');
}

// Join and normalize the two paths.  The path separator is '/', for use
// with zip files.
function joinPaths(path1, path2) {
    var path = path1.split('/').concat(path2.split('/')),
        normpath = [];
    for (var i in path) {
        var dir = path[i];
        if (dir == "..")
            normpath.pop();
        else if (dir != "." && dir != "")
            normpath.push(dir);
    }
    return normpath.join('/');
}

// A book data object for the Epub file 'epubfile', a HTML5 File object.
// The callback will be called when this object is fully initialized,
// with this object as an argument.
function Epub(callback) {
    var files = {};      // Maps filename to zip.Entry
    var spine = [];      // List of filenames in spine
    var contents = [];   // Table of contents
    var metadata = {};   // Maps keys to metadata

    // This starts a chain of callbacks, eventually ending with onLoaded
    loadXMLComponent("META-INF/container.xml", function (doc) {
        var opffn = doc.getElementsByTagName("rootfile")[0].getAttribute("full-path");
        loadXMLComponent(opffn, parseOPF(getDir(opffn)));
    });

    // Parse the OPF file to get the spine, the table of contents, and
    // the metadata.
    parseOPF = function (reldir) {
        return function (doc) {
            var idmap = {};
            var nav_href = null;

            // Parse manifest
            var manifest = doc.getElementsByTagName("manifest")[0];
            var items = manifest.getElementsByTagName("item");
            for (var i=0; i<items.length; i++) {
                item = items[i];
                var id = item.getAttribute("id");
                var href = item.getAttribute("href");
                idmap[id] = joinPaths(reldir, href);
                var props = item.getAttribute("properties")
                if (props != null && props.split(" ").indexOf("nav") > -1)
                    nav_href = idmap[id];
            }

            // Parse spine
            var spineel = doc.getElementsByTagName("spine")[0];
            var sitems = spineel.getElementsByTagName("itemref");
            for (var i=0; i<sitems.length; i++) {
                id = sitems[i].getAttribute("idref");
                spine.push(idmap[id]);
            }

            // Parse metadata
            var metadatael = doc.getElementsByTagName("metadata")[0];
            for (var i=0; i<metadatael.childNodes.length; i++) {
                var node = metadatael.childNodes[i];
                if (node.nodeType == 1 && node.firstChild != null)
                    metadata[node.localName] = node.firstChild.nodeValue;
            }

            // Parse table of contents
            if (nav_href != null) {  // Epub3 navigation
                loadXMLComponent(nav_href, parseNav(getDir(nav_href)));
            } else {  // Epub2 navigation
                var ncxfile = idmap[spineel.getAttribute("toc")];
                if (ncxfile != undefined)
                    loadXMLComponent(ncxfile, parseNCX(getDir(ncxfile)));
            }
        };
    };

    // Parse the Epub3 table of contents.
    parseNav = function (reldir) {
        return function (navdoc) {
            var navs = navdoc.getElementsByTagName("nav");
            for (var i=0; i<navs.length; i++) {
                var nav = navs[i];
                if (nav.getAttribute("epub:type") == "toc")
                    contents = self.parseNavList(nav.getElementsByTagName("ol")[0], reldir);
            }
            onLoaded();
        };
    };

    parseNavList = function (element, reldir) {
        var children = [];
        for (var i=0; i<element.childNodes.length; i++) {
            var node = element.childNodes[i];
            if (node.nodeType == 1 && node.nodeName == "li") {
                var link = node.getElementsByTagName("a")[0];
                if (link != undefined) {
                    var child = { title: link.firstChild.nodeValue,
                                  src: joinPaths(reldir, link.getAttribute("href")) };
                    var olist = node.getElementsByTagName("ol")[0];
                    if (olist != undefined)
                        child["children"] = parseNavList(olist, reldir);
                    children.push(child);
                }
            }
        }
        return children;
    };

    // Parse the Epub2 table of contents.
    parseNCX = function (reldir) {
        return function (ncx) {
            var navmap = ncx.getElementsByTagName("navMap")[0];
            contents = self.parseNCXChildren(navmap, reldir);
            onLoaded();
        };
    };

    parseNCXChildren = function(element, reldir) {
        var children = [];
        for (var i=0; i<element.childNodes.length; i++) {
            var node = element.childNodes[i];
            if (node.nodeType == 1 && node.nodeName == "navPoint") {
                var child = {};
                var nav_label = node.getElementsByTagName("text")[0];
                child["title"] = nav_label.firstChild.nodeValue;
                var content = node.getElementsByTagName("content")[0];
                child["src"] = joinPaths(reldir, content.getAttribute("src"));
                var child_nav = parseNCXChildren(node, reldir);
                if (child_nav.length > 0)
                    child["children"] = child_nav;
                children.push(child);
            }
        }
        return children;
    };

    // Part of Monocle's book data object interface.
    getComponents = function () {
        return spine;
    };

    // Part of Monocle's book data object interface.
    getContents = function () {
        return contents;
    };

    // Part of Monocle's book data object interface.
    getComponent = function (component) {
        return { url: component };
    };

    // Part of Monocle's book data object interface.
    getMetaData = function (key) {
        return metadata[key];
    }

    // Called at the end of the initialization process.  At this point,
    // the object is ready to be passed to a Monocle.Reader.
    onLoaded = function () {
        callback(this);
    };
}
