/* Copyright 2013-2014 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

import QtQuick 2.0
import Ubuntu.Components 1.1

import "sqlout.js" as Res

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

    property double gridmargin: units.gu(1)
    property double mingridwidth: units.gu(15)

    PageStack {
        id: pageStack
        Component.onCompleted: {
            push(localBooks)
            localBooks.listBooks()
        }

        Page {
            id: localBooks
            visible: false
            title: "Library"
            flickable: gridview

            function listBooks() {
                bookModel.clear()
                for (var i=0; i<Res.rows.length; i++) {
                    var item = Res.rows[i]
                    bookModel.append({fullcover: item.fullcover})
                }
            }

            ListModel {
                id: bookModel
            }

            Component {
                id: coverDelegate
                Image {
                    width: gridview.cellWidth
                    height: gridview.cellHeight

                    fillMode: Image.PreserveAspectFit
                    source: model.fullcover
                    // Prevent blurry SVGs
                    sourceSize.width: 2*localBooks.mingridwidth
                    sourceSize.height: 3*localBooks.mingridwidth
                }
            }

            GridView {
                id: gridview
                anchors {
                    // Setting fill: parent leads to binding loop; see #17
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    leftMargin: gridmargin
                    rightMargin: gridmargin
                }
                height: mainView.height
                clip: true
                cellWidth: width / Math.floor(width/mingridwidth)
                cellHeight: cellWidth*1.5

                model: bookModel
                delegate: coverDelegate
            }

            head {
                sections {
                    model: ["Recently Read", "Title", "Author"]
                }
            }
        }
    }
}
