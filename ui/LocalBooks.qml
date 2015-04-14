/* Copyright 2013-2014 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import QtGraphicalEffects 1.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0
import Ubuntu.Components.Popups 1.0

import "components"


Page {
    id: localBooks
    title: i18n.tr("Library")
    flickable: gridview
    property double gridmargin: units.gu(1)
    property double mingridwidth: units.gu(15)

    function openDatabase() {
        return LocalStorage.openDatabaseSync("BeruLocalBooks", "", "Books on the local device",
                                             1000000);
    }

    function listBooks() {
        bookModel.clear()
        var db = openDatabase()
        db.readTransaction(function (tx) {
            var res = tx.executeSql("SELECT filename, title, author, cover, fullcover, authorsort, count(*) " +
                                    "FROM LocalBooks GROUP BY filename ORDER BY lastread DESC, title ASC")
            for (var i=0; i<res.rows.length; i++) {
                var item = res.rows.item(i)
                if (filesystem.exists(item.filename))
                    bookModel.append({filename: item.filename, title: item.title,
                                      author: item.author, cover: item.cover, fullcover: item.fullcover,
                                      authorsort: item.authorsort, count: item["count(*)"]})
            }
        })
    }

    // We need to wait for main to be finished, so that the settings are available.
    function onMainCompleted() {
        listBooks()
    }

    ListModel {
        id: bookModel
    }

    Component {
        id: coverDelegate
        Item {
            width: gridview.cellWidth
            height: gridview.cellHeight

            Item {
                id: image
                anchors.fill: parent

                Image {
                    anchors {
                        fill: parent
                        leftMargin: gridmargin
                        rightMargin: gridmargin
                        topMargin: 1.5*gridmargin
                        bottomMargin: 1.5*gridmargin
                    }
                    fillMode: Image.PreserveAspectFit
                    source: model.fullcover
                    // Prevent blurry SVGs
                    sourceSize.width: 2*localBooks.mingridwidth
                    sourceSize.height: 3*localBooks.mingridwidth
                }
            }
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
            model: [i18n.tr("Recently Read"), i18n.tr("Title"), i18n.tr("Author")]
        }
    }
}
