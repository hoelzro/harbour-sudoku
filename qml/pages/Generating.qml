import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    allowedOrientations: defaultAllowedOrientations
    backNavigation: false

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 20

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Generating..."
        }

        BusyIndicator {
            anchors.horizontalCenter: parent.horizontalCenter
            size: BusyIndicatorSize.Large
            running: true
        }
    }
}
