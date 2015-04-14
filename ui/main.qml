/* Copyright 2013-2014 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

import QtQuick 2.0
import Ubuntu.Components 1.1
import File 1.0


MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"
    id: mainView
    
    applicationName: "com.ubuntu.developer.rschroll.beru"
    
    /* 
     This property enables the application to change orientation 
     when the device is rotated. The default is false.
    */
    automaticOrientation: true

    useDeprecatedToolbar: false
    
    width: units.gu(50)
    height: units.gu(75)

    FileSystem {
        id: filesystem
    }

    PageStack {
        id: pageStack
        Component.onCompleted: push(localBooks)
        onCurrentPageChanged: currentPage.forceActiveFocus()


        LocalBooks {
            id: localBooks
            visible: false
        }
    }

    Component.onCompleted: {
        localBooks.onMainCompleted()
    }
}
