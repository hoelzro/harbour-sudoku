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
    id: page
    allowedOrientations: defaultAllowedOrientations
    property alias resume: board.resume

    SilicaFlickable {
        id: silica
        anchors.fill: parent
        contentHeight: page.height

        SudokuBoard {
            id: board
            y: Math.round(Screen.height * (40 / 960))
            x: (Screen.width - width)/2
            cellSize: (Screen.width - 2*y - 2*board.spacing) / 9
            focus: true
            onInactiveChanged: {
                if (isSetup) {
                    if (inactive) {
                        save();
                    }
                }
            }
        }

        SmallInput {
            id: numinput
            transformOrigin: page.isLandscape ? Item.Left : Item.Top
            scale: (ias - (70 / 960 * Screen.height)) / height

            property int ias: Screen.height - (board.y + board.height)
            property int margin: {
                page.isLandscape ? (ias - (width*scale))/2 :
                                   (ias - (height*scale))/2
            }

            x: page.isLandscape ? board.x + board.width + margin : 0
            y: page.isLandscape ? 0 : board.y + board.height + margin
            anchors.verticalCenter: page.isLandscape ? parent.verticalCenter : undefined
            anchors.horizontalCenter: page.isLandscape ? undefined : parent.horizontalCenter
            onEntry: {
                board.updateSelection(value == 0 ? null : value);
            }
        }

        RemorsePopup { id: remorse }

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
                    if (board.isGameOver()) {
                        board.newGame();
                    }
                    else {
                    remorse.execute("Generating", board.newGame);
                    }
                }
            }
        }
        PushUpMenu {
            //in-game functions
            MenuItem {
                text: "Show Conflicts"
                onClicked: {
                    board.showConflicts();
                }
            }
            MenuItem {
                text: "Give Me a Hint"
                onClicked: {
                    board.giveHint();
                }
            }
            MenuItem {
                id: reset
                text: "Reset Game"
                onClicked: {
                    if (board.isGameOver()) {
                        board.clearBoard();
                        enabled = false;
                    }
                    else {
                    remorse.execute("Resetting", board.clearBoard);
                    }
                }
            }
        }
    }

    Component.onDestruction: {
        board.save();
    }
}
