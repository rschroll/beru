/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL license. See the file COPYING for full details.
 */

import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Popups 0.1
import QtWebKit 3.0
import org.nemomobile.folderlistmodel 1.0

import File 1.0
import HttpServer 1.0
import "../jszip/jszip.js" as JsZip


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

    PageStack {
        id: pageStack
        Component.onCompleted: push(listpage)

        Page {
            id: listpage
            visible: false
            title: i18n.tr("Books")
            property int sort: 0
            onSortChanged: listBooks()

            function openDatabase() {
                return LocalStorage.openDatabaseSync("BeruLocalBooks", "1", "Books on the local device", 1000000)
            }

            function fileToTitle(filename) {
                return filename.replace(/\.epub$/, "").replace(/_/g, " ")
            }

            function addFile(filePath, fileName) {
                var db = openDatabase()
                db.transaction(function (tx) {
                    // New items are given a lastread time of now, since these are probably
                    // interesting for a user to see.
                    tx.executeSql("INSERT OR IGNORE INTO LocalBooks(filename, title, lastread)" +
                                  " VALUES(?, ?, datetime('now'))", [filePath, fileToTitle(fileName)])
                })
            }

            function listBooks() {
                var sort = ["lastread DESC, title ASC", "title ASC", "author ASC, title ASC"][listpage.sort]
                if (sort === undefined) {
                    console.log("Error: Undefined sorting: " + listpage.sort)
                    return
                }

                bookModel.clear()
                var db = openDatabase()
                db.readTransaction(function (tx) {
                    var res = tx.executeSql("SELECT filename, title, author, cover FROM LocalBooks " +
                                            "ORDER BY " + sort);
                    for (var i=0; i<res.rows.length; i++) {
                        if (filereader.exists(res.rows.item(i).filename))
                            bookModel.append(res.rows.item(i))
                    }
                })
            }

            Component.onCompleted: {
                var db = openDatabase()
                db.transaction(function (tx) {
                    tx.executeSql("CREATE TABLE IF NOT EXISTS LocalBooks(filename TEXT UNIQUE, " +
                                  "title TEXT, author TEXT, cover BLOB, lastread TEXT)")
                })
                loadTimer.start()
            }

            // This will list all files in "~/Books"
            FolderListModel {
                id: folderModel
                //readsMediaMetadata: true
                isRecursive: true
                showDirectories: true
                filterDirectories: false
                path: homePath() + "/Books"
                nameFilters: ["*.epub"] // file types supported.
            }

            // We use the repeater to iterate through the folderModel
            Repeater {
                id: folderRepeater
                model: folderModel

                Component {
                    Item {
                        Component.onCompleted: {
                            loadTimer.stop()
                            listpage.addFile(filePath, fileName)
                            loadTimer.start()
                        }
                    }
                }
            }

            // When we're finished making sure all the files in ~/Books are
            // in the database, we read out the database into our ListModel.
            // This timer is to ensure that the loading runs only after all
            // those files have been checked.
            Timer {
                id: loadTimer
                interval: 100
                repeat: false
                running: false
                triggeredOnStart: false

                onTriggered: {
                    console.log("Timer expired")
                    listpage.listBooks()
                }
            }

            ListModel {
                id: bookModel
            }

            FileReader {
                id: filereader
            }

            ListView {
                id: listview
                anchors.fill: parent

                model: bookModel
                delegate: Subtitled {
                    text: model.title
                    subText: model.author || ""
                    progression: true
                    onClicked: {
                        var file = filereader.read_b64(model.filename)
                        server.zipfile = new JsZip.JSZip(file, {base64: true})
                        webview.url = "http://127.0.0.1:" + server.port
                        pageStack.push(webviewpage)
                    }
                }
            }

            tools: ToolbarItems {
                id: listpageToolbar

                ToolbarButton {
                    id: sortButton
                    action: Action {
                        text: i18n.tr("Sort")
                        iconSource: Qt.resolvedUrl("")
                        onTriggered: PopupUtils.open(sortComponent, sortButton)
                    }
                }
            }

            Component {
                id: sortComponent

                ActionSelectionPopover {
                    id: sortPopover

                    delegate: Standard {
                        text: action.text
                        selected: action.sort == listpage.sort
                        onTriggered: {
                            listpage.sort = action.sort
                            PopupUtils.close(sortPopover)
                            listpageToolbar.opened = false
                        }
                    }

                    actions: ActionList {
                        Action {
                            text: i18n.tr("Recently Read")
                            property int sort: 0
                        }
                        Action {
                            text: i18n.tr("Title")
                            property int sort: 1
                        }
                        Action {
                            text: i18n.tr("Author")
                            property int sort: 2
                        }
                    }
                }
            }
        }

        Page {
            id: webviewpage
            visible: false
            //flickable: null

            property var contents

            WebView {
                id: webview
                anchors.fill: parent

                onTitleChanged: {
                    var command = JSON.parse(title)
                    if (command[0] == "ExternalLink")
                        Qt.openUrlExternally(command[1])
                    else
                        console.log("Unknown command: " + command)
                }
            }

            HttpServer {
                id: server

                property int port: 5000

                Component.onCompleted: {
                    while (!listen("127.0.0.1", port))
                        port += 1
                }

                property var zipfile

                function static_file(path, response) {
                    var file = filereader.read_b64("html/" + path)
                    response.writeHead(200)
                    response.write_b64(file)
                    response.end()
                }

                function component(path, response) {
                    var file = zipfile.file(path.slice(1))
                    //response.setHeader("Content-Type", "text/plain")
                    response.writeHead(200)
                    response.write_b64(file.asBase64())
                    response.end()
                }

                onNewRequest: { // request, response
                    if (request.path == "/")
                        return static_file("index.html", response)
                    if (request.path[1] == ".")
                        return static_file(request.path.slice(2), response)
                    return component(request.path, response)
                }
            }
        }
    }
}
