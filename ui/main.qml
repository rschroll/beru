/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import File 1.0


MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"
    id: mainView
    
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

    Component {
        id: errorOpen
        Dialog {
            id: errorOpenDialog
            title: i18n.tr("Error Opening File")
            text: i18n.tr("Beru could not open this file.\n\n" +
                          "Remember, Beru can only open Epub files without DRM.")
            Button {
                text: i18n.tr("OK")
                onClicked: PopupUtils.close(errorOpenDialog)
            }
        }
    }

    Server {
        id: server
    }

    function loadFile(filename) {
        if (server.loadFile(filename)) {
            pageStack.push(bookPage, {url: "http://127.0.0.1:" + server.port})
            localBooks.updateRead(filename)
            return true
        }
        PopupUtils.open(errorOpen)
        return false
    }

    function mobileIcon(name) {
        return "/usr/share/icons/ubuntu-mobile/actions/scalable/" + name + ".svg"
    }

    Arguments {
        id: args

        Argument {
            name: "appargs"
            required: true
            valueNames: ["APP_ARGS"]
        }
    }

    Component.onCompleted: {
        var filePath = filereader.canonicalFilePath(args.values.appargs)
        if (filePath !== "") {
            var fileName = filePath.split("/").pop()
            if (loadFile(filePath))
                localBooks.addFile(filePath, fileName)
        }
    }
}
