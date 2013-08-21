/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Popups 0.1
import QtWebKit 3.0
import QtWebKit.experimental 1.0

import "qmlmessaging.js" as Messaging


Page {
    id: bookPage
    visible: false
    //flickable: null
    
    property alias url: bookWebView.url

    ListModel {
        id: contentsListModel
    }
    
    WebView {
        id: bookWebView
        anchors.fill: parent
        
        onTitleChanged: Messaging.handleMessage(title)
    }

    tools: ToolbarItems {
        id: bookPageToolbar

        ToolbarButton {
            id: contentsButton
            action: Action {
                text: i18n.tr("Contents")
                iconSource: Qt.resolvedUrl("")
                onTriggered: PopupUtils.open(contentsComponent, contentsButton)
            }
        }
    }

    Component {
        id: contentsComponent

        Popover {
            id: contentsPopover

            ListView {
                id: contentsListView
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
                height: 0.8*bookPage.height

                model: contentsListModel
                delegate: Standard {
                    text: (new Array(model.level + 1)).join("    ") + model.title.replace("\n", "")
                    onClicked: {
                        Messaging.sendMessage("NavigateChapter", model.src)
                        PopupUtils.close(contentsPopover)
                        bookPageToolbar.opened = false
                    }
                }
            }
        }
    }

    function onExternalLink(href) {
        Qt.openUrlExternally(href)
    }

    function parseContents(contents, level) {
        if (level === undefined) {
            level = 0
            contentsListModel.clear()
        }
        for (var i in contents) {
            var chp = contents[i]
            chp.level = level
            contentsListModel.append(chp)
            if (chp.children !== undefined)
                parseContents(chp.children, level + 1)
        }
    }

    Component.onCompleted: {
        Messaging.registerHandler("ExternalLink", onExternalLink)
        Messaging.registerHandler("Contents", parseContents)
    }
}
