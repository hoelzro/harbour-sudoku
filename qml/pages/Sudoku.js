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

// based on algorithm described in http://zhangroup.aporc.org/images/files/Paper_3485.pdf

var Sudoku = (function() {
    const GRID_SIZE      = 9;
    const BLOCK_SIZE     = 3;
    const STARTING_CELLS = 11; // determined from paper, hardcoded for 9x9

    var ArrayUtils = {};

    ArrayUtils.grep = function grep(array, predicate) {
        var result = [];

        for(var i = 0; i < array.length; i++) {
            if(predicate(array[i])) {
                result.push(array[i]);
            }
        }

        return result;
    };

    ArrayUtils.concatMap = function concatMap(array, callback) {
        var result = [];

        for(var i = 0; i < array.length; i++) {
            var subresult = callback(array[i]);

            for(var j = 0; j < subresult.length; j++) {
                result.push(subresult[j]);
            }
        }

        return result;
    };

    ArrayUtils.flatten = function flatten(array) {
        return ArrayUtils.concatMap(array, function(value) {
            if(typeof(value) == 'object' && value.hasOwnProperty('length')) {
                return ArrayUtils.flatten(value);
            } else {
                return [ value ];
            }
        });
    };

    ArrayUtils.classify = function classify(array, classifier) {
        var result = [];

        for(var i = 0; i < array.length; i++) {
            var index = classifier(array[i]);
            if(! result[index]) {
                result[index] = [];
            }
            result[index].push(array[i]);
        }

        return result;
    };

    ArrayUtils.min = function min(values, getValue) {
        var minIndex = null;
        var minValue = null;

        for(var i = 0; i < values.length; i++) {
            var value = getValue(values[i]);

            if(minValue === null || value < minValue) {
                minValue = value;
                minIndex = i;
            }
        }

        return values[minIndex];
    };

    ArrayUtils.range = function range(start, end) {
        var values = [];

        for(var i = start; i <= end; i++) {
            values.push(i);
        }

        return values;
    };

    ArrayUtils.shuffle = function shuffle(array) {
        var result = [];
        var struck = [];

        for(var i = 0; i < array.length; i++) {
            var k = Math.floor(Math.random() * (array.length - i));

            for(var j = 0; j < array.length; j++) {
                if(struck[j]) {
                    continue;
                } else {
                    k--;
                }

                if(k < 0) {
                    struck[j] = true;
                    result.push(array[j]);
                    break;
                }
            }
        }

        return result;
    };

    ArrayUtils.pluck = function pluck(array, indices) {
        var values = [];

        for(var i = 0; i < indices.length; i++) {
            values.push(array[ indices[i] ]);
        }
        return values;
    }

    ArrayUtils.pick = function pick(array, numElements) {
        var indices = ArrayUtils.shuffle(ArrayUtils.range(0, array.length - 1));
        var result  = ArrayUtils.pluck(array, indices.slice(0, numElements));
        return numElements == 1 ? result[0] : result;
    };

    var HashUtils = {};

    HashUtils.pairs = function pairs(hash) {
        var result = [];

        for(var k in hash) {
            if(hash.hasOwnProperty(k)) {
                result.push({ key: k, value: hash[k] });
            }
        }

        return result;
    };

    HashUtils.size = function size(hash) {
        var count = 0;

        for(var k in hash) {
            if(hash.hasOwnProperty(k)) {
                count++;
            }
        }

        return count;
    };

    var Set = function Set(elements) {
        for(var i = 0; i < elements.length; i++) {
            var e = elements[i];

            this[e] = e;
        }
    };

    Set.prototype.forEach = function forEach(action) {
        for(var k in this) {
            if(! this.hasOwnProperty(k)) {
                continue;
            }
            action(this[k]);
        }
    };

    var Cell = function Cell(row, column) {
        this.row    = row;
        this.column = column;
        this.value  = null;
    };

    Cell.prototype.getRow = function getRow() {
        return this.row;
    };

    Cell.prototype.getColumn = function getColumn() {
        return this.column;
    };

    Cell.prototype.getBlock = function getBlock() {
        return Math.floor(this.column / BLOCK_SIZE) + (this.row - this.row % BLOCK_SIZE);
    };

    Cell.prototype.getValue = function getValue() {
        return this.value;
    };

    Cell.prototype.setValue = function setValue(value) {
        return this.value = value;
    };

    Cell.prototype.toString = function toString() {
        /* we can't include the value, otherwise hash is f'ed up =( */
        return '(' + this.row + ', ' + this.column + ')';
    }

    var Sudoku = function Sudoku() {
        this.cells = [];

        for(var rowNum = 0; rowNum < GRID_SIZE; rowNum++) {
            var row = [];
            this.cells.push(row);

            for(var colNum = 0; colNum < GRID_SIZE; colNum++) {
                row.push(new Cell(rowNum, colNum));
            }
        }
    }

    Sudoku.prototype.toString = function toString() {
        var parts = [];
        var cells = this.cells;

        parts.push('┌───┬───┬───┰───┬───┬───┰───┬───┬───┐\n');
        for(var rowNum = 1; rowNum <= GRID_SIZE; rowNum++) {
            var row = cells[rowNum - 1];

            parts.push('│');
            for(var colNum = 1; colNum <= GRID_SIZE; colNum++) {
                var cell  = row[colNum - 1];
                var value = cell.getValue();
                if(value === null) {
                    value = ' ';
                }

                parts.push(' ' + value + ' ');

                if(colNum != 9) {
                    if(colNum % 3 == 0 ) {
                        parts.push('┃');
                    } else {
                        parts.push('│');
                    }
                }
            }
            parts.push('│\n');

            if(rowNum != 9) {
                if(rowNum % 3 == 0) {
                    parts.push('┝━━━┿━━━┿━━━╋━━━┿━━━┿━━━╋━━━┿━━━┿━━━┥\n');
                } else {
                    parts.push('├───┼───┼───╂───┼───┼───╂───┼───┼───┤\n');
                }
            }
        }
        parts.push('└───┴───┴───┸───┴───┴───┸───┴───┴───┘\n');

        return parts.join('');
    }

    Sudoku.prototype.set = function set(row, col, value) {
        this.cells[row][col].setValue(value);
    }

    Sudoku.prototype.get = function get(row, col) {
        return this.cells[row][col].getValue();
    };

    var findRelatedCells = function findRelatedCells(cells) {
        var rowToCells   = ArrayUtils.classify(cells, function(cell) { return cell.getRow() });
        var colToCells   = ArrayUtils.classify(cells, function(cell) { return cell.getColumn() });
        var blockToCells = ArrayUtils.classify(cells, function(cell) { return cell.getBlock() });

        var related = {};

        for(var i = 0; i < cells.length; i++) {
            var cell = cells[i];

            var relations = new Set(ArrayUtils.flatten([
                ArrayUtils.grep(rowToCells[ cell.getRow() ],    function(otherCell) { return cell.getBlock() != otherCell.getBlock() }),
                ArrayUtils.grep(colToCells[ cell.getColumn() ], function(otherCell) { return cell.getBlock() != otherCell.getBlock() }),
                ArrayUtils.grep(blockToCells[ cell.getBlock() ], function(otherCell) { return cell != otherCell })
            ]));

            related[cell] = relations;
        }

        return related;
    };

    var solveHelper = function solveHelper(s, cellLookup, relatedCells, possibleValues) {
        if(HashUtils.size(possibleValues) == 0) {
            return true;
        }

        var minPair = ArrayUtils.min(HashUtils.pairs(possibleValues), function(pair) { return pair.value.length });
        var minCell = cellLookup[ minPair.key ];
        var choices = minPair.value;

        for(var i = 0; i < choices.length; i++) {
            var choice = choices[i];

            minCell.setValue(choice);

            var newPossibleValues = {};

            for(var cell in possibleValues) {
                if(!possibleValues.hasOwnProperty(cell)) {
                    continue;
                }

                if(relatedCells[minCell][cell]) {
                    newPossibleValues[cell] = ArrayUtils.grep(possibleValues[cell], function(value) {
                        return value != choice;
                    });
                } else {
                    newPossibleValues[cell] = possibleValues[cell];
                }
            }

            delete newPossibleValues[minCell];
            if(solveHelper(s, cellLookup, relatedCells, newPossibleValues)) {
                return true;
            }
        }
        minCell.setValue(null);

        return false;
    };

    var DIFFICULTIES = [
        ArrayUtils.range(20, 30),
    ];

    var digOut = function digOut(s, difficulty) {
        var numCells = (GRID_SIZE * GRID_SIZE) - ArrayUtils.pick(difficulty, 1);
        var cells    = ArrayUtils.pick(ArrayUtils.flatten(s.cells), numCells);

        for(var i = 0; i < cells.length; i++) {
            cells[i].setValue(null);
        }
    };

    Sudoku.prototype.solve = function solve() {
        var cells          = ArrayUtils.flatten(this.cells);
        var possibleValues = {};

        var classified = ArrayUtils.classify(cells, function(value) {
            return value.getValue() === null ? 0 : 1;
        });
        var emptyCells    = classified[0];
        var nonEmptyCells = classified[1];

        for(var i = 0; i < emptyCells.length; i++) {
            var cell = emptyCells[i];

            possibleValues[cell] = ArrayUtils.range(1, GRID_SIZE);
        }

        var relatedCells = findRelatedCells(cells);

        for(var i = 0; i < nonEmptyCells.length; i++) {
            var cell      = nonEmptyCells[i];
            var related   = relatedCells[cell];
            var cellValue = cell.getValue();

            related.forEach(function(otherCell) {
                if(otherCell in possibleValues) {
                    possibleValues[otherCell] = ArrayUtils.grep(possibleValues[otherCell], function(value) {
                        return value != cellValue;
                    });
                }
            });
        }

        var cellLookup = {};
        for(var i = 0; i < cells.length; i++) {
            cellLookup[ cells[i] ] = cells[i];
        }

        return solveHelper(this, cellLookup, relatedCells, possibleValues);
    };

    Sudoku.prototype.generate = function generate(difficulty) {
        var cells        = ArrayUtils.flatten(this.cells);
        var relatedCells = findRelatedCells(cells);
        var hasPuzzle    = false;

        OUTER:
        while(true) {
            var cellToNumbers = {};
            for(var i = 0; i < cells.length; i++) {
                cells[i].setValue(null);
                cellToNumbers[ cells[i] ] = ArrayUtils.range(1, GRID_SIZE);
            }

            var luckyFew = ArrayUtils.pick(cells, STARTING_CELLS);

            for(var i = 0; i < luckyFew.length; i++) {
                var victim  = luckyFew[i];
                var numbers = cellToNumbers[victim];

                delete cellToNumbers[victim];

                if(!numbers || numbers.length == 0) {
                    continue OUTER;
                }
                var value = ArrayUtils.pick(numbers, 1);
                victim.setValue(value);

                relatedCells[victim].forEach(function(relatedCell) {
                    if(cellToNumbers[relatedCell]) {
                        cellToNumbers[ relatedCell ] = ArrayUtils.grep(cellToNumbers[ relatedCell ], function(otherValue) {
                            return value != otherValue;
                        });
                    }
                });
            }

            if(this.solve()) {
                break OUTER;
            }
        }

        digOut(this, DIFFICULTIES[difficulty]);
    };

    Sudoku.prototype.getConflicts = function getConflicts() {
        var relatedCellLookup = findRelatedCells(ArrayUtils.flatten(this.cells));
        var nonEmptyCells     = ArrayUtils.grep(ArrayUtils.flatten(this.cells), function(cell) {
            return cell.getValue() != null;
        });

        var conflicts = [];

        for(var i = 0; i < nonEmptyCells.length; i++) {
            var value = nonEmptyCells[i].getValue();
            var isConflicting = false;

            relatedCellLookup[ nonEmptyCells[i] ].forEach(function(cell) {
                var otherValue = cell.getValue();

                if(otherValue === value) {
                    isConflicting = true;
                }
            });

            if(isConflicting) {
                conflicts.push({
                    row: nonEmptyCells[i].getRow(),
                    col: nonEmptyCells[i].getColumn()
                });
            }
        }

        return conflicts;
    };

    return Sudoku;
})();

var sudokuObjects = [];

function makeSudoku() {
    var s = new Sudoku();
    s.generate(0);

    sudokuObjects.push(s);
    return sudokuObjects.length - 1;
}

function getSudoku(id) {
    return sudokuObjects[id];
}
