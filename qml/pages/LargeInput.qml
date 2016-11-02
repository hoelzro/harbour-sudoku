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
import Sailfish.Silica 1.0

Item {
    signal entry(int value)
    height:numpad.height
    width:numpad.width


    Grid {
        id: numpad
        rows: page.isPortrait ? 2 : 5
        columns: page.isPortrait ? 5 : 2
        spacing: 10

        Repeater {
            model: 9

            Button {
                width: 90
                height:80
                text: index + 1

                onClicked: {
                    entry(index + 1);
                }
            }
        }
    }

    Button{
        id: erase
        anchors {
            bottom: numpad.bottom
            right: numpad.right
        }

        width: 90
        height: 80
        text: 'Erase'


        onClicked: {
            entry(0);
        }
    }
}
