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

Grid {
    id: root
    property bool ready: false
    property int value: 0 //Bit field using 9 bits
    rows: 3
    columns: 3
    spacing: 0

    Repeater {
        id: cells
        model: 9
        anchors.fill: parent
        anchors.margins: Math.round(cellSize * (3/50))

        Text {
            id: pencilText
            property bool show: root.value & (1 << index)
            width: parent.width/3
            height: parent.height/3
            horizontalAlignment: Text.AlignHCenter
            color: Theme.primaryColor
            font.pointSize: Math.round(cellSize * (10/50))
            text: '' + (index + 1)
            opacity: show ? 1.0 : 0
        }
    }
    Component.onCompleted: ready = true
}
