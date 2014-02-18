/* Copyright 2013-2014 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import QtGraphicalEffects 1.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Popups 0.1
import Epub 1.0


Page {
    id: localBooks
    title: i18n.tr("Books")
    flickable: gridview
    property int sort: 0
    property bool needsort: false
    property bool firststart: false
    property bool wide: width >= units.gu(80)
    property string bookdir: ""
    property bool writablehome: false
    property string defaultdirname: i18n.tr("Books")
    property double gridmargin: units.gu(1)
    property double mingridwidth: units.gu(15)
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
        firststart = true
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

    function addBookDir() {
        var db = openDatabase()
        db.transaction(function (tx) {
            var files = filesystem.listDir(bookdir, ["*.epub"])
            for (var i=0; i<files.length; i++) {
                tx.executeSql(addFileSQL, [bookdir + "/" + files[i], fileToTitle(files[i])])
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

    function listAuthorBooks(authorsort) {
        perAuthorModel.clear()
        var db = openDatabase()
        db.readTransaction(function (tx) {
            var res = tx.executeSql("SELECT filename, title, author, cover, fullcover FROM LocalBooks " +
                                    "WHERE authorsort=? ORDER BY title ASC", [authorsort])
            for (var i=0; i<res.rows.length; i++) {
                var item = res.rows.item(i)
                if (filesystem.exists(item.filename))
                    perAuthorModel.append({filename: item.filename, title: item.title,
                                           author: item.author, cover: item.cover, fullcover: item.fullcover})
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
            var title, author, authorsort, cover, fullcover
            if (coverReader.load(res.rows.item(0).filename)) {
                var coverinfo = coverReader.getCoverInfo(units.gu(5), 2*mingridwidth)
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
                fullcover = coverinfo.fullcover
            } else {
                title = res.rows.item(0).title
                author = i18n.tr("Could not open this book.")
                authorsort = "zzzzerror"
                cover = "ZZZerror"
                fullcover = ""
            }
            tx.executeSql("UPDATE LocalBooks SET title=?, author=?, authorsort=?, cover=?, " +
                          "fullcover=? WHERE filename=?",
                          [title, author, authorsort, cover, fullcover, res.rows.item(0).filename])

            if (localBooks.visible) {
                for (var i=0; i<bookModel.count; i++) {
                    var book = bookModel.get(i)
                    if (book.filename == res.rows.item(0).filename) {
                        console.log(book.filename + " " + book.fullcover)
                        book.title = title
                        book.author = author
                        book.cover = cover
                        book.fullcover = fullcover
                        break
                    }
                }
            }

            coverTimer.start()
        })
    }

    function refreshCover(filename) {
        var db = openDatabase()
        db.transaction(function (tx) {
            tx.executeSql("UPDATE LocalBooks SET authorsort='zzznull' WHERE filename=?", [filename])
        })

        coverTimer.start()
    }

    function readBookDir() {
        addBookDir()
        listBooks()
        coverTimer.start()
    }

    function adjustViews(showAuthor) {
        if (sort != 2 || perAuthorModel.count == 0)
            showAuthor = false  // Don't need to show authors' list

        if (sort == 0) {
            listview.visible = false
            gridview.visible = true
            localBooks.flickable = gridview
        } else {
            listview.visible = true
            gridview.visible = false
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
    }

    function loadBookDir() {
        if (filesystem.writableHome()) {
            writablehome = true
            var storeddir = getSetting("bookdir")
            bookdir = (storeddir == null) ? filesystem.getDataDir(defaultdirname) : storeddir
        } else {
            writablehome = false
            bookdir = filesystem.getDataDir(defaultdirname)
        }
    }

    function setBookDir(dir) {
        bookdir = dir
        setSetting("bookdir", dir)
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
        if (db.version == "" || db.version == "1" || db.version == "2") {
            db.changeVersion(db.version, "3", function (tx) {
                tx.executeSql("ALTER TABLE LocalBooks ADD fullcover BLOB DEFAULT ''")
                // Trigger re-rendering of covers.
                tx.executeSql("UPDATE LocalBooks SET authorsort='zzznull'")
            })
        }
    }

    // We need to wait for main to be finished, so that the settings are available.
    function onMainCompleted() {
        // readBookDir() will trigger the loading of all files in the default directory
        // into the library.
        if (!firststart) {
            loadBookDir()
            readBookDir()
        } else {
            writablehome = filesystem.writableHome()
            if (writablehome) {
                setBookDir(filesystem.homePath() + "/" + defaultdirname)
                PopupUtils.open(settingsComponent)
            } else {
                setBookDir(filesystem.getDataDir(defaultdirname))
                readBookDir()
            }
        }
    }

    // If we need to resort, do it when hiding or showing this page
    onVisibleChanged: {
        if (needsort)
            listBooks()
        // If we are viewing recently read, then the book we had been reading is now at the top
        if (visible && sort == 0)
            listview.positionViewAtBeginning()
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
                        x: 0
                        y: 0
                        width: parent.width
                        height: parent.height/2
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.Wrap
                        elide: Text.ElideRight
                        color: defaultCover.textColor(model)
                        font.family: "URW Bookman L"
                        text: {
                            if (!model.fullcover)
                                return model.title
                            return ""
                        }
                    }

                    Text {
                        x: 0
                        y: parent.height/2
                        width: parent.width
                        height: parent.height/2
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.Wrap
                        elide: Text.ElideRight
                        color: defaultCover.textColor(model)
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
            }
        }
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
                    return defaultCover.missingCover(model)
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
                    // Save copies now, since these get cleared by loadFile (somehow...)
                    var filename = model.filename
                    var pasterror = model.cover == "ZZZerror"
                    if (loadFile(filename) && pasterror)
                        refreshCover(filename)
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
                    return defaultCover.missingCover(model)
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
                    // Save copies now, since these get cleared by loadFile (somehow...)
                    var filename = model.filename
                    var pasterror = model.cover == "ZZZerror"
                    if (loadFile(filename) && pasterror)
                        refreshCover(filename)
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

    Scrollbar {
        flickableItem: gridview
        align: Qt.AlignTrailing
        anchors {
            right: localBooks.right
            top: localBooks.top
            bottom: localBooks.bottom
        }
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
                              "automatically find all epub files in %1.  Additionally, any book " +
                              "opened with Beru will be added to the library.").arg(bookdir)
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
                onClicked: readBookDir()
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

        ToolbarButton {
            id: settingsButton
            action: Action {
                text: i18n.tr("Settings")
                iconSource: mobileIcon("settings")
                onTriggered: PopupUtils.open(writablehome ? settingsComponent : settingsDisabledComponent,
                                                            settingsButton)
            }
        }
    }

    Component {
        id: settingsComponent

        Dialog {
            id: settingsDialog
            title: firststart ? i18n.tr("Welcome to Beru") : i18n.tr("Default Book Location")
            text: i18n.tr("Enter the folder in your home directory where your ebooks are or " +
                          "should be stored.\n\nChanging this value will not affect existing " +
                          "books in your library.")
            property string homepath: filesystem.homePath() + "/"

            TextField {
                id: pathfield
                text: {
                    if (bookdir.substring(0, homepath.length) == homepath)
                        return bookdir.substring(homepath.length)
                    return bookdir
                }
                onTextChanged: {
                    var status = filesystem.exists(homepath + pathfield.text)
                    if (status == 0) {
                        useButton.text = i18n.tr("Create Directory")
                        useButton.enabled = true
                    } else if (status == 1) {
                        useButton.text = i18n.tr("File Exists")
                        useButton.enabled = false
                    } else if (status == 2) {
                        useButton.text = i18n.tr("Use Directory")
                        useButton.enabled = true
                    }
                }
            }

            Button {
                id: useButton
                onClicked: {
                    var status = filesystem.exists(homepath + pathfield.text)
                    if (status != 1) { // Should always be true
                        if (status == 0)
                            filesystem.makeDir(homepath + pathfield.text)
                        setBookDir(homepath + pathfield.text)
                        useButton.enabled = false
                        useButton.text = i18n.tr("Please wait...")
                        cancelButton.enabled = false
                        unblocker.start()
                    }
                }
            }

            Timer {
                id: unblocker
                interval: 10
                onTriggered: {
                    readBookDir()
                    PopupUtils.close(settingsDialog)
                    firststart = false
                }
            }

            Button {
                id: cancelButton
                text: i18n.tr("Cancel")
                gradient: UbuntuColors.greyGradient
                visible: !firststart
                onClicked: PopupUtils.close(settingsDialog)
            }
        }
    }

    Component {
        id: settingsDisabledComponent

        Dialog {
            id: settingsDisabledDialog
            title: i18n.tr("Default Book Location")
            text: i18n.tr("Beru seems to be operating under AppArmor restrictions that prevent it " +
                              "from accessing most of your home directory.  Ebooks should be put in " +
                              "<i>%1</i> for Beru to read them.").arg(bookdir)

            Label {
                text: "For more information:<br>" +
                      "<a href='http://rschroll.github.io/beru/confinement.html'>" +
                      "rschroll.github.io/beru/confinement.html</a>"
                linkColor: "#a4a4ff"
                onLinkActivated: Qt.openUrlExternally(link)
                horizontalAlignment: Text.AlignHCenter
                fontSize: "medium"
                color: Qt.rgba(1, 1, 1, 0.6)
                wrapMode: Text.WordWrap
            }

            Button {
                text: i18n.tr("Close")
                onClicked: PopupUtils.close(settingsDisabledDialog)
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
