import QtQuick 2.9

import "../../Util.js" as UtilScript

Item {
    id: settingsSwipe

    Column {
        anchors.centerIn: parent
        width:            parent.width

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width:                    parent.width - UtilScript.pt(32)
            height:                   UtilScript.pt(64)
            color:                    enabled ? "steelblue" : "darkgray"
            radius:                   UtilScript.pt(8)
            enabled:                  VKHelper.friendsCount !== 0

            Text {
                anchors.fill:        parent
                text:                qsTr("Trusted Friends")
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
                    var component = Qt.createComponent("../TrustedFriendsPage.qml");

                    if (component.status === Component.Ready) {
                        mainStackView.push(component);
                    } else {
                        console.log(component.errorString());
                    }
                }
            }
        }
    }
}
