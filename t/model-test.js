var test      = require('tap').test;
var modSudoku = require('../qml/pages/Sudoku.js');

test('Sudoku Model Tests', function(t) {
    var id1 = modSudoku.makeSudoku();
    var id2 = modSudoku.makeSudoku();
    t.is(id1, id2, 'The handle for the sudoku object should be shared (for now)');

    t.end();
});
