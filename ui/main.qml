/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import U1db 1.0 as U1db
import File 1.0


MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"
    id: mainView
    
    applicationName: "com.ubuntu.developer.rschroll.beru"
    
    /* 
     This property enables the application to change orientation 
     when the device is rotated. The default is false.
    */
    automaticOrientation: true
    
    width: units.gu(50)
    height: units.gu(75)

    FileReader {
        id: filereader
    }

    PageStack {
        id: pageStack
        Component.onCompleted: push(tabs)

        Tabs {
            id: tabs

            Tab {
                title: i18n.tr("Library")
                page: LocalBooks {
                    id: localBooks
                }
            }

            Tab {
                title: i18n.tr("Get Books")
                page: BookSources {
                    id: bookSources
                }
            }
        }

        BookPage {
            id: bookPage
            visible: false
        }

        BrowserPage {
            id: browserPage
            visible: false
        }
    }

    Component {
        id: errorOpen
        Dialog {
            id: errorOpenDialog
            title: i18n.tr("Error Opening File")
            text: i18n.tr("Beru could not open this file.\n\n" +
                          "Remember, Beru can only open Epub files without DRM.")
            Button {
                text: i18n.tr("OK")
                onClicked: PopupUtils.close(errorOpenDialog)
            }
        }
    }

    Server {
        id: server
    }

    function loadFile(filename) {
        if (server.loadFile(filename)) {
            pageStack.push(bookPage, {url: "http://127.0.0.1:" + server.port})
            localBooks.updateRead(filename)
            return true
        }
        PopupUtils.open(errorOpen)
        return false
    }

    function mobileIcon(name) {
        return "/usr/share/icons/ubuntu-mobile/actions/scalable/" + name + ".svg"
    }

    function openSettingsDatabase() {
        return LocalStorage.openDatabaseSync("BeruSettings", "1", "Global settings for Beru", 10000)
    }

    function getSetting(key) {
        var db = openSettingsDatabase()
        var retval = null
        db.readTransaction(function (tx) {
            var res = tx.executeSql("SELECT value FROM Settings WHERE key=?", [key])
            if (res.rows.length > 0)
                retval = res.rows.item(0).value
        })
        return retval
    }

    function setSetting(key, value) {
        var db = openSettingsDatabase()
        db.transaction(function (tx) {
            tx.executeSql("INSERT OR REPLACE INTO Settings(key, value) VALUES(?, ?)", [key, value])
        })
    }

    U1db.Database {
        id: bookSettingsDatabase
        path: "BeruBookSettings.db"
    }

    function getBookSettings(key) {
        if (server.epub.hash == "")
            return undefined

        var settings = bookSettingsDatabase.getDoc(server.epub.hash)
        if (settings == undefined)
            return undefined
        return settings[key]
    }

    function setBookSetting(key, value) {
        if (server.epub.hash == "")
            return false

        if (databaseTimer.hash != null &&
                (databaseTimer.hash != server.epub.hash || databaseTimer.key != key))
            databaseTimer.trigger()

        databaseTimer.stop()
        databaseTimer.hash = server.epub.hash
        databaseTimer.key = key
        databaseTimer.value = value
        databaseTimer.start()

        return true
    }

    Timer {
        id: databaseTimer
        interval: 1000
        repeat: false
        running: false
        triggeredOnStart: false
        property var hash: null
        property var key
        property var value
        onTriggered: {
            if (hash == null)
                return

            var settings = bookSettingsDatabase.getDoc(hash)
            if (settings == undefined)
                settings = {}
            settings[key] = value
            bookSettingsDatabase.putDoc(settings, hash)
            hash = null
        }
    }

    Arguments {
        id: args

        Argument {
            name: "appargs"
            required: true
            valueNames: ["APP_ARGS"]
        }
    }

    Component.onCompleted: {
        var db = openSettingsDatabase()
        db.transaction(function (tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS Settings(key TEXT UNIQUE, value TEXT)")
        })

        var filePath = filereader.canonicalFilePath(args.values.appargs)
        if (filePath !== "") {
            if (loadFile(filePath))
                localBooks.addFile(filePath)
        }
    }
}
