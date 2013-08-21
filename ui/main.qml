/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import File 1.0


MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"
    
    // Note! applicationName needs to match the .desktop filename
    applicationName: "beru"
    
    /* 
     This property enables the application to change orientation 
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true
    
    width: units.gu(50)
    height: units.gu(75)

    FileReader {
        id: filereader
    }

    PageStack {
        id: pageStack
        Component.onCompleted: push(localBooks)

        LocalBooks {
            id: localBooks
        }

        BookPage {
            id: bookPage
        }
    }

    Server {
        id: server
    }

    function loadFile(filename) {
        server.loadFile(filename)
        pageStack.push(bookPage, {url: "http://127.0.0.1:" + server.port})
        localBooks.updateRead(filename)
    }
}
