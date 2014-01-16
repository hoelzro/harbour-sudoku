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
import "."
import "Sudoku.js" as S

Grid {
    rows: 3
    columns: 3
    spacing: 5

    property int cellSize
    property variant _currentSelection: null
    property int modelId: null

    function updateSelection(value) {
        if(_currentSelection) {
            _currentSelection.value = value;
        }
    }

    Repeater {
        id: blocks
        model: 9

        SudokuBlock {
            cellSize: parent.cellSize
            blockNumber: index

            onCellSelected: {
                if(_currentSelection) {
                    _currentSelection.isHighlighted = false
                }
                _currentSelection = cell
                cell.isHighlighted = true;
            }
        }
    }

    function getBlockForCoords(row, col) {
        var blockNo  = Math.floor(col / 3) + (row - row % 3);
        var blockRow = row % 3;
        var blockCol = col % 3;

        return [
            blocks.itemAt(blockNo),
            blockRow,
            blockCol
        ];
    }

    Component.onCompleted: {
        modelId = S.makeSudoku();
        var s = S.getSudoku(modelId);

        for(var row = 0; row < 9; row++) {
            for(var col = 0; col < 9; col++) {
                var value = s.get(row, col);

                if(value === null) {
                    continue;
                }

                var data  = getBlockForCoords(row, col);
                var block = data[0];
                var bRow  = data[1];
                var bCol  = data[2];

                block.set(bRow, bCol, value);
            }
        }
    }
}
