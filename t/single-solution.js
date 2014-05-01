var test      = require('tap').test;
var modSudoku = require('../qml/pages/Sudoku.js');

const NUM_TO_GENERATE = 1000;

test('Assert that only single-solution sudokus are generated', function(t) {
    var solver = new modSudoku.SudokuSolver();

    for(var i = 0; i < NUM_TO_GENERATE; i++) {
        var numSolutions = 0;
        var s            = new modSudoku.Sudoku();
        s.generate(0);

        solver.eachSolution(s, function(solution) {
            var initialCells = solution.initialCells;
            var numGiven     = 0;

            for(var k in initialCells) {
                if(! initialCells.hasOwnProperty(k)) {
                    continue;
                }
                numGiven++;
            }
            t.ok(numGiven >= 27 && numGiven <= 30, '# given cells should be between 27 and 30');
            numSolutions++;
            if(numSolutions > 1) {
                return true;
            }
        });

        t.is(numSolutions, 1, 'Each generated puzzle should have exactly one solution');
    }

    t.end();
});
