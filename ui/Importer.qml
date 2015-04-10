/* Copyright 2015 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import Ubuntu.Content 0.1

import "components"

Item {
    id: importer
    property bool importError: false
    property bool openImport: true

    Connections {
        target: ContentHub
        onImportRequested: {
            if (transfer.state === ContentTransfer.Charged)
                importItems(transfer.items)
        }
    }

    Reader {
        id: importReader
    }

    function doImport(filename, item) {
        return function () {
            var components = filename.split("/").pop().split(".")
            var ext = components.pop()
            var dir = filesystem.getDataDir(localBooks.defaultdirname)
            var basename =components.join(".")
            var newfilename = basename + "." + ext
            var i = 0
            while (filesystem.exists(dir + "/" + newfilename)) {
                i += 1
                newfilename = basename + "(" + i + ")." + ext
            }
            item.move(dir, newfilename)
            localBooks.addFile(dir + "/" + newfilename, true)
            console.log("Importing as " + dir + "/" + newfilename)
            if (openImport)
                loadFile(dir + "/" + newfilename)
        }
    }

    function importItems(items) {
        var dialog = PopupUtils.open(importComponent)
        openImport = (items.length == 1)
        importError = false

        for (var i=0; i<items.length; i++) {
            var filename = items[i].url.toString().slice(7)
            if (importReader.load(filename)) {
                localBooks.inDatabase(
                            importReader.hash(),
                            function (currentfilename) {
                                if (openImport)
                                    loadFile(currentfilename)
                                console.log("This was already imported as " + currentfilename)
                            },
                            doImport(filename, items[i]))
            } else {
                console.log("Import error: " + importReader.error)
                importError = true
            }
        }
        if (!importError)
            PopupUtils.close(dialog)
    }

    Component {
        id: importComponent
        Dialog {
            id: importDialog
            title: importError ? i18n.tr("Error Importing File") : i18n.tr("Import in Progress")
            text: importError ? importReader.error : ""
            StyledButton {
                text: i18n.tr("Dismiss")
                onClicked: {
                    openImport = false
                    PopupUtils.close(importDialog)
                }
            }
        }
    }
}
