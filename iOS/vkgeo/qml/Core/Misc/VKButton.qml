import QtQuick 2.9

import "../../Util.js" as UtilScript

Rectangle {
    id:     vkButton
    color:  enabled ? "steelblue" : "darkgray"
    radius: UtilScript.pt(8)

    property string text: ""

    signal clicked()

    Text {
        anchors.fill:        parent
        text:                vkButton.text
        color:               "white"
        font.pointSize:      16
        font.family:         "Helvetica"
        font.bold:           true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment:   Text.AlignVCenter
        wrapMode:            Text.Wrap
        fontSizeMode:        Text.Fit
        minimumPointSize:    8
    }

    MouseArea {
        anchors.fill: parent

        onClicked: {
            vkButton.clicked();
        }
    }
}
