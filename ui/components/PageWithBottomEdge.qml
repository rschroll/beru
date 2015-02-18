/*
 * Copyright (C) 2014 Canonical, Ltd.
 * Copyright 2015 Robert Schroll
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
    Example:

    MainView {
        objectName: "mainView"

        applicationName: "com.ubuntu.developer.boiko.bottomedge"

        width: units.gu(100)
        height: units.gu(75)

        Component {
            id: pageComponent

            PageWithBottomEdge {
                id: mainPage
                title: i18n.tr("Main Page")

                Rectangle {
                    anchors.fill: parent
                    color: "white"
                }

                bottomEdgePageComponent: Page {
                    title: "Contents"
                    anchors.fill: parent
                    //anchors.topMargin: contentsPage.flickable.contentY

                    ListView {
                        anchors.fill: parent
                        model: 50
                        delegate: ListItems.Standard {
                            text: "One Content Item: " + index
                        }
                    }
                }
                bottomEdgeTitle: i18n.tr("Bottom edge action")
            }
        }

        PageStack {
            id: stack
            Component.onCompleted: stack.push(pageComponent)
        }
    }

*/

import QtQuick 2.2
import Ubuntu.Components 1.1

Page {
    id: page

    property alias bottomEdgePageComponent: edgeLoader.sourceComponent
    property alias bottomEdgePageSource: edgeLoader.source
    property alias bottomEdgeTitle: tipLabel.text
    property bool bottomEdgeEnabled: true
    property int bottomEdgeExpandThreshold: page.height * 0.2
    property int bottomEdgeExposedArea: bottomEdge.state !== "expanded" ? (page.height - bottomEdge.y - bottomEdge.tipHeight) : _areaWhenExpanded
    property bool reloadBottomEdgePage: true

    property alias bottomEdgeControls: controlLoader.sourceComponent

    readonly property alias bottomEdgePage: edgeLoader.item
    readonly property bool isReady: ((bottomEdge.y === fakeHeader.height) && bottomEdgePageLoaded)
    readonly property bool isCollapsed: (bottomEdge.y === page.height)
    readonly property bool bottomEdgePageLoaded: (edgeLoader.status == Loader.Ready)

    property bool _showEdgePageWhenReady: false
    property int _areaWhenExpanded: 0

    signal bottomEdgePressed()
    signal bottomEdgeReleased()
    signal bottomEdgeDismissed()

    function showBottomEdgePage(source, properties)
    {
        edgeLoader.setSource(source, properties)
        _showEdgePageWhenReady = true
    }

    function setBottomEdgePage(source, properties)
    {
        edgeLoader.setSource(source, properties)
    }

    function closeBottomEdge() {
        bottomEdge.state = "collapsed"
    }

    function _pushPage()
    {
        if (edgeLoader.status === Loader.Ready) {
            if (edgeLoader.item.flickable) {
                edgeLoader.item.flickable.contentY = -page.header.height
                edgeLoader.item.flickable.returnToBounds()
            }
            if (edgeLoader.item.ready)
                edgeLoader.item.ready()
        }
    }


    Component.onCompleted: {
        // avoid a binding on the expanded height value
        var expandedHeight = height;
        _areaWhenExpanded = expandedHeight;
    }

    onActiveChanged: {
        if (active) {
            bottomEdge.state = "collapsed"
        }
    }

    onBottomEdgePageLoadedChanged: {
        if (_showEdgePageWhenReady && bottomEdgePageLoaded) {
            bottomEdge.state = "expanded"
            _showEdgePageWhenReady = false
        }
    }

    Rectangle {
        id: bgVisual

        color: "black"
        anchors.fill: page
        opacity: 0.7 * ((page.height - bottomEdge.y) / page.height)
        z: 1
    }

    UbuntuShape {
        id: tip
        objectName: "bottomEdgeTip"

        property bool hidden: (activeFocus === false) ||
                             ((bottomEdge.y - units.gu(1)) < tip.y)

        property bool isAnimating: true

        enabled: mouseArea.enabled
        visible: page.bottomEdgeEnabled
        anchors {
            bottom: parent.bottom
            horizontalCenter: bottomEdge.horizontalCenter
            bottomMargin: hidden ? - height + units.gu(1) : -units.gu(1)
            Behavior on bottomMargin {
                SequentialAnimation {
                    // wait some msecs in case of the focus change again, to avoid flickering
                    PauseAnimation {
                        duration: 300
                    }
                    UbuntuNumberAnimation {
                        duration: UbuntuAnimation.SnapDuration
                    }
                    ScriptAction {
                        script: tip.isAnimating = false
                    }
                }
            }
        }

        z: 1
        width: tipLabel.paintedWidth + units.gu(6)
        height: bottomEdge.tipHeight + units.gu(1)
        color: Theme.palette.normal.overlay
        Label {
            id: tipLabel

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: bottomEdge.tipHeight
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            opacity: tip.hidden ? 0.0 : 1.0
            Behavior on opacity {
                UbuntuNumberAnimation {
                    duration: UbuntuAnimation.SnapDuration
                }
            }
        }
    }

    Rectangle {
        id: shadow

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: units.gu(1)
        z: 1
        opacity: 0.0
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.2) }
        }
    }

    MouseArea {
        id: mouseArea

        property real previousY: -1
        property string dragDirection: "None"

        preventStealing: true
        drag {
            axis: Drag.YAxis
            target: bottomEdge
            minimumY: bottomEdge.pageStartY
            maximumY: page.height
        }
        enabled: edgeLoader.status == Loader.Ready
        visible: page.bottomEdgeEnabled

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: bottomEdge.tipHeight
        z: 1

        onReleased: {
            page.bottomEdgeReleased()
            if (dragDirection === "BottomToTop") {
                if (bottomEdge.y < (page.height - bottomEdgeExpandThreshold - bottomEdge.tipHeight))
                    bottomEdge.state = "expanded"
                else if (bottomEdge.y < (page.height - 0.75*controls.fullHeight))
                    bottomEdge.state = "controls"
                else
                    bottomEdge.state = "collapsed"
            } else {
                bottomEdge.state = "collapsed"
            }
            previousY = -1
            dragDirection = "None"
        }

        onPressed: {
            page.bottomEdgePressed()
            previousY = mouse.y
            tip.forceActiveFocus()
        }

        onMouseYChanged: {
            var yOffset = previousY - mouseY
            // skip if was a small move
            if (Math.abs(yOffset) <= units.gu(2)) {
                return
            }
            previousY = mouseY
            dragDirection = yOffset > 0 ? "BottomToTop" : "TopToBottom"
        }
    }

    StyledItem {
        id: fakeHeader

        anchors {
            left: parent.left
            right: parent.right
        }
        y: -fakeHeader.height + (fakeHeader.height * (page.height - bottomEdge.y)) / (page.height - fakeHeader.height)
        z: bgVisual.z + 1

        Rectangle {
            color: Theme.palette.normal.background
            anchors.fill: parent
            z: -1
        }

        Behavior on y {
            UbuntuNumberAnimation {
                duration: UbuntuAnimation.SnapDuration
            }
        }

        // PageHeadStyle uses these properties when styling the header.
        property string title: bottomEdgeTitle
        property color dividerColor: Qt.darker(Theme.palette.normal.background, 1.1)
        property PageHeadConfiguration config: PageHeadConfiguration {
            backAction: Action {
                iconName: "back"
                onTriggered: closeBottomEdge()
            }
        }

        // PageHeadStyle needs these properties as well, although they aren't used
        // in this setup.
        property Item contents: null
        property color panelColor: "red"

        style: Theme.createStyleComponent("PageHeadStyle.qml", header)
    }


    Rectangle {
        id: bottomEdge
        objectName: "bottomEdge"

        readonly property int tipHeight: units.gu(3)
        readonly property int pageStartY: fakeHeader.height

        z: 1
        color: Theme.palette.normal.background
        clip: true
        anchors {
            left: parent.left
            right: parent.right
        }
        height: page.height
        y: height

        visible: !page.isCollapsed
        state: "collapsed"
        states: [
            State {
                name: "collapsed"
                PropertyChanges {
                    target: bottomEdge
                    y: bottomEdge.height
                }
                PropertyChanges {
                    target: fakeHeader
                    y: -fakeHeader.height
                }
                PropertyChanges {
                    target: controls
                    y: bottomEdge.height
                }
            },
            State {
                name: "expanded"
                PropertyChanges {
                    target: bottomEdge
                    y: bottomEdge.pageStartY
                }
                PropertyChanges {
                    target: fakeHeader
                    y: 0
                }
            },
            State {
                name: "floating"
                when: mouseArea.drag.active
                PropertyChanges {
                    target: bottomEdge
                    opacity: Math.min((bottomEdge.height - bottomEdge.y) / bottomEdgeExpandThreshold,
                                      1)
                }
                PropertyChanges {
                    target: shadow
                    opacity: 1.0
                }
                PropertyChanges {
                    target: controls
                    y: {
                        var threshold = page.height - bottomEdgeExpandThreshold - bottomEdge.tipHeight
                        if (bottomEdge.y > threshold)
                            Math.max(bottomEdge.y, bottomEdge.height - controls.fullHeight)
                        else
                            Math.min(bottomEdge.height - controls.fullHeight + threshold - bottomEdge.y,
                                     bottomEdge.height)
                    }
                }
            },
            State {
                name: "controls"
                PropertyChanges {
                    target: bottomEdge
                    y: bottomEdge.height
                }
                PropertyChanges {
                    target: fakeHeader
                    y: -fakeHeader.height
                }
                PropertyChanges {
                    target: controls
                    y: bottomEdge.height - controls.fullHeight
                }
            }
        ]

        transitions: [
            Transition {
                to: "expanded"
                SequentialAnimation {
                    alwaysRunToEnd: true
                    ParallelAnimation {
                        SmoothedAnimation {
                            target: bottomEdge
                            property: "y"
                            duration: UbuntuAnimation.FastDuration
                            easing.type: Easing.Linear
                        }
                        SmoothedAnimation {
                            target: fakeHeader
                            property: "y"
                            duration: UbuntuAnimation.FastDuration
                            easing.type: Easing.Linear
                        }
                        SmoothedAnimation {
                            target: controls
                            property: "y"
                            duration: UbuntuAnimation.FastDuration
                            easing.type: Easing.Linear
                        }
                    }
                    SmoothedAnimation {
                        target: edgeLoader
                        property: "anchors.topMargin"
                        to: - units.gu(4)
                        duration: UbuntuAnimation.FastDuration
                        easing.type: Easing.Linear
                    }
                    SmoothedAnimation {
                        target: edgeLoader
                        property: "anchors.topMargin"
                        to: 0
                        duration: UbuntuAnimation.FastDuration
                        easing: UbuntuAnimation.StandardEasing
                    }
                    ScriptAction {
                        script: page._pushPage()
                    }
                }
            },
            Transition {
                from: "expanded"
                to: "collapsed"
                SequentialAnimation {
                    alwaysRunToEnd: true

                    ScriptAction {
                        script: {
                            Qt.inputMethod.hide()
                            edgeLoader.item.parent = edgeLoader
                            edgeLoader.item.anchors.fill = edgeLoader
                        }
                    }
                    ParallelAnimation {
                        SmoothedAnimation {
                            target: bottomEdge
                            property: "y"
                            duration: UbuntuAnimation.SlowDuration
                        }
                        SmoothedAnimation {
                            target: fakeHeader
                            property: "y"
                            duration: UbuntuAnimation.SlowDuration
                        }
                    }
                    ScriptAction {
                        script: {
                            // destroy current bottom page
                            if (page.reloadBottomEdgePage) {
                                edgeLoader.active = false
                            } else {
                                tip.forceActiveFocus()
                            }

                            // notify
                            page.bottomEdgeDismissed()

                            edgeLoader.active = true
                        }
                    }
                }
            },
            Transition {
                from: "floating"
                to: "collapsed,controls"
                ParallelAnimation {
                    SmoothedAnimation {
                        target: bottomEdge
                        property: "y"
                        duration: UbuntuAnimation.FastDuration
                    }
                    SmoothedAnimation {
                        target: fakeHeader
                        property: "y"
                        duration: UbuntuAnimation.FastDuration
                    }
                    SmoothedAnimation {
                        target: controls
                        property: "y"
                        duration: UbuntuAnimation.FastDuration
                    }
                }
            },
            Transition {
                from: "controls"
                to: "collapsed,floating"
                SmoothedAnimation {
                    target: controls
                    property: "y"
                    duration: UbuntuAnimation.FastDuration
                }
            }
        ]

        Loader {
            id: edgeLoader

            asynchronous: true
            anchors.fill: parent
            //WORKAROUND: The SDK move the page contents down to allocate space for the header we need to avoid that during the page dragging
            Binding {
                target: edgeLoader.status === Loader.Ready ? edgeLoader : null
                property: "anchors.topMargin"
                value:  edgeLoader.item && edgeLoader.item.flickable ? edgeLoader.item.flickable.contentY : 0
                when: !page.isReady
            }

            onLoaded: {
                tip.forceActiveFocus()
                if (page.isReady) {
                    page._pushPage()
                }
            }
        }
    }

    MouseArea {
        id: controls
        objectName: "controls"

        property real fullHeight: controlLoader.item.height

        preventStealing: true
        drag {
            axis: Drag.YAxis
            target: controls
            minimumY: page.height - fullHeight
            maximumY: page.height
        }
        enabled: bottomEdge.state == "controls"
        visible: (y < bottomEdge.height)

        anchors {
            left: parent.left
            right: parent.right
        }
        y: page.height
        height: fullHeight - bottomEdge.tipHeight
        z: 2

        onReleased: {
            if (drag.active && mouseY > 0)
                bottomEdge.state = "collapsed"
        }

        Loader {
            id: controlLoader

            asynchronous: true
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
        }
    }
}
