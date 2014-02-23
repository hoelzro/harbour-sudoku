/*
 * This test verifies that a given stream of numbers provided to the
 * generation algorithm results in the exact same Sudoku board.  Other
 * tests will rely on consistent results for a given stream of numbers
 * to test what they test, and those tests will break if the underlying
 * algorithm changes.  So if this test fails, it's an indication that
 * other tests that rely on a stream of numbers resulting in a certain
 * board must be updated, along with this test.
 */

var test      = require('tap').test;
var modSudoku = require('../qml/pages/Sudoku.js');
var Sudoku    = modSudoku.Sudoku;

var FakeRandomNumbers = function FakeRandomNumbers() {
    this.values = [
        58, 47, 27, 61, 73, 71, 39, 36, 41, 59, 17, 65, 68, 45, 62, 57,
        37, 28, 11, 3, 39, 17, 51, 3, 3, 35, 44, 50, 50, 42, 18, 7,
        29, 32, 16, 43, 12, 7, 6, 15, 11, 15, 27, 25, 11, 19, 6, 26,
        21, 16, 14, 4, 12, 0, 6, 17, 18, 14, 17, 6, 9, 15, 7, 7,
        11, 6, 7, 3, 3, 6, 6, 2, 3, 7, 4, 2, 4, 1, 2, 0,
        0, 1, 4, 5, 1, 0, 1, 2, 1, 0, 2, 0, 3, 4, 1, 2,
        1, 1, 0, 5, 1, 1, 2, 2, 1, 1, 0, 5, 4, 4, 1, 2,
        3, 2, 1, 0, 6, 5, 0, 0, 0, 2, 0, 0, 2, 2, 3, 1,
        0, 1, 0, 0, 4, 3, 1, 0, 1, 0, 0, 2, 1, 1, 0, 0,
        4, 0, 2, 1, 1, 0, 0, 2, 1, 1, 0, 0, 1, 4, 4, 0,
        1, 1, 0, 0, 5, 7, 4, 7, 6, 4, 2, 1, 0, 0, 0, 71,
        41, 27, 21, 30, 20, 63, 23, 63, 51, 0, 29, 50, 66, 52, 23, 14,
        38, 18, 38, 49, 1, 39, 52, 37, 9, 41, 47, 19, 8, 37, 47, 6,
        23, 23, 37, 38, 12, 37, 24, 23, 32, 2, 36, 16, 2, 8, 27, 14,
        9, 17, 14, 15, 21, 20, 25, 16, 3, 2, 7, 13, 7, 4, 11, 8,
        3, 7, 12, 4, 9, 2, 4, 3, 7, 6, 1, 2, 0, 0, 1, 0
    ];

    this.valueIndex = 0;
};

var expectedRows = [
    [ 0 , 3 , 0 , 7 , 0 , 0 , 6 , 5 , 0 ],
    [ 5 , 0 , 0 , 9 , 6 , 3 , 0 , 8 , 2 ],
    [ 0 , 9 , 0 , 0 , 0 , 2 , 7 , 0 , 3 ],
    [ 0 , 0 , 0 , 3 , 0 , 0 , 9 , 6 , 0 ],
    [ 8 , 5 , 0 , 0 , 1 , 0 , 0 , 0 , 7 ],
    [ 9 , 4 , 3 , 0 , 7 , 0 , 0 , 2 , 0 ],
    [ 4 , 8 , 0 , 0 , 2 , 0 , 0 , 0 , 0 ],
    [ 2 , 0 , 0 , 5 , 0 , 0 , 0 , 0 , 0 ],
    [ 0 , 1 , 0 , 4 , 9 , 0 , 0 , 0 , 6 ]
];

FakeRandomNumbers.prototype.nextInt = function nextInt(min, max) {
    if(this.isComplete()) {
        throw 'ran out of numbers';
    }
    return this.values[this.valueIndex++];
};

FakeRandomNumbers.prototype.isComplete = function isComplete() {
    return this.valueIndex == this.values.length;
};

test('Make sure that we use a stream of random numbers exactly as intended', function(t) {
    var s      = new Sudoku();
    var stream = new FakeRandomNumbers();

    s.generate(0, stream.nextInt.bind(stream));

    t.ok(stream.isComplete(), 'All saved values should be used');

    for(var rowNum = 0; rowNum < expectedRows.length; rowNum++) {
        var row = expectedRows[rowNum];

        for(var colNum = 0; colNum < row.length; colNum++) {
            var expectedValue = row[colNum] || null;
            var gotValue      = s.get(rowNum, colNum);

            t.equal(gotValue, expectedValue, 'Generated values should match up');
        }
    }

    t.end();
});
