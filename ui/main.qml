import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1
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
    
    width: units.gu(100)
    height: units.gu(75)

    PageStack {
        id: pageStack
        Component.onCompleted: push(listpage)

        Page {
            id: listpage
            visible: false
            title: i18n.tr("Books")

            ListView {
                id: listview
                anchors.fill: parent

                FolderListModel {
                    id: folderScannerModel
                    //readsMediaMetadata: true
                    isRecursive: true
                    showDirectories: true
                    filterDirectories: false
                    path: homePath() + "/Books"
                    nameFilters: ["*.epub"] // file types supported.
                }

                FileReader {
                    id: filereader
                }

                model: folderScannerModel
                delegate: Subtitled {
                    text: model.fileName
                    subText: model.filePath
                    progression: true
                    onClicked: {
                        var file = filereader.read_b64(model.filePath)
                        server.zipfile = new JsZip.JSZip(file, {base64: true})
                        webview.url = "http://127.0.0.1:5000"
                        pageStack.push(webviewpage, {contents: server.zipfile.file("mimetype").asText()})
                    }
                }
            }
        }

        Page {
            id: webviewpage
            visible: false

            property var contents

            WebView {
                id: webview
                anchors {
                    fill: parent
                    margins: units.gu(2)
                }
            }

            HttpServer {
                id: server
                Component.onCompleted: listen("127.0.0.1", 5000)

                property var zipfile

                function index(response) {
                    var files = zipfile.file(/.*/)
                    response.setHeader("Content-Type", "text/html")
                    response.writeHead(200)
                    response.write("<html><body><ul>")
                    for (var i=0; i<files.length; i++) {
                        response.write("<li><a href='" + files[i].name + "'>" +
                                       files[i].name + "</a></li>")
                    }
                    response.write("</ul></body></html>")
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
                        return index(response)

                    return component(request.path, response)
                }
            }
        }
    }
}
