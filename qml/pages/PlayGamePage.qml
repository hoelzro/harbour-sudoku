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
            pencilEnabled: numinput.item ? numinput.item.pencilEnabled : false
            onInactiveChanged: {
                if (isSetup) {
                    if (inactive) {
                        save();
                    }
                }
            }
        }

        Loader {
            id: numinput
            source: Screen.width / Screen.height < 0.75 ? "SmallInput.qml" : "LargeInput.qml"
            transformOrigin: page.isLandscape ? Item.Left : Item.Top
            scale: Screen.width / Screen.height >= 0.75 && page.isLandscape ? (availableSpace - (70 / 960 * Screen.height)) / width
                                                                            : (availableSpace - (70 / 960 * Screen.height)) / height

            property int availableSpace: Screen.height - (board.y + board.height)
            property int margin: page.isLandscape
                                 ? (availableSpace - (width*scale))/2
                                 : (availableSpace - (height*scale))/2

            x: page.isLandscape ? board.x + board.width + margin : 0
            y: page.isLandscape ? 0 : board.y + board.height + margin
            anchors.verticalCenter: page.isLandscape ? parent.verticalCenter : undefined
            anchors.horizontalCenter: page.isLandscape ? undefined : parent.horizontalCenter
            onLoaded: {
                if (item)
                    item.pencilEnabled
            }
        }

        Connections {
            target: numinput.item
            onEntry: board.updateSelection(value == 0 ? null : value)
        }

        Component {
            id: dragComponent
            Item {
                property bool dragActive: parent.drag.active
                property var lastActiveDragTarget: null
                property var lastDragTarget: null
                property var mapped
                property var index
                property real trueOpacity: Theme.highlightBackgroundOpacity * 1.5
                property int dropSizeMultiplier: board.cellSize / 50
                property alias iconVisible: dragIcon.visible

                signal entry(int value)
                onEntry: board.updateSelection(value == 0 ? null : value)

                id: dragIndicator
                scale: 0.25 * dropSizeMultiplier
                opacity: 0
                x: parent.mouseX
                y: parent.mouseY

                onDragActiveChanged: {
                    if (!parent.drag.active) {
                        if (lastActiveDragTarget !== null && !lastActiveDragTarget.isInitial) {
                            mapped = parent.mapFromItem(lastActiveDragTarget,
                                                        lastActiveDragTarget.width/2 - width/2,
                                                        lastActiveDragTarget.height/2 - height/2);
                            state = "Entry";
                        }
                        else {
                            state = "NoEntry";
                        }
                    }
                }
                Drag.active: parent.drag.active
                Drag.onTargetChanged: {
                    if (parent.drag.active) lastActiveDragTarget = Drag.target;
                    if (Drag.target !== null) lastDragTarget = Drag.target;
                    if (lastActiveDragTarget === null) lastDragTarget.cellNotSelected();
                }

                Component.onCompleted: state = "Active"

                Label {

                    id: dragLabel
                    text: index ? index : ""
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeMedium * 4
                    x: - width/2
                    y: - height/2
                }

                Image {
                    id: dragIcon
                    source: "image://theme/icon-l-clear?" + Theme.highlightColor
                    visible: false
                    x: - width/2
                    y: - height/2
                }

                states: [
                    State {
                        name: "Entry"
                        PropertyChanges {
                            target: dragIndicator
                            scale: 0.25 * dropSizeMultiplier
                            opacity: trueOpacity === 1 ? 0 : 1
                            x: dragIndicator.mapped.x
                            y: dragIndicator.mapped.y
                        }
                    },
                    State {
                        name: "NoEntry"
                        PropertyChanges {
                            target: dragIndicator
                            scale: 0.25 * dropSizeMultiplier
                            opacity: 0
                        }
                    },
                    State {
                        name: "Active"
                        PropertyChanges {
                            target: dragIndicator
                            scale: 1
                            opacity: trueOpacity
                        }
                    }

                ]
                transitions: [
                    Transition {
                        to: "Entry"
                        SequentialAnimation {
                            ScriptAction {script: entry(0)}
                            ParallelAnimation {
                                NumberAnimation {
                                    target: dragIndicator
                                    property: "scale"
                                    duration: 200
                                    easing.type: Easing.InOutQuad
                                }
                                NumberAnimation {
                                    target: dragIndicator
                                    property: "opacity"
                                    duration: 200
                                    easing.type: Easing.InOutQuad
                                }
                                NumberAnimation {
                                    target: dragIndicator
                                    property: "y"
                                    duration: 200
                                    easing.type: Easing.InOutQuad
                                }
                                NumberAnimation {
                                    target: dragIndicator
                                    property: "x"
                                    duration: 200
                                    easing.type: Easing.InOutQuad
                                }
                            }
                            ScriptAction {script: {entry(index); dragIndicator.destroy();}}
                        }
                    },
                    Transition {
                        to: "NoEntry"
                        SequentialAnimation {
                            ParallelAnimation {
                                NumberAnimation {
                                    target: dragIndicator
                                    property: "scale"
                                    duration: 200
                                    easing.type: Easing.InOutQuad
                                }
                                NumberAnimation {
                                    target: dragIndicator
                                    property: "opacity"
                                    duration: 200
                                    easing.type: Easing.InOutQuad
                                }
                            }
                            ScriptAction {script: dragIndicator.destroy()}
                        }
                    },
                    Transition {
                        to: "Active"
                        ParallelAnimation {
                            NumberAnimation {
                                target: dragIndicator
                                property: "scale"
                                duration: 200
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                target: dragIndicator
                                property: "opacity"
                                duration: 200
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                ]
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
                text: "Settings"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl('Settings.qml'));
                }
            }
            MenuItem {
                text: "New Game"
                onClicked: {
                    if (board.isGameOver()) {
                        board.newGame();
                    }
                    else {
                    remorse.execute("Generating", board.newGame, 3000);
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
                enabled: reset.enabled
            }
            MenuItem {
                text: "Give Me a Hint"
                onClicked: {
                    board.giveHint();
                }
            }
            MenuItem {
                text: "Fill in pencil values"
                onClicked: {
                    board.generatePencilValues();
                }
            }
            MenuItem {
                id: reset
                text: "Reset Game"
                onClicked: {
                    if (board.isGameOver()) {
                        board.clearBoard();
                    }
                    else {
                    remorse.execute("Resetting", board.clearBoard, 3000);
                    }
                }
            }
        }
    }

    Component.onDestruction: {
        board.save();
    }
}
