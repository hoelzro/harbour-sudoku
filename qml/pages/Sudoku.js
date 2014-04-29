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

var exports = (function() {
    const GRID_SIZE       = 9;
    const BLOCK_SIZE      = 3;
    const STARTING_CELLS  = 11;   // determined from paper, hardcoded for 9x9
    const MAX_SOLVE_CALLS = 1000; // to avoid wasting time trying to find solutions for hard-to-solve puzzles;
                                  // just restart

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

    ArrayUtils.shuffle = function shuffle(array, randInt) {
        var result = [];
        var struck = [];

        for(var i = 0; i < array.length; i++) {
            var k = randInt(0, array.length - i - 1);

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

    ArrayUtils.pick = function pick(array, numElements, randInt) {
        var indices = ArrayUtils.shuffle(ArrayUtils.range(0, array.length - 1), randInt);
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

    var solveHelper = function solveHelper(s, action, cellLookup, relatedCells, possibleValues, progress) {
        progress.numCalls++;
        if(progress.numCalls > MAX_SOLVE_CALLS) {
            return;
        }
        if(HashUtils.size(possibleValues) == 0) {
            action(s);
            return;
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
            solveHelper(s, action, cellLookup, relatedCells, newPossibleValues, progress);
        }
        minCell.setValue(null);
    };

    var DIFFICULTIES = [
        ArrayUtils.range(27, 30),
    ];

    var SudokuSolver = function SudokuSolver() {
    };

    SudokuSolver.prototype.solve = function solve(s) {
        var sentinel;
        var solution;

        try {
            this.eachSolution(s, function(sol) {
                var solCells = sol.cells;
                solution     = [];

                for(var rowNo = 0; rowNo < solCells.length; rowNo++) {
                    var row         = solCells[rowNo];
                    var solutionRow = [];

                    for(var colNo = 0; colNo < row.length; colNo++) {
                        var cell     = row[colNo];
                        var cellCopy = new Cell(cell.getRow(), cell.getColumn());
                        cellCopy.setValue(cell.getValue());

                        solutionRow.push(cellCopy);
                    }

                    solution.push(solutionRow);
                }
                throw sentinel;
            });
        } catch(e) {
            if(e !== sentinel) {
                throw e;
            }
        }

        if(solution) {
            for(var rowNo = 0; rowNo < solution.length; rowNo++) {
                var row = solution[rowNo];
                for(var colNo = 0; colNo < row.length; colNo++) {
                    var cell = row[colNo];

                    s.set(cell.getRow(), cell.getColumn(), cell.getValue());
                }
            }
            return true;
        } else {
            return false;
        }
    };

    SudokuSolver.prototype.eachSolution = function eachSolution(s, action) {
        var cells          = ArrayUtils.flatten(s.cells);
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

        return solveHelper(s, action, cellLookup, relatedCells, possibleValues, { numCalls: 0 });
    };

    var Sudoku = function Sudoku() {
        this.cells        = [];
        this.initialCells = {};

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

    var reflectCell = function reflectCell(cell, allCells) {
        var row = cell.getRow();
        var col = cell.getColumn();

        var center = (GRID_SIZE - 1) / 2;

        var dRow = row - center;
        var dCol = col - center;

        var mirrorRow = center - dRow;
        var mirrorCol = center - dCol;

        return ArrayUtils.grep(allCells, function(otherCell) {
            return otherCell.getRow() == mirrorRow && otherCell.getColumn() == mirrorCol;
        })[0];
    };

    var hasUniqueSolution = function hasUniqueSolution(s) {
        var solver = new SudokuSolver();

        var sentinel        = {};
        var hasSeenSolution = false;

        try {
            solver.eachSolution(s, function(_) {
                if(hasSeenSolution) {
                    throw sentinel;
                }
                hasSeenSolution = true;
            });
        } catch(e) {
            if(e !== sentinel) {
                throw e;
            }
            return false;
        }

        return hasSeenSolution;
    };

    var digOut = function digOut(s, difficulty, randInt) {
        var numCells  = (GRID_SIZE * GRID_SIZE) - ArrayUtils.pick(difficulty, 1, randInt);
        var flatCells = ArrayUtils.flatten(s.cells);
        var counts    = [ null, 9 ,9, 9, 9, 9, 9, 9, 9, 9 ]; // XXX hardcoded

        while(numCells > 0) {
            var cell       = ArrayUtils.pick(flatCells, 1, randInt);
            var reflection = reflectCell(cell, flatCells);

            var cellValue       = cell.getValue();
            var reflectionValue = reflection.getValue();

            counts[ cellValue ]--;
            if(reflection !== cell) {
                counts[ reflectionValue ]--;
            }

            // XXX this guarantees all 9 numbers are on the board...we just need 8
            if(counts[cellValue] == 0 || counts[reflectionValue] == 0) {
                counts[ cellValue ]++;
                if(reflection !== cell) {
                    counts[ reflectionValue ]++;
                }
                continue;
            }

            cell.setValue(null);
            numCells--;

            if(reflection !== cell) { // the center is its own reflection
                reflection.setValue(null);
                numCells--;
            }

            if(! hasUniqueSolution(s)) {
                numCells++;
                counts[ cellValue ]++;

                if(reflection !== null) {
                    numCells++;
                    counts[ reflectionValue ]++;
                }
                continue;
            }

            flatCells = ArrayUtils.grep(flatCells, function(otherCell) {
                return otherCell !== cell && otherCell !== reflection;
            });
        }
    };

    Sudoku.prototype.generate = function generate(difficulty, randInt) {
        var cells        = ArrayUtils.flatten(this.cells);
        var relatedCells = findRelatedCells(cells);
        var hasPuzzle    = false;

        if(!randInt) {
            randInt = function randInt(min, max) {
                return Math.round(min + (max - min) * Math.random());
            };
        }

        OUTER:
        while(true) {
            var cellToNumbers = {};
            for(var i = 0; i < cells.length; i++) {
                cells[i].setValue(null);
                cellToNumbers[ cells[i] ] = ArrayUtils.range(1, GRID_SIZE);
            }

            var luckyFew = ArrayUtils.pick(cells, STARTING_CELLS, randInt);

            for(var i = 0; i < luckyFew.length; i++) {
                var victim  = luckyFew[i];
                var numbers = cellToNumbers[victim];

                delete cellToNumbers[victim];

                if(!numbers || numbers.length == 0) {
                    continue OUTER;
                }
                var value = ArrayUtils.pick(numbers, 1, randInt);
                victim.setValue(value);

                relatedCells[victim].forEach(function(relatedCell) {
                    if(cellToNumbers[relatedCell]) {
                        cellToNumbers[ relatedCell ] = ArrayUtils.grep(cellToNumbers[ relatedCell ], function(otherValue) {
                            return value != otherValue;
                        });
                    }
                });
            }

            var solver = new SudokuSolver();

            if(solver.solve(this)) {
                break OUTER;
            }
        }

        digOut(this, DIFFICULTIES[difficulty], randInt);

        for(var row = 0; row < GRID_SIZE; row++) {
            for(var col = 0; col < GRID_SIZE; col++) {
                if(this.get(row, col) != null) {
                    this.initialCells[row * GRID_SIZE + col] = true;
                }
            }
        }
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

    Sudoku.prototype.isGameOver = function isGameOver() {
        var emptyCells = ArrayUtils.grep(ArrayUtils.flatten(this.cells), function(cell) {
            return cell.getValue() == null;
        });

        return emptyCells.length == 0 && this.getConflicts().length == 0;
    };

    // XXX lots of code duplication between here and solve =(
    Sudoku.prototype.getHint = function getHint() {
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

        var minPair = ArrayUtils.min(HashUtils.pairs(possibleValues), function(pair) { return pair.value.length });
        var minCell = cellLookup[ minPair.key ];
        var choices = minPair.value;

        return choices.length == 1 ? { row: minCell.getRow(), col: minCell.getColumn(), value: choices[0] } : null;
    };

    Sudoku.prototype.isInitialCell = function isInitialCell(row, col) {
        return this.initialCells[row * GRID_SIZE + col];
    };

    return {
        Sudoku       : Sudoku,
        SudokuSolver : SudokuSolver
    };
})();

var sudokuObject;

function makeSudoku(rows) {
    var s = new exports.Sudoku();

    if(rows) {
        for(var i = 0; i < rows.length; i++) {
            s.set(rows[i].row, rows[i].column, rows[i].value);
            if(rows[i].isInitial) {
                // Hard-coded GRID_SIZE =(
                s.initialCells[rows[i].row * 9 + rows[i].column] = true;
            }
        }
    } else {
        s.generate(0);
    }

    sudokuObject = s;
    return 0;
}

function getSudoku(id) {
    return sudokuObject;
}

if(typeof(module) != 'undefined') { // node.js (for testing)
    exports.makeSudoku = makeSudoku;
    exports.getSudoku  = getSudoku;
    module.exports     = exports;
}
