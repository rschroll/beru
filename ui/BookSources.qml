/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1

Page {
    id: bookSources
    title: i18n.tr("Get Books")

    ListView {
        id: sourcesView
        anchors.fill: parent

        model: sourcesModel
        delegate: Standard {
            text: model.name
            progression: true
            onClicked: {
                var url = model.url
                if (width < units.gu(80) && model.murl != undefined)
                    url = model.murl
                pageStack.push(browserPage, {url: url, title: model.name,
                                   showAddressBar: model.showAddressBar})
            }
        }
    }

    ListModel {
        id: sourcesModel
        ListElement {
            name: "Project Gutenberg"
            url: "http://www.gutenberg.org"
            murl: "http://m.gutenberg.org"
            showAddressBar: false
        }
        ListElement {
            name: "Open Library"
            url: "http://openlibrary.org"
            showAddressBar: false
        }
        ListElement {
            name: "MobileRead Epubs"
            url: "http://www.mobileread.com/forums/ebooks.php?s=&sort=ebook&order=asc&page=1&ltr=&f=130&genreid="
            murl: "http://www.mobileread.mobi/forums/ebooks.php?s=&sort=ebook&order=asc&page=1&ltr=&f=130&genreid="
            showAddressBar: false
        }
        ListElement {
            name: "Search the Web"
            url: "http://google.com"
            murl: "http://google.com/m"
            showAddressBar: true
        }
    }
}
