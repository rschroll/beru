import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1
import QtWebKit 3.0
import org.nemomobile.folderlistmodel 1.0

import File 1.0
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
                        var zipfile = new JsZip.JSZip()
                        zipfile.load(file, {base64: true})
                        pageStack.push(webviewpage, {contents: zipfile.file("mimetype").asText()})
                    }
                }
            }
        }

        Page {
            id: webviewpage
            visible: false

            property var contents
            onContentsChanged: {
                webview.loadHtml("<br><br><br><br>" + contents)
            }

            WebView {
                id: webview
                anchors {
                    fill: parent
                    margins: units.gu(2)
                }
            }
        }
    }
}
