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
    
    width: units.gu(50)
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
                        webview.url = "http://127.0.0.1:" + server.port
                        pageStack.push(webviewpage)
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
                    console.log(request.path)
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
