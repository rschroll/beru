/* Copyright 2015 Robert Schroll
 *
 * This file is part of Beru and is distributed under the terms of
 * the GPL. See the file COPYING for full details.
 */

import QtQuick 2.0
import QtGraphicalEffects 1.0
import Ubuntu.Components 1.1


AbstractButton {
    id: floatingButton

    property int size: units.gu(8)
    property int margin: units.gu(1)
    property color color: "white"
    property color borderColor: Theme.palette.normal.foregroundText

    width: size
    height: size

    Item {
        id: container
        anchors.fill: parent

        Rectangle {
            anchors {
                margins: margin
                fill: parent
            }
            radius: width/2
            color: floatingButton.color
            border {
                color: borderColor
                width: units.dp(1)
            }

            Image {
                id: icon
                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }
                width: parent.width/2
                height: width
                source: floatingButton.iconSource
                opacity: floatingButton.enabled ? 1.0 : 0.5
            }
        }
    }

    DropShadow {
        anchors.fill: container
        radius: 1.5*margin
        samples: 16
        source: container
        color: "black"
        verticalOffset: 0.25*margin
    }
}
