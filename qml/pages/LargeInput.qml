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
import "."

Item {
    signal entry(int value)
    height:numpad.height
    width:numpad.width

    Grid {
        id: numpad
        rows: page.isLandscape ? 5 : 2
        columns: page.isLandscape ? 2 : 5
        spacing: 10 / 32 * Theme.fontSizeMedium

        Repeater {
            model: 10

            MouseArea {
                height: 90 / 32 * Theme.fontSizeMedium
                width: height

                Rectangle {
                    anchors.fill: parent
                    color: parent.pressed ? Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
                                          : Theme.rgba(Theme.primaryColor, 0.2)
                    radius: Theme.paddingSmall
                }

                Label {
                    text: index < 9 ? index + 1 : 'Erase'
                    anchors.centerIn: parent
                    color: parent.pressed ? Theme.highlightColor : Theme.primaryColor
                }

                onClicked: {
                    if (index === 9) {
                        entry(0);
                    }
                    else entry(index + 1);
                }
            }
        }
    }
}
