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

Rectangle {
    property int cellSize
    property int blockNumber
    property bool dragEnabled: configurations.draggingEnabled

    signal cellSelected (variant cell)
    signal entry (int value)

    width: cellSize * 3
    height: cellSize * 3
    color: "transparent"

    border.color: Theme.secondaryColor
    border.width: Math.max(Math.round(2/50*cellSize),2)

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
                border.width: isHighlighted ? Math.max(Math.round(3/50*cellSize),2) : Math.max(Math.round(1/50*cellSize),1)
                color: isConflict ? Theme.secondaryHighlightColor : "transparent"

                property bool isHighlighted: false
                property int row:    Math.floor(blockNumber / 3) * 3 + Math.floor(index / 3)
                property int column: (blockNumber % 3) * 3 + (index % 3)
                property int pencil: 0
                property variant value: null
                onValueChanged: {
                    if (value === null) {
                        selfLabel.state = "Empty"
                    }
                    else if (value !== null) {
                        selfLabel.state = ""
                        selfLabel.text = '' + value
                    }
                    pencil = 0
                }

                property bool isConflict: false
                property bool isInitial: false

                PencilOverlay {
                    id: pencilOverlay
                    anchors.fill: parent
                    value: self.pencil
                    visible: selfLabel.state === "Empty"                }

                Text {
                    id: selfLabel
                    anchors.centerIn: parent
                    color: isInitial ? Theme.primaryColor : Theme.highlightColor
                    font.pointSize: Math.round(cellSize * (24/50))

                    onTextChanged: {
                        if (!setUpTimer.running) {
                            valueBehavior.enabled = false
                            scale = 1.2
                            valueBehavior.enabled = true
                            scale = 1
                        }
                    }

                    Behavior on scale {
                        id: valueBehavior
                        enabled: false
                        NumberAnimation {duration: 200; easing.type: Easing.OutQuart}
                    }

                    states: [
                        State {
                            name: "Empty"
                            PropertyChanges {
                                target: selfLabel
                                text: ''
                            }
                        }
                    ]
                    transitions: [
                        Transition {
                            to: "Empty"
                            SequentialAnimation {
                                NumberAnimation {
                                    target: selfLabel
                                    property: "opacity"
                                    to: 0
                                    duration: 150
                                    easing.type: Easing.InOutQuad
                                }
                                PropertyAction {
                                    target: selfLabel
                                    property: "text"
                                }
                                PropertyAction {
                                    target: selfLabel
                                    property: "opacity"
                                    value: 1
                                }
                            }
                        }
                    ]
                    Timer {
                        id: setUpTimer
                        interval: 200
                        running: true
                    }
                }

                DropArea {
                    signal cellNotSelected
                    property bool isInitial: self.isInitial
                    onCellNotSelected: cellSelected(null)
                    anchors.fill: parent
                    onEntered: cellSelected(self)
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    onClicked: cellSelected(self)
                    preventStealing: dragEnabled && !self.isInitial && self.isHighlighted && selfLabel.text !== ''

                    drag.target: dragEnabled && !self.isInitial && self.isHighlighted && selfLabel.text !== '' ? this : undefined

                    drag.onActiveChanged: {
                        if (drag.active) {
                            drag.target = dragComponent.createObject(this,{index: selfLabel.text});
                            updateSelection(null);
                        }
                        else {
                            drag.target = Qt.binding(function() {return dragEnabled && !self.isInitial && self.isHighlighted && selfLabel.text !== ''
                                                                 ? parent
                                                                 : undefined});
                        }
                    }
                }
            }
        }
    }

    function set(row, col, value, isInitial, pencil) {
        var index = row * 3 + col;
        var cell  = cells.itemAt(index);

        // XXX can we update the current binding?
        cell.value     = Qt.binding(function() { return value; });
        cell.isInitial = isInitial;
        cell.pencil = pencil;
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

    function getCell(row, col) {
        var index = row * 3 + col;

        return cells.itemAt(index);
    }
}
