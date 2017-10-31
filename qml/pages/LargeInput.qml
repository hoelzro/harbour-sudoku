/*
 * This file is part of harbour-sudoku.
 *
 * harbour-sudoku is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * harbour-sudoku is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with harbour-sudoku.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "."

Item {
    signal entry(int value)
    property var dragComponent
    property bool eraseEnabled
    property bool dragEnabled: configurations.draggingEnabled
    height:numpad.height
    width:numpad.width

    Grid {
        id: numpad
        rows: page.isLandscape ? 5 : 2
        columns: page.isLandscape ? 2 : 5
        spacing: 10 / 32 * Theme.fontSizeMedium

        Repeater {
            model: 10

            MouseArea {
                property color color: drag.active ? Theme.highlightColor : Theme.primaryColor
                id: mouseArea
                height: 90 / 32 * Theme.fontSizeMedium
                width: height
                preventStealing: dragEnabled
                enabled: index === 9 ? eraseEnabled : true

                Rectangle {
                    anchors.fill: parent
                    color: parent.pressed ? Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
                                          : Theme.rgba(parent.color, 0.2)
                    radius: Theme.paddingSmall
                    opacity: parent.enabled ? 1.0 : 0.4

                    Label {
                        text: index < 9 ? index + 1 : 'Erase'
                        anchors.centerIn: parent
                        color: mouseArea.pressed ? Theme.highlightColor : mouseArea.color
                    }
                }

                onClicked: {
                    if (index === 9) {
                        entry(0);
                    }
                    else entry(index + 1);
                }

                drag.target: dragEnabled
                             ? drag.active
                               ? index = 9
                                 ? dragComponent.createObject(this, {trueOpacity: 1, iconVisible: true})
                                 : dragComponent.createObject(this, {index: index + 1})
                               : this
                             : undefined
            }
        }
    }
}
