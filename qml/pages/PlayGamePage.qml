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

Page {

    property alias resume: board.resume

    SilicaFlickable {
        anchors.fill: parent

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 40
            spacing: 20

            SudokuBoard {
                id: board
                anchors.topMargin: 10

                cellSize: 50
            }

            NumberInput {
                anchors.horizontalCenter: parent.horizontalCenter

                onEntry: {
                    board.updateSelection(value == 0 ? null : value);
                }
            }
        }

        PullDownMenu {
            MenuItem {
                text: "About This App"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl('AboutPage.qml'));
                }
            }

            MenuItem {
                text: "New Game"
                onClicked: {
                    board.reset();
                }
            }

            MenuItem {
                text: "Give Me a Hint"
                onClicked: {
                    board.giveHint();
                }
            }

            MenuItem {
                text: "Show Conflicts"
                onClicked: {
                    board.showConflicts();
                }
            }
        }
    }

    Component.onDestruction: {
        board.save();
    }
}
