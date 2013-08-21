/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import QtWebKit 3.0


Page {
    id: bookPage
    visible: false
    //flickable: null
    
    property alias url: bookWebView.url
    
    WebView {
        id: bookWebView
        anchors.fill: parent
        
        onTitleChanged: {
            var command = JSON.parse(title)
            if (command[0] == "ExternalLink")
                Qt.openUrlExternally(command[1])
            else
                console.log("Unknown command: " + command)
        }
    }
}
