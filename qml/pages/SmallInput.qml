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
    property bool eraseEnabled: reset.enabled
    property bool dragEnabled: configurations.draggingEnabled
    property alias pencilEnabled: pencil.selected
    height:numpad.height + erase.height + erase.anchors.topMargin
    width:numpad.width

    Grid {
        id: numpad
        rows: 3
        columns: 3
        spacing: 10 / 32 * Theme.fontSizeMedium

        Repeater {
            model: 9

            Button {
                width: 90 / 32 * Theme.fontSizeMedium
                height: width
                text: index + 1
                color: drag.active ? Theme.highlightColor : Theme.primaryColor
                preventStealing: dragEnabled

                onClicked: entry(index + 1)

                drag.target: dragEnabled ? drag.active ? dragComponent.createObject(this, {index: index + 1}) : this : undefined
            }
        }
    }

    Button {
        id: erase
        anchors {
            top: numpad.bottom
            left: parent.left
            topMargin: 10
        }

        width: 90 / 32 * Theme.fontSizeMedium
        height: width
        text: 'Erase'
        color: drag.active ? Theme.highlightColor : Theme.primaryColor
        preventStealing: dragEnabled
        enabled: eraseEnabled

        onClicked: {
            pencil.selected = false
            entry(0)
        }

        drag.target: dragEnabled ? drag.active ? dragComponent.createObject(this, {trueOpacity: 1, iconVisible: true}) : this : undefined
    }
    Button {
        id: pencil
        property bool selected: false
        anchors {
            top: numpad.bottom
            right: parent.right
            topMargin: 10
        }

        width: erase.width
        height: width
        text: 'Pencil'
        color: selected ? Theme.highlightColor : Theme.primaryColor
        onClicked: selected = !selected
    }
}
