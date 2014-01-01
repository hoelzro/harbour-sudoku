TARGET   = harbour-sudoku
CONFIG  += sailfishapp
SOURCES += \
    src/harbour-sudoku.cpp
HEADERS       +=
desktop.files += harbour-sudoku.desktop
OTHER_FILES   += \
    qml/pages/LaunchPage.qml \
    qml/harbour-sudoku.qml \
    rpm/harbour-sudoku.spec \
    rpm/harbour-sudoku.yaml \
    harbour-sudoku.desktop
