var test      = require('tap').test;
var modSudoku = require('../qml/pages/Sudoku.js');

const NUM_TO_GENERATE = 1000;

test('Assert that only single-solution sudokus are generated', function(t) {
    var solver = new modSudoku.SudokuSolver();

    for(var i = 0; i < NUM_TO_GENERATE; i++) {
        var numSolutions = 0;
        var s            = new modSudoku.Sudoku();
        s.generate(0);

        var sentinel = {};

        try {
            solver.eachSolution(s, function(_) {
                numSolutions++;
                if(numSolutions > 1) {
                    throw sentinel;
                }
            });
        } catch(e) {
            if(e !== sentinel) {
                throw e;
            }
        }

        t.is(numSolutions, 1, 'Each generated puzzle should have exactly one solution');
    }

    t.end();
});
