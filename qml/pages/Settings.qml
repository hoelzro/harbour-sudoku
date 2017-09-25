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
import Nemo.Configuration 1.0

Dialog {
    id: settings
    allowedOrientations: defaultAllowedOrientations

    onAccepted: {
        if (dragging.enabled) {
            draggingEnabled.value = dragging.checked
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        Column {
            spacing: Theme.paddingMedium

            anchors {
                left: parent.left
                right: parent.right
            }

            DialogHeader {
                id: header
                title: "Settings"
                acceptText: "Save"
                cancelText: "Discard"
                width: settings.width
            }

            TextSwitch {
                id: dragging
                width: parent.width
                checked: draggingEnabled.value
                text: "Enable drag and drop"
                description: "Allows you to drag and drop value from button to cell and from selected cell to another"
            }
        }
    }
    ConfigurationValue {
        id: draggingEnabled
        key: "/app/harbour-sudoku/settings/draggingEnabled"
        defaultValue: false
    }
}
