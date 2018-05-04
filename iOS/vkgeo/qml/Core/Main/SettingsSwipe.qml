import QtQuick 2.9
import QtQuick.Layouts 1.3

import "../Misc"

import "../../Util.js" as UtilScript

Item {
    id: settingsSwipe

    ColumnLayout {
        anchors.fill: parent
        spacing:      UtilScript.pt(32)

        VKButton {
            width:            UtilScript.pt(280)
            height:           UtilScript.pt(64)
            text:             qsTr("Trusted friends list")
            enabled:          VKHelper.friendsCount !== 0
            Layout.topMargin: UtilScript.pt(16)
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            onClicked: {
                var component = Qt.createComponent("../TrustedFriendsPage.qml");

                if (component.status === Component.Ready) {
                    mainStackView.push(component);
                } else {
                    console.log(component.errorString());
                }
            }
        }

        Rectangle {
            color:             "transparent"
            Layout.fillWidth:  true
            Layout.fillHeight: true
        }

        VKButton {
            width:               UtilScript.pt(280)
            height:              UtilScript.pt(64)
            text:                qsTr("Log out of VK")
            Layout.bottomMargin: UtilScript.pt(16)
            Layout.alignment:    Qt.AlignHCenter | Qt.AlignVCenter

            onClicked: {
                VKHelper.logout();
            }
        }
    }
}
