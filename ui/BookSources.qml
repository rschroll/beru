/* Copyright 2013-2015 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0

Page {
    id: bookSources
    title: i18n.tr("Get Books")

    ListView {
        id: sourcesView
        anchors.fill: parent

        model: sourcesModel
        delegate: Standard {
            text: (model.url == "contenthub") ? i18n.tr("Import from Content Hub") : model.name
            progression: true
            onClicked: {
                if (model.url == "contenthub")
                    pageStack.push(importer.pickerPage)
                else
                    Qt.openUrlExternally((width < units.gu(80)
                                          && model.murl != undefined) ? model.murl : model.url)
            }
        }
    }

    ListModel {
        id: sourcesModel
        ListElement {
            url: "contenthub"
        }
        ListElement {
            name: "Project Gutenberg"
            url: "http://www.gutenberg.org"
            murl: "http://m.gutenberg.org"
        }
        ListElement {
            name: "Open Library"
            url: "http://openlibrary.org"
        }
        ListElement {
            name: "MobileRead Epubs"
            url: "http://www.mobileread.com/forums/ebooks.php?s=&sort=ebook&order=asc&page=1&ltr=&f=130&genreid="
            murl: "http://www.mobileread.mobi/forums/ebooks.php?s=&sort=ebook&order=asc&page=1&ltr=&f=130&genreid="
        }
        ListElement {
            name: "Loyal Books"
            url: "http://www.loyalbooks.com"
        }
        ListElement {
            name: "Archive.org"
            url: "https://archive.org/details/texts"
        }
    }
}
