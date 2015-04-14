/* Copyright 2013-2014 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import QtQuick.Window 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import U1db 1.0 as U1db
import File 1.0

import "components"


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

    function getSetting(key) {
        console.log("  !!  getSettings " + key)
        return undefined
    }

    function setSetting(key, value) {
        console.log("  !!  setSettings " + key)
    }

    function getBookSetting(key) {
        console.log("  !!  getBookSettings " + key)
        return undefined
    }

    function setBookSetting(key, value) {
        console.log("  !!  setBookSettings " + key)
    }

    Component.onCompleted: {
        localBooks.onMainCompleted()
    }
}
