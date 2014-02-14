/* Copyright 2013 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Popups 0.1
import QtWebKit 3.0
import QtWebKit.experimental 1.0
import FontList 1.0

import "components"

import "qmlmessaging.js" as Messaging
import "historystack.js" as History


Page {
    id: bookPage
    //flickable: null
    
    property alias url: bookWebView.url
    property var currentChapter: null
    property var history: new History.History(updateNavButtons)
    property bool navjump: false

    focus: true
    Keys.onPressed: {
        if (event.key == Qt.Key_Right || event.key == Qt.Key_Down || event.key == Qt.Key_Space
                || event.key == Qt.Key_Period) {
            Messaging.sendMessage("ChangePage", 1)
            event.accepted = true
        } else if (event.key == Qt.Key_Left || event.key == Qt.Key_Up
                   || event.key == Qt.Key_Backspace || event.key == Qt.Key_Comma) {
            Messaging.sendMessage("ChangePage", -1)
            event.accepted = true
        }
    }

    onVisibleChanged: {
        if (visible == false) {
            // Reset things for the next time this page is opened
            history.clear()
            url = ""
            bookWebView.visible = false
        }
    }

    ListModel {
        id: contentsListModel
    }
    
    WebView {
        id: bookWebView
        anchors.fill: parent
        visible: false
        focus: false

        onTitleChanged: Messaging.handleMessage(title)
        // Reject attempts to give WebView focus
        onActiveFocusChanged: focus = false
    }

    tools: ToolbarItems {
        id: bookPageToolbar
        onOpenedChanged: {
            backButton.enabled = history.canBackward()
            forwardButton.enabled = history.canForward()
        }

        ToolbarButton {
            id: backButton
            enabled: false
            action: Action {
                text: i18n.tr("Back")
                iconSource: mobileIcon("go-previous")
                onTriggered: {
                    var locus = history.goBackward()
                    if (locus !== null) {
                        navjump = true
                        Messaging.sendMessage("GotoLocus", locus)
                    }
                }
            }
        }

        ToolbarButton {
            id: forwardButton
            enabled: false
            action: Action {
                text: i18n.tr("Forward")
                iconSource: mobileIcon("go-next")
                onTriggered: {
                    var locus = history.goForward()
                    if (locus !== null) {
                        navjump = true
                        Messaging.sendMessage("GotoLocus", locus)
                    }
                }
            }
        }

        ToolbarButton {
            id: contentsButton
            action: Action {
                text: i18n.tr("Contents")
                iconSource: Qt.resolvedUrl("images/toc.svg")
                onTriggered: PopupUtils.open(contentsComponent, contentsButton)
            }
        }

        ToolbarButton {
            id: settingsButton
            action: Action {
                text: i18n.tr("Settings")
                iconSource: mobileIcon("settings")
                onTriggered: PopupUtils.open(stylesComponent, settingsButton)
            }
        }
    }

    Component {
        id: contentsComponent

        Popover {
            id: contentsPopover

            ListView {
                id: contentsListView
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
                height: 0.8*bookPage.height

                model: contentsListModel
                delegate: Standard {
                    text: (new Array(model.level + 1)).join("    ") +
                          model.title.replace(/(\n| )+/g, " ")
                    selected: bookPage.currentChapter == model.src
                    onClicked: {
                        Messaging.sendMessage("NavigateChapter", model.src)
                        PopupUtils.close(contentsPopover)
                        bookPageToolbar.opened = false
                    }
                }

                Component.onCompleted: {
                    for (var i=0; i<contentsListModel.count; i++) {
                        if (contentsListModel.get(i).src == bookPage.currentChapter)
                            positionViewAtIndex(i, ListView.Center)
                    }
                }
            }
        }
    }

    Item {
        id: bookStyles
        property bool loading: false
        property bool atdefault: false

        property string textColor
        property string fontFamily
        property var lineHeight
        property real fontScale
        property string background
        property real margin
        property real marginv

        //onTextColorChanged: update()  // This is always updated with background
        onFontFamilyChanged: update()
        onLineHeightChanged: update()
        onFontScaleChanged: update()
        onBackgroundChanged: update()
        onMarginChanged: update()

        function load(styles) {
            loading = true
            textColor = styles.textColor || "#222"
            fontFamily = styles.fontFamily || "Default"
            lineHeight = styles.lineHeight || "Default"
            fontScale = styles.fontScale || 1
            background = styles.background || "url(.background_paper@30.png)"
            margin = styles.margin || 0
            marginv = styles.marginv || 0
            loading = false
        }

        function asObject() {
            return {
                textColor: textColor,
                fontFamily: fontFamily,
                lineHeight: lineHeight,
                fontScale: fontScale,
                background: background,
                margin: margin,
                marginv: marginv
            }
        }

        function update() {
            if (loading)
                return

            Messaging.sendMessage("Styles", asObject())
            atdefault = false
        }

        function saveAsDefault() {
            setSetting("defaultBookStyle", JSON.stringify(asObject()))
            Messaging.sendMessage("SetDefaultStyles", asObject())
        }
    }

    FontLister {
        id: fontLister

        property var fontList: ["Default", "Bitstream Charter", "Ubuntu", "URW Bookman L", "URW Gothic L"]

        Component.onCompleted: {
            var familyList = families()
            var possibleFamilies = [["Droid Serif", "Nimbus Roman No9 L", "FreeSerif"],
                                    ["Droid Sans", "Nimbus Sans L", "FreeSans"]]
            for (var j=0; j<possibleFamilies.length; j++) {
                for (var i=0; i<possibleFamilies[j].length; i++) {
                    if (familyList.indexOf(possibleFamilies[j][i]) >= 0) {
                        fontList.splice(2, 0, possibleFamilies[j][i])
                        break
                    }
                }
            }
        }
    }

    FontLoader {
        source: Qt.resolvedUrl("../html/fonts/Bitstream Charter.ttf")
    }

    FontLoader {
        source: Qt.resolvedUrl("../html/fonts/URW Bookman L.ttf")
    }

    FontLoader {
        source: Qt.resolvedUrl("../html/fonts/URW Gothic L.ttf")
    }

    Component {
        id: stylesComponent

        Dialog {
            id: stylesDialog
            property real labelwidth: units.gu(11)

            OptionSelector {
                id: colorSelector
                onSelectedIndexChanged: {
                    bookStyles.textColor = model.get(selectedIndex).foreground
                    bookStyles.background = model.get(selectedIndex).background
                }
                model: colorModel

                delegate: StylableOptionSelectorDelegate {
                    text: name
                    Component.onCompleted: {
                        textLabel.color = foreground
                        if (background.slice(0, 5) == "url(.") {
                            var filename = Qt.resolvedUrl("../html/" + background.slice(5, -1))
                            backgroundImage.source = filename
                        } else {
                            backgroundShape.color = background
                        }
                    }

                    UbuntuShape {
                        id: backgroundShape
                        anchors {
                            leftMargin: units.gu(0)
                            rightMargin: units.gu(0)
                            fill: parent
                        }
                        z: -1
                        image: Image {
                            id: backgroundImage
                            fillMode: Image.Tile
                        }
                    }
                }
            }

            ListModel {
                id: colorModel
                ListElement {
                    name: "Black on White"
                    foreground: "black"
                    background: "white"
                }
                ListElement {
                    name: "Dark on Texture"
                    foreground: "#222"
                    background: "url(.background_paper@30.png)"
                }
                ListElement {
                    name: "Light on Texture"
                    foreground: "#999"
                    background: "url(.background_paper_invert@30.png)"
                }
                ListElement {
                    name: "White on Black"
                    foreground: "white"
                    background: "black"
                }
            }

            OptionSelector {
                id: fontSelector
                onSelectedIndexChanged: bookStyles.fontFamily = model[selectedIndex]

                model: fontLister.fontList

                delegate: StylableOptionSelectorDelegate {
                    text: (modelData == "Default") ? i18n.tr("Default Font") : modelData
                    Component.onCompleted: {
                        if (modelData != "Default")
                            textLabel.font.family = modelData
                    }
                }
            }

            Row {
                Label {
                    text: i18n.tr("Font Scaling")
                    verticalAlignment: Text.AlignVCenter
                    width: labelwidth
                    height: fontScaleSlider.height
                }

                Slider {
                    id: fontScaleSlider
                    width: parent.width - labelwidth
                    minimumValue: 0
                    maximumValue: 12
                    function formatValue(v) {
                        return [0.5, 0.59, 0.7, 0.84, 1, 1.2, 1.4, 1.7, 2, 2.4, 2.8, 3.4, 4][Math.round(v)]
                    }
                    onValueChanged: bookStyles.fontScale = formatValue(value)
                }
            }

            Row {
                Label {
                    text: i18n.tr("Line Height")
                    verticalAlignment: Text.AlignVCenter
                    width: labelwidth
                    height: lineHeightSlider.height
                }

                Slider {
                    id: lineHeightSlider
                    width: parent.width - labelwidth
                    minimumValue: 0.8
                    maximumValue: 2
                    function formatValue(v, untranslated) {
                        if (v < 0.95)
                            return untranslated ? "Default" : i18n.tr("Auto")
                        return v.toFixed(1)
                    }
                    function setThumbColor() {
                        __styleInstance.thumb.color = (value < 0.95) ?
                                    UbuntuColors.warmGrey : Theme.palette.selected.foreground
                    }
                    onValueChanged: {
                        bookStyles.lineHeight = formatValue(value, true)
                        setThumbColor()
                    }
                    onPressedChanged: {
                        if (pressed)
                            __styleInstance.thumb.color = Theme.palette.selected.foreground
                        else
                            setThumbColor()
                    }
                }
            }

            Row {
                Label {
                    text: i18n.tr("Margins")
                    verticalAlignment: Text.AlignVCenter
                    width: labelwidth
                    height: marginSlider.height
                }

                Slider {
                    id: marginSlider
                    width: parent.width - labelwidth
                    minimumValue: 0
                    maximumValue: 30
                    function formatValue(v) { return Math.round(v) + "%" }
                    onValueChanged: bookStyles.margin = value
                }
            }

            Button {
                text: i18n.tr("Close")
                onClicked: PopupUtils.close(stylesDialog)
            }

            Item {
                height: children[0].height
                Button {
                    text: i18n.tr("Make Default")
                    width: parent.width/2 - units.gu(1)
                    anchors {
                        left: parent.left
                        top: parent.top
                        //width: parent.width / 2
                    }
                    gradient: UbuntuColors.greyGradient
                    enabled: !bookStyles.atdefault
                    onClicked: {
                        bookStyles.saveAsDefault()
                        bookStyles.atdefault = true
                    }
                }
                Button {
                    text: i18n.tr("Load Defaults")
                    width: parent.width/2 - units.gu(1)
                    anchors {
                        right: parent.right
                        top: parent.top
                    }
                    gradient: UbuntuColors.greyGradient
                    enabled: !bookStyles.atdefault
                    onClicked: {
                        Messaging.sendMessage("ResetStylesToDefault")
                        bookStyles.atdefault = true
                    }
                }
            }

            function setValues() {
                for (var i=0; i<colorModel.count; i++) {
                    if (colorModel.get(i).foreground == bookStyles.textColor) {
                        colorSelector.selectedIndex = i
                        break
                    }
                }
                fontSelector.selectedIndex = fontSelector.model.indexOf(bookStyles.fontFamily)
                fontScaleSlider.value = 4 + 4 * Math.LOG2E * Math.log(bookStyles.fontScale)
                lineHeightSlider.value = (bookStyles.lineHeight == "Default") ? 0.8 : bookStyles.lineHeight
                marginSlider.value = bookStyles.margin
            }

            function onLoadingChanged() {
                if (bookStyles.loading == false)
                    setValues()
            }

            Component.onCompleted: {
                setValues()
                bookStyles.onLoadingChanged.connect(onLoadingChanged)
            }

            Component.onDestruction: {
                bookStyles.onLoadingChanged.disconnect(onLoadingChanged)
            }
        }
    }

    function updateNavButtons(back, forward) {
        backButton.enabled = back
        forwardButton.enabled = forward
    }

    function onExternalLink(href) {
        Qt.openUrlExternally(href)
    }

    function parseContents(contents, level) {
        if (level === undefined) {
            level = 0
            contentsListModel.clear()
        }
        for (var i in contents) {
            var chp = contents[i]
            chp.level = level
            contentsListModel.append(chp)
            if (chp.children !== undefined)
                parseContents(chp.children, level + 1)
        }
    }

    function onJumping(locuses) {
        if (navjump)
            navjump = false
        else
            history.add(locuses[0], locuses[1])
    }

    function onPageChange(location) {
        currentChapter = location.chapterSrc
        setBookSetting("locus", { componentId: location.componentId,
                                  percent: location.percent })
    }

    function onReady() {
        bookWebView.visible = true
    }

    function windowSizeChanged() {
        Messaging.sendMessage("WindowSizeChanged")
    }

    Component.onCompleted: {
        Messaging.registerHandler("ExternalLink", onExternalLink)
        Messaging.registerHandler("Jumping", onJumping)
        Messaging.registerHandler("PageChange", onPageChange)
        Messaging.registerHandler("Styles", bookStyles.load)
        Messaging.registerHandler("Ready", onReady)
        server.epub.contentsReady.connect(parseContents)
        onWidthChanged.connect(windowSizeChanged)
        onHeightChanged.connect(windowSizeChanged)
    }
}
