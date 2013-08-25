/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Popups 0.1
import org.nemomobile.folderlistmodel 1.0
import Epub 1.0


Page {
    id: localBooks
    visible: false
    title: i18n.tr("Books")
    property int sort: 0
    property bool needsort: false
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
            tx.executeSql("INSERT OR IGNORE INTO LocalBooks(filename, title, author, cover, lastread)" +
                          " VALUES(?, ?, 'zzznull', 'ZZZnone', datetime('now'))", [filePath, fileToTitle(fileName)])
        })
    }
    
    function listBooks() {
        var sort = ["lastread DESC, title ASC", "title ASC", "author ASC, title ASC"][localBooks.sort]
        if (sort === undefined) {
            console.log("Error: Undefined sorting: " + localBooks.sort)
            return
        }
        
        bookModel.clear()
        var db = openDatabase()
        db.readTransaction(function (tx) {
            var res = tx.executeSql("SELECT filename, title, author, cover FROM LocalBooks " +
                                    "ORDER BY " + sort);
            for (var i=0; i<res.rows.length; i++) {
                var item = res.rows.item(i)
                if (filereader.exists(item.filename))
                    // For some reason, we need to explicitly call toString on the cover.
                    bookModel.append({filename: item.filename, title: item.title,
                                      author: item.author, cover: item.cover.toString()})
            }
        })
        localBooks.needsort = false
    }
    
    function updateRead(filename) {
        var db = openDatabase()
        db.transaction(function (tx) {
            tx.executeSql("UPDATE OR IGNORE LocalBooks SET lastread=datetime('now') WHERE filename=?",
                          [filename])
        })
        if (localBooks.sort == 0)
            listBooks()
    }

    function updateBookCover() {
        var db = openDatabase()
        db.transaction(function (tx) {
            var res = tx.executeSql("SELECT filename, title FROM LocalBooks WHERE author == 'zzznull'")
            if (res.rows.length == 0)
                return

            localBooks.needsort = true
            var title, author, cover
            if (coverReader.load(res.rows.item(0).filename)) {
                var coverinfo = coverReader.getCoverInfo(units.gu(1))
                title = coverinfo.title
                if (title == "ZZZnone")
                    title = res.rows.item(0).title
                author = coverinfo.author
                cover = coverinfo.cover
            } else {
                title = res.rows.item(0).title
                author = "zzzzerror" + i18n.tr("Could not open this book.")
                cover = "ZZZerror"
            }
            tx.executeSql("UPDATE LocalBooks SET title=?, author=?, cover=? WHERE filename=?",
                          [title, author, cover, res.rows.item(0).filename])
            coverTimer.start()
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

    // If we need to resort, do it when hiding or showing this page
    onVisibleChanged: {
        if (needsort)
            listBooks()
        // If we are viewing recently read, then the book we had been reading is now at the top
        if (visible && sort == 0)
            listview.positionViewAtBeginning()
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
                    localBooks.addFile(filePath, fileName)
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
            localBooks.listBooks()
            coverTimer.start()
        }
    }

    EpubReader {
        id: coverReader
    }

    Timer {
        id: coverTimer
        interval: 1000
        repeat: false
        running: false
        triggeredOnStart: false

        onTriggered: localBooks.updateBookCover()
    }
    
    ListModel {
        id: bookModel
    }
    
    ListView {
        id: listview
        anchors.fill: parent
        
        model: bookModel
        delegate: Subtitled {
            text: model.title
            subText: {
                if (model.author == "zzznull" || model.author == "zzznone")
                    return ""
                if (model.author.match(/^zzzzerror/))
                    return model.author.slice(9)
                return model.author
            }
            icon: {
                if (model.cover == "ZZZnone")
                    return Qt.resolvedUrl("images/default_cover.png")
                if (model.cover == "ZZZerror")
                    return Qt.resolvedUrl("images/error_cover.png")
                return model.cover
            }
            iconFrame: true
            progression: true
            onClicked: loadFile(model.filename)
        }
    }
    
    tools: ToolbarItems {
        id: localBooksToolbar
        
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
                selected: action.sort == localBooks.sort
                onTriggered: {
                    localBooks.sort = action.sort
                    PopupUtils.close(sortPopover)
                    localBooksToolbar.opened = false
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
