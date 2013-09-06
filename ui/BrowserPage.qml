/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import QtWebKit 3.0
import QtWebKit.experimental 1.0

Page {
    id: browserPage
    property var url
    onUrlChanged: webViewLoader.item.url = url
    property alias showAddressBar: addressBar.visible
    //flickable: webViewLoader

    Item {
        id: addressBar
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: visible ? goButton.height + units.gu(2) : 0

        TextField {
            id: addressField
            placeholderText: i18n.tr("Enter URL")
            anchors {
                margins: units.gu(1)
                left: parent.left
                right: goButton.left
                verticalCenter: parent.verticalCenter
            }
        }

        Button {
            id: goButton
            text: i18n.tr("Go")
            anchors {
                margins: units.gu(1)
                top: parent.top
                right: parent.right
            }
            onClicked: webViewLoader.item.url = addressField.text
        }
    }

    Loader {
        id: webViewLoader
        //anchors.fill: parent
        anchors {
            top: addressBar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        source: "components/UbuntuWebView.qml"

        onStatusChanged: {
            if (status == Loader.Error)
                sourceComponent = basicWebView
            else if (status == Loader.Ready)
                load()
        }

        Component {
            id: basicWebView
            WebView {}
        }

        Connections {
            id: download
            ignoreUnknownSignals: true
            property real fraction
            property bool done
            onTotalBytesReceivedChanged: {
                fraction = target.totalBytesReceived / target.expectedContentLength
            }
            onSucceeded: {
                done = true
                localBooks.addFile(target.destinationPath, true)
            }
        }

        function load() {
            item.onUrlChanged.connect(function () {
                addressField.text = item.url
            })
            item.experimental.onDownloadRequested.connect(function (downloadItem) {
                download.done = false
                download.target = downloadItem

                // Check if ~/Books exists; try to make it if possible.  If not fall back to
                // XDG_DATA_HOME.  See https://lists.launchpad.net/ubuntu-phone/msg03861.html
                var dir = filereader.getDataDir("Books")
                if (dir == "") {
                    PopupUtils.open(errorComponent)
                    return
                }
                var addText = ""
                if (dir != filereader.homePath() + "/Books")
                    var addText = i18n.tr("\n\nNote: Beru would prefer to download ebooks to " +
                                          "~/Books, but it is unable to do so because that directory " +
                                          "does not exist or is not writable.  If you are able to " +
                                          "fix this manually, Beru will use it in the future.")
                dir += "/"

                var components = downloadItem.suggestedFilename.split("/").pop().split(".")
                var ext = components.pop()
                var basename = components.join(".")
                var filename = basename + "." + ext
                var i = 0
                while (filereader.exists(dir + filename)) {
                    i += 1
                    filename = basename + "(" + i + ")." + ext
                }
                downloadItem.destinationPath = dir + filename

                var downloadargs = {
                    text: i18n.tr("Beru is downloading the ebook to %1.\n\n" +
                                  "This book will be added to your library as soon as the " +
                                  "download is complete.").arg(dir + filename) + addText
                }
                if (ext != "epub")
                    PopupUtils.open(extensionWarning, browserPage, {downloadargs: downloadargs,
                                        text: i18n.tr("This file, %1, may not be an Epub file.  " +
                                                      "If it is not, Beru will not be able to " +
                                                      "read it.").arg(filename)})
                else
                    PopupUtils.open(downloadComponent, browserPage, downloadargs)
            })
        }
    }

    Component {
        id: downloadComponent

        Dialog {
            id: downloadDialog
            title: i18n.tr("Downloading Ebook")

            ProgressBar {
                id: downloadProgress
                value: download.fraction
            }

            Button {
                id: openFileButton
                visible: false
                text: i18n.tr("Read book")
                onClicked: {
                    PopupUtils.close(downloadDialog)
                    pageStack.pop()
                    loadFile(download.target.destinationPath)
                }
            }

            Button {
                text: i18n.tr("Continue Browsing")
                onClicked: PopupUtils.close(downloadDialog)
            }

            Component.onCompleted: {
                // Can't connect to download.onSucceeded for some reason.
                download.onDoneChanged.connect(function () {
                    if (download.done) {
                        downloadProgress.visible = false
                        openFileButton.visible = true
                    }
                })
                download.target.start()
            }
        }
    }

    Component {
        id: extensionWarning

        Dialog {
            id: extensionDialog
            title: i18n.tr("Possibly Incompatible File Type")

            property var downloadargs

            Button {
                text: i18n.tr("Cancel Download")
                onClicked: PopupUtils.close(extensionDialog)
            }

            Button {
                text: i18n.tr("Continue Download")
                onClicked: {
                    PopupUtils.close(extensionDialog)
                    PopupUtils.open(downloadComponent, browserPage, downloadargs)
                }
            }
        }
    }

    Component {
        id: errorComponent

        Dialog {
            id: errorDialog
            title: i18n.tr("Download Error")
            text: i18n.tr("Beru was unable to find a place where the ebook could be saved.  " +
                          "This shouldn't ever happen; please submit a bug at " +
                          "github.com/rschroll/beru/issues")

            Button {
                text: i18n.tr("What a Bummer!")
                onClicked: PopupUtils.close(errorDialog)
            }
        }
    }

    tools: ToolbarItems {
        id: browserPageToolbar

        ToolbarButton {
            id: backButton
            enabled: webViewLoader.item.canGoBack
            action: Action {
                text: i18n.tr("Back")
                iconSource: mobileIcon("go-previous")
                onTriggered: webViewLoader.item.goBack()
            }
        }

        ToolbarButton {
            id: forwardButton
            enabled: webViewLoader.item.canGoForward
            action: Action {
                text: i18n.tr("Forward")
                iconSource: mobileIcon("go-next")
                onTriggered: webViewLoader.item.goForward()
            }
        }
    }
}
