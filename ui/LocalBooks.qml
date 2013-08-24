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


Page {
    id: localBooks
    visible: false
    title: i18n.tr("Books")
    property int sort: 0
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
            tx.executeSql("INSERT OR IGNORE INTO LocalBooks(filename, title, lastread)" +
                          " VALUES(?, ?, datetime('now'))", [filePath, fileToTitle(fileName)])
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
                if (filereader.exists(res.rows.item(i).filename))
                    bookModel.append(res.rows.item(i))
            }
        })
    }
    
    function updateRead(filename) {
        var db = openDatabase()
        db.transaction(function (tx) {
            tx.executeSql("UPDATE LocalBooks SET lastread=datetime('now') WHERE filename=?",
                          [filename])
        })
        if (localBooks.sort == 0)
            listBooks()
    }
    
    Component.onCompleted: {
        var db = openDatabase()
        db.transaction(function (tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS LocalBooks(filename TEXT UNIQUE, " +
                          "title TEXT, author TEXT, cover BLOB, lastread TEXT)")
        })
        loadTimer.start()
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
        
        onTriggered: localBooks.listBooks()
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
            subText: model.author || ""
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
