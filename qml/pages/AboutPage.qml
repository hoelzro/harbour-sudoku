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

Page {
    Column {
        anchors.fill: parent

        PageHeader {
            title: 'About This Application'
        }

        Label {
            text: 'Sudoku for SailfishOS, by Rob Hoelz.<br />Source code at <br /><a href="https://github.com/hoelzro/harbour-sudoku">https://github.com/hoelzro/harbour-sudoku</a>'
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

            onLinkActivated: {
                Qt.openUrlExternally(link)
            }
        }
    }
}
