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

import "components"

import "qmlmessaging.js" as Messaging
import "historystack.js" as History


Page {
    id: bookPage
    visible: false
    //flickable: null
    
    property alias url: bookWebView.url
    property var currentChapter: null
    property var history: new History.History(updateNavButtons)
    property bool navjump: false

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
        
        onTitleChanged: Messaging.handleMessage(title)
    }

    tools: ToolbarItems {
        id: bookPageToolbar
        onOpenedChanged: {
            backButton.visible = history.canBackward()
            forwardButton.visible = history.canForward()
        }

        ToolbarButton {
            id: backButton
            action: Action {
                text: i18n.tr("Back")
                visible: false
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
            action: Action {
                text: i18n.tr("Forward")
                visible: false
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

    Component {
        id: stylesComponent

        Dialog {
            id: stylesDialog
            property real labelwidth: units.gu(11)

            ColorSelector {
                id: colorSelector
                text: i18n.tr("Colors")
                values: [i18n.tr("Black on White"), i18n.tr("Dark on Texture"),
                    i18n.tr("Light on Texture"), i18n.tr("White on Black")]
                foregrounds: ["black", "#222", "#999", "white"]
                backgrounds: ["white", "url(.background_paper@30.png)",
                    "url(.background_paper_invert@30.png)", "black"]
                onSelectedIndexChanged: {
                    bookStyles.textColor = foregrounds[selectedIndex]
                    bookStyles.background = backgrounds[selectedIndex]
                }
            }

            FontSelector {
                id: fontSelector
                text: i18n.tr("Font")
                values: ["Default", "Bitstream Charter", "Nimbus Roman No9 L", "Nimbus Sans L",
                    "Ubuntu", "URW Bookman L", "URW Gothic L"]
                onSelectedIndexChanged: bookStyles.fontFamily = values[selectedIndex]
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
                    function formatValue(v) {
                        if (v < 0.95)
                            return "Default"
                        return v.toFixed(1)
                    }
                    onValueChanged: bookStyles.lineHeight = formatValue(value)
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
                    gradient: bookStyles.atdefault ? UbuntuColors.greyGradient : UbuntuColors.orangeGradient
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
                    gradient: bookStyles.atdefault ? UbuntuColors.greyGradient : UbuntuColors.orangeGradient
                    onClicked: {
                        Messaging.sendMessage("ResetStylesToDefault")
                        bookStyles.atdefault = true
                    }
                }
            }

            function setValues() {
                colorSelector.selectedIndex = colorSelector.foregrounds.indexOf(bookStyles.textColor)
                fontSelector.selectedIndex = fontSelector.values.indexOf(bookStyles.fontFamily)
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
        backButton.visible = back
        forwardButton.visible = forward
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

    Component.onCompleted: {
        Messaging.registerHandler("ExternalLink", onExternalLink)
        Messaging.registerHandler("Jumping", onJumping)
        Messaging.registerHandler("PageChange", onPageChange)
        Messaging.registerHandler("Styles", bookStyles.load)
        Messaging.registerHandler("Ready", onReady)
        server.epub.contentsReady.connect(parseContents)
    }
}
