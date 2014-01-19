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

Rectangle {
    property int cellSize
    property int blockNumber

    signal cellSelected (variant cell)

    width: cellSize * 3
    height: cellSize * 3
    color: "transparent"

    border.color: Theme.secondaryColor
    border.width: 2

    Grid {
        rows: 3
        columns: 3
        spacing: 0

        Repeater {
            id: cells
            model: 9

            Rectangle {
                id: self
                width: cellSize
                height: cellSize
                border.color: isHighlighted ? Theme.highlightColor : Theme.primaryColor
                border.width: isHighlighted ? 5 : 1
                color: isConflict ? Theme.secondaryHighlightColor : "transparent"

                property bool isHighlighted: false
                property int row:    Math.floor(blockNumber / 3) * 3 + Math.floor(index / 3)
                property int column: (blockNumber % 3) * 3 + (index % 3)
                property variant value: null
                property bool isConflict: false

                Text {
                    anchors.centerIn: parent
                    color: Theme.primaryColor

                    text: value == null ? '' : '' + value
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: cellSelected(self)
                }
            }
        }
    }

    function set(row, col, value) {
        var index = row * 3 + col;

        // XXX can we update the current binding?
        cells.itemAt(index).value = Qt.binding(function() { return value; });
    }

    function markAsConflict(row, col) {
        var index = row * 3 + col;
        cells.itemAt(index).isConflict = true;
    }

    function clearConflictMarks() {
        for(var row = 0; row < 3; row++) {
            for(var col = 0; col < 3; col++) {
                var index = row * 3 + col;
                cells.itemAt(index).isConflict = false;
            }
        }
    }
}
