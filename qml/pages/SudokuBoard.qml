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
import QtQuick.LocalStorage 2.0
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

            var s = S.getSudoku(modelId);
            s.set(_currentSelection.row, _currentSelection.column, value);
        }

        for(var block_no = 0; block_no < 9; block_no++) {
            blocks.itemAt(block_no).clearConflictMarks();
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

    function isGameOver() {
        var s = S.getSudoku(modelId);
        return s.isGameOver();
    }

    function showConflicts() {
        var s         = S.getSudoku(modelId);
        var conflicts = s.getConflicts();

        for(var i = 0; i < conflicts.length; i++) {
            var data = getBlockForCoords(conflicts[i].row, conflicts[i].col);

            var block = data[0];
            var bRow  = data[1];
            var bCol  = data[2];

            block.markAsConflict(bRow, bCol);
        }
    }

    function giveHint() {
        var s    = S.getSudoku(modelId);
        var hint = s.getHint();

        if(hint == null) {
            return;
        }

        var data = getBlockForCoords(hint.row, hint.col);

        var block = data[0];
        var bRow  = data[1];
        var bCol  = data[2];

        if(_currentSelection) {
            _currentSelection.isHighlighted = false;
        }
        _currentSelection = block.getCell(bRow, bCol);
        _currentSelection.isHighlighted = true;
        updateSelection(hint.value);
    }

    function restore() {
        var db = LocalStorage.openDatabaseSync('harbour-sudoku', '1.0', 'Saved Game Data for Sudoku', 2000);

        var rows = [];

        try {
            db.transaction(function(txn) {
                var result = txn.executeSql('SELECT row, column, value FROM board');

                for(var i = 0; i < result.rows.length; i++) {
                    var row = result.rows.item(i);
                    rows.push({
                        row: row.row,
                        column: row.column,
                        value: row.value
                    });
                }
            });
        } catch(e) {
            var code = e.code;

            if(code !== SQLException.DATABASE_ERR) {
                throw e;
            }
        }

        return rows.length == 0 ? null : rows;
    }

    function save() {
        var db = LocalStorage.openDatabaseSync('harbour-sudoku', '1.0', 'Saved Game Data for Sudoku', 2000);
        var s  = S.getSudoku(modelId);

        db.transaction(function(txn) {
            txn.executeSql('CREATE TABLE IF NOT EXISTS board (row INTEGER NOT NULL, column INTEGER NOT NULL, value INTEGER NOT NULL)');
            txn.executeSql('DELETE FROM board');

            for(var row = 0; row < 9; row++) {
                for(var col = 0; col < 9; col++) {
                    var value = s.get(row, col);

                    if(value != null) {
                        txn.executeSql('INSERT INTO board VALUES (?, ?, ?)', [ row, col, value ]);
                    }
                }
            }
        });
    }

    function reset() {
        // XXX code duplication =(
        modelId = S.makeSudoku();
        var s = S.getSudoku(modelId);

        for(var row = 0; row < 9; row++) {
            for(var col = 0; col < 9; col++) {
                var value = s.get(row, col);

                var data  = getBlockForCoords(row, col);
                var block = data[0];
                var bRow  = data[1];
                var bCol  = data[2];

                block.set(bRow, bCol, value);
            }
        }
    }

    Component.onCompleted: {
        var rows = restore();

        modelId = S.makeSudoku(rows);
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
