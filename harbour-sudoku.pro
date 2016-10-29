TARGET   = harbour-sudoku
CONFIG  += sailfishapp
SOURCES += \
    src/harbour-sudoku.cpp
HEADERS       +=
desktop.files += harbour-sudoku.desktop
OTHER_FILES   += \
    qml/cover/CoverPage.qml \
    qml/pages/SudokuBlock.qml \
    qml/pages/Victory.qml \
    qml/pages/SudokuBoard.qml \
    qml/pages/PlayGamePage.qml \
    qml/pages/Generating.qml \
    qml/pages/AboutPage.qml \
    qml/pages/Sudoku.js \
    qml/pages/SmallInput.qml \
    qml/pages/LargeInput.qml \
    qml/harbour-sudoku.qml \
    rpm/harbour-sudoku.spec \
    rpm/harbour-sudoku.yaml \
    harbour-sudoku.desktop
