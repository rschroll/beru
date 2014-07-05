/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.Extras.Browser 0.1

Page {
    id: browserPage
    property var url
    onUrlChanged: webView.url = url
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
            onClicked: webView.url = addressField.text
        }
    }

    UbuntuWebView {
        id: webView
        //anchors.fill: parent
        anchors {
            top: addressBar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
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

        onUrlChanged: addressField.text = url

        onLoadingChanged: loadProgressBar.visible = loading

        onLoadProgressChanged: loadProgressBar.value = loadProgress

        experimental.onDownloadRequested: {
            download.done = false
            download.target = downloadItem

            var dir = localBooks.bookdir
            if (dir == "") {
                PopupUtils.open(errorComponent)
                return
            }
            dir += "/"

            var components = downloadItem.suggestedFilename.split("/").pop().split(".")
            var ext = components.pop()
            var basename = components.join(".")
            var filename = basename + "." + ext
            var i = 0
            while (filesystem.exists(dir + filename)) {
                i += 1
                filename = basename + "(" + i + ")." + ext
            }
            downloadItem.destinationPath = dir + filename

            var downloadargs = {
                text: i18n.tr("This book will be added to your library as soon as the " +
                              "download is complete."),
                details: i18n.tr("This book is being saved as <i>%1</i>").arg(dir + filename)
            }
            if (ext != "epub")
                PopupUtils.open(extensionWarning, browserPage, {downloadargs: downloadargs,
                                    text: i18n.tr("This file, <i>%1</i>, may not be an Epub file.  " +
                                                  "If it is not, Beru will not be able to " +
                                                  "read it.").arg(filename)})
            else
                PopupUtils.open(downloadComponent, browserPage, downloadargs)
        }
    }

    ProgressBar {
        id: loadProgressBar
        minimumValue: 0
        maximumValue: 100
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: units.gu(2)
        visible: false
    }

    Component {
        id: downloadComponent

        Dialog {
            id: downloadDialog
            title: i18n.tr("Downloading Ebook")
            property string details

            UbuntuShape {
                height: detailsLabel.height + units.gu(4)
                        + (expanded ? moreDetailsLabel.height + units.gu(2) : 0 )
                clip: true
                property bool expanded: false

                Behavior on height {
                    UbuntuNumberAnimation {}
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: parent.expanded = !parent.expanded
                }

                Label {
                    id: detailsLabel
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        leftMargin: units.gu(3)
                        rightMargin: units.gu(3)
                        topMargin: units.gu(2)
                    }
                    text: "Details"
                }

                Image {
                    width: units.gu(2)
                    height: units.gu(2)
                    rotation: parent.expanded ? -90 : 90
                    source: mobileIcon("go-to")
                    anchors {
                        right: parent.right
                        rightMargin: units.gu(3)
                        verticalCenter: detailsLabel.verticalCenter
                    }

                    Behavior on rotation {
                        UbuntuNumberAnimation {}
                    }
                }

                Label {
                    id: moreDetailsLabel
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: detailsLabel.bottom
                        leftMargin: units.gu(3)
                        rightMargin: units.gu(3)
                        topMargin: units.gu(2)
                    }
                    text: downloadDialog.details
                    fontSize: "small"
                    wrapMode: Text.Wrap
                }
            }

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

        back: ToolbarButton {
            action: Action {
                text: i18n.tr("Library")
                iconSource: mobileIcon("back")
                onTriggered: pageStack.pop()
            }
        }

        ToolbarButton {
            id: backButton
            action: Action {
                text: i18n.tr("Back")
                iconSource: mobileIcon("go-previous")
                enabled: webView.canGoBack
                onTriggered: webView.goBack()
            }
        }

        ToolbarButton {
            id: forwardButton
            action: Action {
                text: i18n.tr("Forward")
                iconSource: mobileIcon("go-next")
                enabled: webView.canGoForward
                onTriggered: webView.goForward()
            }
        }
    }
}
