/* Copyright 2015 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

import QtQuick 2.0
import Ubuntu.Components 1.1


Rectangle {
    id: swipeControl
    color: actionColor
    height: actionLabel.height + 2 * marginWidth
    width: parent.width
    clip: true

    property double lineWidth: units.dp(1)
    property double marginWidth: units.gu(2)
    property double threshold: 0.5
    property string actionText: ""
    property string notificationText: ""
    property color sliderColor: "white"
    property color actionColor: "red"

    signal triggered

    Label {
        id: actionLabel
        text: swipeControl.actionText
        anchors {
            top: parent.top
            left: parent.left
            margins: swipeControl.marginWidth
        }
        color: swipeControl.sliderColor
        opacity: slider.x > slider.width * swipeControl.threshold
        scale: (slider.x > slider.width * swipeControl.threshold) ? 1.0 : 0.8

        Behavior on opacity {
            UbuntuNumberAnimation {
                duration: UbuntuAnimation.BriskDuration
            }
        }
        Behavior on scale {
            UbuntuNumberAnimation {
                duration: UbuntuAnimation.BriskDuration
            }
        }
    }

    Rectangle {
        id: slider
        anchors {
            top: parent.top
            bottom: parent.bottom
            topMargin: swipeControl.lineWidth
            bottomMargin: swipeControl.lineWidth
        }
        color: swipeControl.sliderColor
        width: parent.width

        Behavior on x {
            UbuntuNumberAnimation {
                duration: UbuntuAnimation.SnapDuration
            }
        }

        Label {
            id: notificationLabel
            anchors.centerIn: parent
            color: swipeControl.actionColor
            text: swipeControl.notificationText
        }

        Icon {
            name: "next"
            anchors {
                top: parent.top
                topMargin: units.gu(1)
                bottom: parent.bottom
                bottomMargin: units.gu(1)
                right: parent.right
            }
            width: height
            color: swipeControl.actionColor
        }
    }

    MouseArea {
        anchors.fill: parent
        drag {
            target: slider
            axis: Drag.XAxis
            minimumX: 0
            maximumX: slider.width
        }
        onReleased: {
            if (slider.x > slider.width * swipeControl.threshold) {
                slider.x = slider.width
                swipeControl.triggered()
            } else {
                slider.x = 0
            }
        }
    }
}
