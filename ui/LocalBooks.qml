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
    title: i18n.tr("Books")
    flickable: listview
    property int sort: 0
    property bool needsort: false
    property bool firststart: false
    property bool wide: width >= units.gu(80)
    onSortChanged: {
        listBooks()
        perAuthorModel.clear()
        adjustViews(false)
    }
    onWidthChanged: {
        widthAnimation.enabled = false
        adjustViews(true)  // True to allow author's list if necessary
        widthAnimation.enabled = true
    }
    
    function onFirstStart(db) {
        db.changeVersion(db.version, "1")
        noBooksLabel.text = i18n.tr("Welcome to Beru")
    }

    function openDatabase() {
        return LocalStorage.openDatabaseSync("BeruLocalBooks", "", "Books on the local device",
                                             1000000, onFirstStart);
    }
    
    function fileToTitle(filename) {
        return filename.replace(/\.epub$/, "").replace(/_/g, " ")
    }
    
    // New items are given a lastread time of now, since these are probably
    // interesting for a user to see.
    property string addFileSQL: "INSERT OR IGNORE INTO LocalBooks(filename, title, author, authorsort, " +
                                "cover, lastread) VALUES(?, ?, '', 'zzznull', 'ZZZnone', datetime('now'))"

    function addFile(filePath, startCoverTimer) {
        var fileName = filePath.split("/").pop()
        var db = openDatabase()
        db.transaction(function (tx) {
            tx.executeSql(addFileSQL, [filePath, fileToTitle(fileName)])
        })
        localBooks.needsort = true
        if (startCoverTimer)
            coverTimer.start()
    }

    function addFolder() {
        var db = openDatabase()
        db.transaction(function (tx) {
            for (var i=0; i<folderRepeater.count; i++) {
                var item = folderRepeater.itemAt(i)
                tx.executeSql(addFileSQL, [item.filepath, fileToTitle(item.filename)])
            }
        })
        localBooks.needsort = true
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

        listview.delegate = (localBooks.sort == 2) ? authorDelegate : titleDelegate

        bookModel.clear()
        var db = openDatabase()
        db.readTransaction(function (tx) {
            var res = tx.executeSql("SELECT filename, title, author, cover, authorsort, count(*) " +
                                    "FROM LocalBooks " + sort)
            for (var i=0; i<res.rows.length; i++) {
                var item = res.rows.item(i)
                if (filereader.exists(item.filename))
                    bookModel.append({filename: item.filename, title: item.title,
                                      author: item.author, cover: item.cover,
                                      authorsort: item.authorsort, count: item["count(*)"]})
            }
        })
        localBooks.needsort = false
    }

    function listAuthorBooks(authorsort) {
        perAuthorModel.clear()
        var db = openDatabase()
        db.readTransaction(function (tx) {
            var res = tx.executeSql("SELECT filename, title, author, cover FROM LocalBooks " +
                                    "WHERE authorsort=? ORDER BY title ASC", [authorsort])
            for (var i=0; i<res.rows.length; i++) {
                var item = res.rows.item(i)
                if (filereader.exists(item.filename))
                    perAuthorModel.append({filename: item.filename, title: item.title,
                                           author: item.author, cover: item.cover})
            }
            perAuthorModel.append({filename: "ZZZback", title: i18n.tr("Back"),
                                   author: "", cover: ""})
        })
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
            var res = tx.executeSql("SELECT filename, title FROM LocalBooks WHERE authorsort == 'zzznull'")
            if (res.rows.length == 0)
                return

            localBooks.needsort = true
            var title, author, authorsort, cover
            if (coverReader.load(res.rows.item(0).filename)) {
                var coverinfo = coverReader.getCoverInfo(units.gu(1))
                title = coverinfo.title
                if (title == "ZZZnone")
                    title = res.rows.item(0).title

                author = coverinfo.author.trim()
                authorsort = coverinfo.authorsort.trim()
                if (authorsort == "zzznone" && author != "") {
                    // No sort information, so let's do our best to fix it:
                    authorsort = author
                    var lc = author.lastIndexOf(",")
                    if (lc == -1) {
                        // If no commas, assume "First Last"
                        var ls = author.lastIndexOf(" ")
                        if (ls > -1) {
                            authorsort = author.slice(ls + 1) + ", " + author.slice(0, ls)
                            authorsort = authorsort.trim()
                        }
                    } else if (author.indexOf(",") == lc) {
                        // If there is exactly one comma in the author, assume "Last, First".
                        // Thus, authorsort is correct and we have to fix author.
                        author = author.slice(lc + 1).trim() + " " + author.slice(0, lc).trim()
                    }
                }

                cover = coverinfo.cover
            } else {
                title = res.rows.item(0).title
                author = i18n.tr("Could not open this book.")
                authorsort = "zzzzerror"
                cover = "ZZZerror"
            }
            tx.executeSql("UPDATE LocalBooks SET title=?, author=?, authorsort=?, cover=? " +
                          "WHERE filename=?",
                          [title, author, authorsort, cover, res.rows.item(0).filename])

            if (localBooks.visible) {
                for (var i=0; i<bookModel.count; i++) {
                    var book = bookModel.get(i)
                    if (book.filename == res.rows.item(0).filename) {
                        book.title = title
                        book.author = author
                        book.cover = cover
                        break
                    }
                }
            }

            coverTimer.start()
        })
    }

    function setPath() {
        folderModel.path = filereader.getDataDir("Books")
    }

    function adjustViews(showAuthor) {
        if (sort != 2 || perAuthorModel.count == 0)
            showAuthor = false  // Don't need to show authors' list

        if (!wide || sort != 2) {
            listview.width = localBooks.width
            listview.x = showAuthor ? -localBooks.width : 0
            localBooks.flickable = showAuthor ? perAuthorListView : listview
        } else {
            localBooks.flickable = null
            listview.width = localBooks.width / 2
            listview.x = 0
            listview.topMargin = 0
            perAuthorListView.topMargin = 0
        }
    }
    
    Component.onCompleted: {
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

        // setPath() will trigger the loading of all files in the default directory
        // into the library.  Since this can cause a freeze, on the first start, we
        // throw up a dialog to hide it.  The dialog calls setPath once it's ready.
        setPath()
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
        isRecursive: true
        showDirectories: true
        filterDirectories: false
        nameFilters: ["*.epub"] // file types supported.
        onAwaitingResultsChanged: {
            if (!awaitingResults) {
                addFolder()
                listBooks()
                firststart = false
                coverTimer.start()
            }
        }
        onError: {
            // No folder (Should we try to create it?)
            // We can load the rest of the library anyway.
            listBooks()
            firststart = false
            coverTimer.start()
        }
    }
    
    // We use the repeater to iterate through the folderModel
    // The model is set after load, to avoid freezing the GUI
    Repeater {
        id: folderRepeater
        model: folderModel
        
        Component {
            Item {
                property var filepath: filePath
                property var filename: fileName
            }
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

    ListModel {
        id: perAuthorModel
        property bool needsclear: false
    }

    Component {
        id: titleDelegate
        Subtitled {
            text: model.title
            subText: model.author
            icon: {
                if (model.filename == "ZZZback")
                    return mobileIcon("back")
                if (model.cover == "ZZZnone")
                    return Qt.resolvedUrl("images/default_cover.svg")
                if (model.cover == "ZZZerror")
                    return Qt.resolvedUrl("images/error_cover.svg")
                return model.cover
            }
            iconFrame: model.filename != "ZZZback" && model.cover != "ZZZerror"
            visible: model.filename != "ZZZback" || !wide
            progression: false
            onClicked: {
                if (model.filename == "ZZZback") {
                    perAuthorModel.needsclear = true
                    adjustViews(false)
                } else {
                    loadFile(model.filename)
                }
            }
        }
    }

    Component {
        id: authorDelegate
        Subtitled {
            text: model.author || i18n.tr("Unknown Author")
            subText: (model.count > 1) ? i18n.tr("%1 Books").arg(model.count) : model.title
            icon: {
                if (model.count > 1)
                    return mobileIcon("contact")
                if (model.cover == "ZZZnone")
                    return Qt.resolvedUrl("images/default_cover.svg")
                if (model.cover == "ZZZerror")
                    return Qt.resolvedUrl("images/error_cover.svg")
                return model.cover
            }
            iconFrame: model.count == 1 && model.cover != "ZZZerror"
            progression: model.count > 1
            onClicked: {
                if (model.count > 1) {
                    listAuthorBooks(model.authorsort)
                    adjustViews(true)
                } else {
                    loadFile(model.filename)
                }
            }
        }
    }

    ListView {
        id: listview
        x: 0
        width: parent.width
        height: parent.height
        clip: true

        model: bookModel

        Behavior on x {
            id: widthAnimation
            NumberAnimation {
                duration: UbuntuAnimation.BriskDuration
                easing: UbuntuAnimation.StandardEasing

                onRunningChanged: {
                    if (!running && perAuthorModel.needsclear) {
                        perAuthorModel.clear()
                        perAuthorModel.needsclear = false
                    }
                }
            }
        }
    }

    Scrollbar {
        flickableItem: listview
        align: Qt.AlignTrailing
    }

    ListView {
        id: perAuthorListView
        anchors {
            left: listview.right
        }
        width: wide ? parent.width / 2 : parent.width
        height: parent.height
        clip: true

        model: perAuthorModel
        delegate: titleDelegate
    }

    Scrollbar {
        flickableItem: perAuthorListView
        align: Qt.AlignTrailing
    }

    Item {
        anchors.fill: parent
        visible: bookModel.count == 0

        Column {
            anchors.centerIn: parent
            spacing: units.gu(2)
            width: Math.min(units.gu(30), parent.width)

            Label {
                id: noBooksLabel
                text: i18n.tr("No Books in Library")
                fontSize: "large"
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }

            Label {
                text: i18n.tr("Beru could not find any books for your library.  Beru will " +
                              "automatically find all epub files in %1.  (It's a mouthful, " +
                              "we know.)").arg(folderModel.path)
                wrapMode: Text.Wrap
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }

            Button {
                text: i18n.tr("Download Books")
                width: parent.width
                onClicked: tabs.selectedTabIndex = 1
            }

            Button {
                text: i18n.tr("Search Again")
                width: parent.width
                onClicked: {
                    // Refresh isn't enough if folder was created in the meantime.
                    folderModel.path = ""
                    setPath()
                }
            }
        }
    }
    
    tools: ToolbarItems {
        id: localBooksToolbar
        
        ToolbarButton {
            id: sortButton
            action: Action {
                text: i18n.tr("Sort")
                iconSource: mobileIcon("filter")
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

    Component {
        id: firstStart

        Dialog {
            id: firstStartDialog
            title: i18n.tr("Welcome to Beru")
            text: i18n.tr("Right now, Beru is looking through %1 and adding all the Epub " +
                          "files it finds to your Library.  Any files you add to this folder " +
                          "will be added to the Library the next time you start Beru.\n\n" +
                          "Additionally, any file you open with Beru will be added to your " +
                          "library, regardless of where it is located.").arg(folderModel.path)

            Button {
                id: closeButton
                text: firststart ? i18n.tr("One moment please...") : i18n.tr("OK")
                gradient: firststart ? UbuntuColors.greyGradient : UbuntuColors.orangeGradient
                enabled: !firststart
                onClicked: {
                    if (!firststart)
                        PopupUtils.close(firstStartDialog)
                }
            }

            // Just waiting for onCompleted isn't enough to ensure this dialog
            // gets shown, so we start a brief timer before calling setPath().
            Timer {
                interval: 100
                repeat: false
                running: true
                triggeredOnStart: false
                onTriggered: setPath()
            }
        }
    }
}
