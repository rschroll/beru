/* Copyright 2013-2014 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.Extras.Browser 0.2
import Ubuntu.DownloadManager 0.1

import "components"


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

        StyledButton {
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

        onUrlChanged: addressField.text = url

        onLoadingChanged: loadProgressBar.visible = loading

        onLoadProgressChanged: loadProgressBar.value = loadProgress

        onDownloadRequested: {
            var downloadargs = {
                text: i18n.tr("This book will be added to your library as soon as the " +
                              "download is complete."),
                url: request.url
            }
            if (request.mimeType != "application/epub+zip") {
                var filename = request.url.toString().split("/").pop()
                PopupUtils.open(extensionWarning, browserPage, {downloadargs: downloadargs,
                                    // A path on the file system. //
                                    text: i18n.tr("This file, <i>%1</i>, may not be an Epub file.  " +
                                                  "If it is not, Beru will not be able to " +
                                                  "read it.").arg(filename)})
            } else {
                PopupUtils.open(downloadComponent, browserPage, downloadargs)
            }
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
            property string url


            SingleDownload {
                id: download
                onFinished: {
                    localBooks.addFile(path, true)
                    downloadProgress.visible = false
                    /*/ A path on the file system. /*/
                    downloadDialog.details = i18n.tr("This book was saved as <i>%1</i>").arg(path)
                    detailsShape.visible = true
                    openFileButton.path = path
                    openFileButton.visible = true
                }
            }

            ProgressBar {
                id: downloadProgress
                value: download.progress/100
            }

            StyledButton {
                id: openFileButton
                visible: false
                text: i18n.tr("Read book")
                property string path
                onClicked: {
                    PopupUtils.close(downloadDialog)
                    pageStack.pop()
                    loadFile(path)
                }
            }

            UbuntuShape {
                id: detailsShape
                visible: false
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
                    text: i18n.tr("Details")
                }

                Image {
                    width: units.gu(2)
                    height: units.gu(2)
                    rotation: parent.expanded ? -90 : 90
                    source: "image://theme/go-to"
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

            StyledButton {
                text: i18n.tr("Continue Browsing")
                onClicked: PopupUtils.close(downloadDialog)
            }

            Component.onCompleted: {
                download.download(url)
            }
        }
    }

    Component {
        id: extensionWarning

        Dialog {
            id: extensionDialog
            title: i18n.tr("Possibly Incompatible File Type")

            property var downloadargs

            StyledButton {
                text: i18n.tr("Cancel Download")
                onClicked: PopupUtils.close(extensionDialog)
            }

            StyledButton {
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

            StyledButton {
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
                iconName: "back"
                onTriggered: pageStack.pop()
            }
        }

        ToolbarButton {
            id: backButton
            action: Action {
                text: i18n.tr("Back")
                iconName: "go-previous"
                enabled: webView.canGoBack
                onTriggered: webView.goBack()
            }
        }

        ToolbarButton {
            id: forwardButton
            action: Action {
                text: i18n.tr("Forward")
                iconName: "go-next"
                enabled: webView.canGoForward
                onTriggered: webView.goForward()
            }
        }
    }
}
