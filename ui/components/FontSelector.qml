/*
 * Copyright 2012 Canonical Ltd.
 * Copyright 2013 Robert Schroll
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1

Empty {
    id: selector
    __height: column.height

    /*!
      \preliminary
      The text that is shown in the list item as a label.
      \qmlproperty string text
     */

    /*!
      \preliminary
      The location of the icon to show in the list item (optional), or an Item that is
      shown on the left side inside the list item. The icon will automatically be
      anchored to the left side of the list item, and if its height is undefined, to the top
      and bottom of the list item.
      \qmlproperty variant icon
    */
    property alias icon: selectorMain.icon

    /*!
      \preliminary
      The location of the icon to show in the list item if iconSource failed to load (optional).
      \qmlproperty url fallbackIconSource
     */
    property alias fallbackIconSource: selectorMain.fallbackIconSource

    /*!
      \internal
      \deprecated
      Width of the icon to be displayed
    */
    property real __iconWidth

    /*!
      \internal
      \deprecated
      Height of the icon to be displayed
    */
    property real __iconHeight

    /*!
      \internal
      \deprecated
      The margins on the left side of the icon.
     */
    property real __leftIconMargin

    /*!
      \internal
      \deprecated
      The margins on the right side of the icon.
     */
    property real __rightIconMargin

    /*!
      \preliminary
      Show or hide the frame around the icon
      \qmlproperty bool iconFrame
     */
    property alias iconFrame: selectorMain.iconFrame

    /*!
      \preliminary
      The list of values that will be shown under the label text
     */
    property variant values

    /*!
      \preliminary
      The index of the currently selected element from the \l values array.
     */
    property int selectedIndex: 0

    /*!
      \preliminary
      Specifies whether the selector is 'open' or 'closed'.
     */
    property bool expanded: false

    showDivider: false

    Column {
        id: column
        anchors {
            left: parent.left
            right: parent.right
            topMargin: units.dp(2)
            bottomMargin: units.dp(2)
        }

        Base {
            id: selectorMain
            height: units.gu(6)
            showDivider: true
            onClicked: selector.expanded = !selector.expanded
            selected: selector.selected

            LabelVisual {
                id: label
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                }
                text: selector.text
                width: Math.min(implicitWidth, parent.width * 0.8)
            }
            LabelVisual {
                id: valueLabel
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: accordion.left
                    rightMargin: selector.__contentsMargins
                    leftMargin: selector.__contentsMargins
                    left: label.right
                }
                fontSize: "small"
                text: selector.values[selector.selectedIndex]
                font.family: selector.values[selector.selectedIndex] == "Default" ? "Ubuntu" : selector.values[selector.selectedIndex]
                font.bold: selector.expanded
                horizontalAlignment: Text.AlignRight
            }
            Item {
                id: accordion
                width: accordionIcon.width
                anchors {
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                }
                Image {
                    id: accordionIcon
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    // TODO: Replace this placeholder graphic with the official one.
                    source: "/usr/lib/x86_64-linux-gnu/qt5/qml/Ubuntu/Components/ListItems/artwork/ListItemProgressionArrow.png"
                    opacity: enabled ? 1.0 : 0.5
                    rotation: expanded ? 270 : 90
                    width: implicitWidth / 1.5
                    height: implicitHeight / 1.5

                    states: [
                        State {
                            name: "expanded"
                            when: selector.expanded
                            PropertyChanges { target: accordionIcon; rotation: 270 }
                        }, State {
                            name: "closed"
                            when: !selector.expanded
                            PropertyChanges { target: accordionIcon; rotation: 90 }
                        }
                    ]

                    transitions: Transition {
                        UbuntuNumberAnimation {
                            target: accordionIcon
                            properties: "rotation"
                            duration: UbuntuAnimation.SnapDuration
                        }
                    }
                }
            }
        }

        Repeater {
            id: valueRepeater
            property int valueHeight: selector.expanded ? units.gu(5) : 0

            states: [ State {
                    name: "expanded"
                    when: selector.expanded
                    PropertyChanges {
                        target: valueRepeater
                        valueHeight: units.gu(5)
                    }
                }, State {
                    name: "closed"
                    when: !selector.expanded
                    PropertyChanges {
                        target: valueRepeater
                        valueHeight: 0
                    }
                }
            ]

            transitions: Transition {
                UbuntuNumberAnimation {
                    target: valueRepeater
                    properties: "valueHeight"
                    duration: UbuntuAnimation.SnapDuration
                }
            }

            model: selector.values
            Rectangle {
                color: Qt.lighter(Theme.palette.normal.base)
                height: valueRepeater.valueHeight
                width: parent.width

                Empty {
                    id: valueBase
                    height: parent.height
                    visible: valueBase.height > 0
                    onClicked: {
                        selector.selectedIndex = index
                        selector.expanded = false
                    }

                    selected: index === selector.selectedIndex

                    LabelVisual {
                        text: modelData
                        anchors {
                            left: parent.left
                            leftMargin: units.gu(3)
                            verticalCenter: parent.verticalCenter
                        }
                        font.family: modelData == "Default" ? "Ubuntu" : modelData
                        font.bold: valueBase.selected
                        property real heightMargin: valueBase.height - implicitHeight
                        visible: heightMargin > 0
                        // fade in/out the values when expanding/contracting the selector.
                        opacity: heightMargin < 10 ? heightMargin/10 : 1
                    }
                }
            }
        }
    }
}
