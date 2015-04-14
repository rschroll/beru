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
    property int sort: 0
    property bool needsort: false
    property bool firststart: false
    property double gridmargin: units.gu(1)
    property double mingridwidth: units.gu(15)
    
    function onFirstStart(db) {
        db.changeVersion(db.version, "1")
        noBooksLabel.text = i18n.tr("Welcome to Beru")
        firststart = true
    }

    function openDatabase() {
        return LocalStorage.openDatabaseSync("BeruLocalBooks", "", "Books on the local device",
                                             1000000, onFirstStart);
    }

    function listBooks() {
        // We only need to GROUP BY in the author sort, but this lets us use the same
        // SQL logic for all three cases.
        var sort = ["GROUP BY filename ORDER BY lastread DESC, title ASC",
                    "GROUP BY filename ORDER BY title ASC",
                    "GROUP BY authorsort ORDER BY authorsort ASC"][localBooks.sort]
        if (sort === undefined) {
            console.log("Error: Undefined sorting: " + localBooks.sort)
            return
        }

        bookModel.clear()
        var db = openDatabase()
        db.readTransaction(function (tx) {
            var res = tx.executeSql("SELECT filename, title, author, cover, fullcover, authorsort, count(*) " +
                                    "FROM LocalBooks " + sort)
            for (var i=0; i<res.rows.length; i++) {
                var item = res.rows.item(i)
                if (filesystem.exists(item.filename))
                    bookModel.append({filename: item.filename, title: item.title,
                                      author: item.author, cover: item.cover, fullcover: item.fullcover,
                                      authorsort: item.authorsort, count: item["count(*)"]})
            }
        })
        localBooks.needsort = false
    }

    function readBookDir() {
        listBooks()
    }

    Component.onCompleted: {
        console.log("  !! component completed")
        var db = openDatabase()
        db.transaction(function (tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS LocalBooks(filename TEXT UNIQUE, " +
                          "title TEXT, author TEXT, cover BLOB, lastread TEXT)")
        })
        // NOTE: db.version is not updated live!  We will get the change only the next time
        // we run, so here we must keep track of what's been happening.  onFirstStart() has
        // already run, so we're at version 1, even if db.version is empty.
        if (db.version == "" || db.version == "1") {
            db.changeVersion(db.version, "2", function (tx) {
                tx.executeSql("ALTER TABLE LocalBooks ADD authorsort TEXT NOT NULL DEFAULT 'zzznull'")
            })
        }
        if (db.version == "" || db.version == "1" || db.version == "2") {
            db.changeVersion(db.version, "3", function (tx) {
                tx.executeSql("ALTER TABLE LocalBooks ADD fullcover BLOB DEFAULT ''")
                // Trigger re-rendering of covers.
                tx.executeSql("UPDATE LocalBooks SET authorsort='zzznull'")
            })
        }
        if (db.version == "" || db.version == "1" || db.version == "2" || db.version == "3") {
            db.changeVersion(db.version, "4", function (tx) {
                tx.executeSql("ALTER TABLE LocalBooks ADD hash TEXT DEFAULT ''")
                // Trigger re-evaluation to update hashes.
                tx.executeSql("UPDATE LocalBooks SET authorsort='zzznull'")
            })
        }
    }

    // We need to wait for main to be finished, so that the settings are available.
    function onMainCompleted() {
        console.log("  !! main completed")
        // readBookDir() will trigger the loading of all files in the default directory
        // into the library.
        readBookDir()
    }

    ListModel {
        id: bookModel
    }

    DefaultCover {
        id: defaultCover
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
                    source: {
                        if (model.cover == "ZZZerror")
                            return defaultCover.errorCover(model)
                        if (!model.fullcover)
                            return defaultCover.missingCover(model)
                        return model.fullcover
                    }
                    // Prevent blurry SVGs
                    sourceSize.width: 2*localBooks.mingridwidth
                    sourceSize.height: 3*localBooks.mingridwidth

                    Text {
                        x: ((model.cover == "ZZZerror") ? 0.09375 : 0.125)*parent.width
                        y: 0.0625*parent.width
                        width: 0.8125*parent.width
                        height: parent.height/2 - 0.125*parent.width
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.Wrap
                        elide: Text.ElideRight
                        color: defaultCover.textColor(model)
                        style: Text.Raised
                        styleColor: defaultCover.highlightColor(model, defaultCover.hue(model))
                        font.family: "URW Bookman L"
                        text: {
                            if (!model.fullcover)
                                return model.title
                            return ""
                        }
                    }

                    Text {
                        x: ((model.cover == "ZZZerror") ? 0.09375 : 0.125)*parent.width
                        y: parent.height/2 + 0.0625*parent.width
                        width: 0.8125*parent.width
                        height: parent.height/2 - 0.125*parent.width
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.Wrap
                        elide: Text.ElideRight
                        color: defaultCover.textColor(model)
                        style: Text.Raised
                        styleColor: defaultCover.highlightColor(model, defaultCover.hue(model))
                        font.family: "URW Bookman L"
                        text: {
                            if (!model.fullcover)
                                return model.author
                            return ""
                        }
                    }
                }
            }

            DropShadow {
                anchors.fill: image
                radius: 1.5*gridmargin
                samples: 16
                source: image
                color: "#808080"
                verticalOffset: 0.25*gridmargin
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    // Save copies now, since these get cleared by loadFile (somehow...)
                    var filename = model.filename
                    var pasterror = model.cover == "ZZZerror"
                    if (loadFile(filename) && pasterror)
                        refreshCover(filename)
                }
                onPressAndHold: openInfoDialog(model)
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
