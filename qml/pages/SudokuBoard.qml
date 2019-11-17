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
import Sailfish.Silica 1.0
import "."
import "Sudoku.js" as S

Grid {
    id: oBoard
    rows: 3
    columns: 3
    spacing: Math.round(Screen.height * (5 / 960))

    property int cellSize
    property var _currentSelection: null
    property int modelId: -1
    property bool resume: true
    property bool autoSetup: true
    property bool isSetup: false
    property bool inactive: Qt.application.state === Qt.ApplicationInactive
    property bool staticBoard: false
    property bool pencilEnabled: false

    property var sudokuWorker: null

    function clearConflicts() {
        for(var block_no = 0; block_no < 9; block_no++) {
            blocks.itemAt(block_no).clearConflictMarks();
        }
    }

    function toggleBitValue(field, index) {
        var isSet = field & (1 << index)
        return setBitValue(field, index, !isSet)
    }

    function setBitValue(field, index, value) {
        if (value)
            field |= (1 << index)
        else
            field &= ~(1 << index)
        return field
    }

    function updateSelection(value) {
        if(_currentSelection) {
            var s = S.getSudoku(modelId);
            if(s.isInitialCell(_currentSelection.row, _currentSelection.column)) {
                return;
            }

            if (oBoard.pencilEnabled) {
                if (_currentSelection.value === null) {
                    _currentSelection.pencil = toggleBitValue(_currentSelection.pencil, value-1);
                    s.setPencil(_currentSelection.row, _currentSelection.column, _currentSelection.pencil)
                } else {
                    return
                }
            } else {
                _currentSelection.value = value;
                _currentSelection.pencil = 0
                s.set(_currentSelection.row, _currentSelection.column, value);
                s.setPencil(_currentSelection.row, _currentSelection.column, 0);
            }
        }

        clearConflicts();

        if(isGameOver()) {
            pageStack.push(Qt.resolvedUrl('Victory.qml'), {
                board: this
            });
        }
        setResetAvailablity();
    }

    function clearBoard() {
        var s = S.getSudoku(modelId);
        for(var row = 0; row < 9; row++) {
          for(var col = 0; col < 9; col++) {
            if(s.isInitialCell(row, col)) {
              continue;
            }
            var data = getBlockForCoords(row, col);
            var block = data[0];
            var blockRow = data[1];
            var blockCol = data[2];
            block.set(blockRow, blockCol, null, false, 0);
            s.set(row, col, null);
            s.setPencil(row, col, 0);
          }
        }
        clearConflicts();
        reset.enabled = false;

    }

    Repeater {
        id: blocks
        model: 9

        SudokuBlock {
            cellSize: parent.cellSize
            blockNumber: index

            onCellSelected: {
                if(_currentSelection) {
                    _currentSelection.isHighlighted = false;
                }
                _currentSelection = cell;
                if (cell !== null) {
                    cell.isHighlighted = true;
                }
            }
            onEntry: updateSelection(value)
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

    function setResetAvailablity() {
        var s = S.getSudoku(modelId);
        for(var row = 0; row < 9; row++) {
          for(var col = 0; col < 9; col++) {
              if (s.get(row, col) !== null || s.getPencil(row, col) !== 0) {
                  if (!s.isInitialCell(row, col)) {
                      reset.enabled = true;
                      var foundUserInput = true;
                      return;
                  }
                  else {
                      foundUserInput = false;
                  }
              }
          }
        }
        if (!foundUserInput) {
            reset.enabled = false;
        }
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

        if(hint === null) {
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

    function openConnection() {
        var db = LocalStorage.openDatabaseSync('harbour-sudoku', '', 'Saved Game Data for Sudoku', 2000);

        if(db.version === '') {
            db.changeVersion('', '2.1', function(txn) {
                txn.executeSql('CREATE TABLE board (row INTEGER NOT NULL, column INTEGER NOT NULL, value INTEGER NOT NULL, is_initial INTEGER NOT NULL DEFAULT 0, pencil INTEGER NOT NULL DEFAULT 0)');
            });
        }
        if(db.version === '1.0') {
            db.changeVersion('1.0', '2.0', function(txn) {
                txn.executeSql('ALTER TABLE board ADD COLUMN is_initial INTEGER NOT NULL DEFAULT 0');
            });
        }
        if(db.version === '2.0') {
            db.changeVersion('2.0', '2.1', function(txn) {
                txn.executeSql('ALTER TABLE board ADD COLUMN pencil INTEGER NOT NULL DEFAULT 0');
            });
        }

        return db;
    }

    function restore() {
        var db = openConnection();

        var rows = [];

        try {
            db.readTransaction(function(txn) {
                var result = txn.executeSql('SELECT row, column, value, is_initial, pencil FROM board');

                for(var i = 0; i < result.rows.length; i++) {
                    var row = result.rows.item(i);
                    rows.push({
                        row: row.row,
                        column: row.column,
                        value: row.value === 0 ? null : row.value,
                        isInitial: row.is_initial,
                        pencil: row.pencil
                    });
                }
            });
        } catch(e) {
            var code = e.code;

            if(code !== SQLException.DATABASE_ERR) {
                throw e;
            }
        }

        return rows.length === 0 ? null : rows;
    }

    function save() {
        var db = openConnection();
        var s  = S.getSudoku(modelId);

        db.transaction(function(txn) {
            txn.executeSql('DELETE FROM board');

            for(var row = 0; row < 9; row++) {
                for(var col = 0; col < 9; col++) {
                    var value     = s.get(row, col);
                    var isInitial = s.isInitialCell(row, col);
                    var pencil    = s.getPencil(row, col);

                    if(value !== null || pencil > 0) {
                        if (value === null)
                            value = 0
                        txn.executeSql('INSERT INTO board VALUES (?, ?, ?, ?, ?)', [ row, col, value, isInitial ? 1 : 0, pencil]);
                    }
                }
            }
        });
    }

    function onBoardLoaded(state) {
        if(state.bg) {
            pageStack.pop(); // remove the Generating page
        }

        var rows = state.rows;
        modelId  = S.makeSudoku(rows);
        var s    = S.getSudoku(modelId);

        for(var row = 0; row < 9; row++) {
            for(var col = 0; col < 9; col++) {
                var value = s.get(row, col);
                var pencil = s.getPencil(row, col);

                var data  = getBlockForCoords(row, col);
                var block = data[0];
                var bRow  = data[1];
                var bCol  = data[2];
                if (block)
                    block.set(bRow, bCol, value, s.isInitialCell(row, col), pencil);
            }
        }
        if (!staticBoard) {
            setResetAvailablity();
        }
    }

    function generateBoardInBackground(replace) {
        if(! sudokuWorker) {
            sudokuWorker = Qt.createQmlObject("import QtQuick 2.0; WorkerScript { source: 'Sudoku.js'; onMessage: onBoardLoaded(messageObject) }", oBoard);
        }
        sudokuWorker.sendMessage();
        if(replace) {
            pageStack.replace(Qt.resolvedUrl('Generating.qml'), {}, PageStackAction.Immediate);
        } else {
            pageStack.push(Qt.resolvedUrl('Generating.qml'), {}, PageStackAction.Immediate);
        }
    }

    function newGame() {
        generateBoardInBackground();
        clearConflicts();
        reset.enabled = false;
    }

    function setup() {
        if(resume) {
            var rows = restore();
            if(rows !== null) {
                onBoardLoaded({
                    rows: rows,
                    bg:   false
                });
                return isSetup = true;
            }
        }

        generateBoardInBackground();
    }

    Component.onCompleted: {
        if(autoSetup) {
            setup();
        }
    }
// some physical keyboard support
    Keys.onPressed: {
        if (event.key === Qt.Key_Backspace) {
            updateSelection(null);
        }
        if (event.key >= Qt.Key_0 && event.key <= Qt.Key_9) {
            var value = event.key - Qt.Key_0;
            updateSelection(value);
        }
        if (event.key === Qt.Key_Left || Qt.Key_Up || Qt.Key_Right || Qt.Key_Down) { // not necessary the best way to put it but works
            if (_currentSelection === null) {
                _currentSelection = blocks.itemAt(0).getCell(0,0);
                _currentSelection.isHighlighted = true;
                return;
            }
            if (event.key === Qt.Key_Left && _currentSelection.column - 1 < 0) {
                var data = getBlockForCoords(_currentSelection.row, 8);
            }
            else if (event.key === Qt.Key_Left) {
                var data = getBlockForCoords(_currentSelection.row, _currentSelection.column - 1);
            }

            if (event.key === Qt.Key_Up && _currentSelection.row - 1 < 0) {
                var data = getBlockForCoords(8, _currentSelection.column);
            }
            else  if (event.key === Qt.Key_Up) {
                var data = getBlockForCoords(_currentSelection.row - 1, _currentSelection.column);
            }

            if (event.key === Qt.Key_Right && _currentSelection.column + 1 > 8) {
                var data = getBlockForCoords(_currentSelection.row, 0);
            }
            else if (event.key === Qt.Key_Right) {
                var data = getBlockForCoords(_currentSelection.row, _currentSelection.column + 1);
            }

            if (event.key === Qt.Key_Down && _currentSelection.row + 1 > 8) {
                var data = getBlockForCoords(0, _currentSelection.column);
            }
            else if (event.key === Qt.Key_Down) {
                var data = getBlockForCoords(_currentSelection.row + 1, _currentSelection.column);
            }

            if (data === undefined) {
                return;
            }

            var block = data[0];
            var bRow  = data[1];
            var bCol  = data[2];

            if(_currentSelection) {
                _currentSelection.isHighlighted = false;
            }
            _currentSelection = block.getCell(bRow, bCol);
            _currentSelection.isHighlighted = true;
        }
    }
}
