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
import "../pages"

CoverBackground {
    id: cover

    Label {
        anchors {
            horizontalCenter: parent.horizontalCenter
            topMargin: Theme.paddingLarge
            top: parent.top
        }
        text: "Sudoku"
    }

    SudokuBoard {
        id: coverBoard
        staticBoard: true
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        cellSize: 22 / 234 * parent.width
        autoSetup: true
        opacity: 10
        onInactiveChanged: {
            if (inactive) {
                setup()
            }
        }
    }
    Timer {
        interval: 600
        running: true

        onTriggered: {
            coverBoard.setup();
        }
    }
}
