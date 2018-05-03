import QtQuick 2.9
import QtQuick.Layouts 1.3

import "../../Util.js" as UtilScript

Item {
    id: settingsSwipe

    ColumnLayout {
        anchors.fill: parent
        spacing:      UtilScript.pt(32)

        Rectangle {
            width:            UtilScript.pt(280)
            height:           UtilScript.pt(64)
            color:            enabled ? "steelblue" : "darkgray"
            radius:           UtilScript.pt(8)
            enabled:          VKHelper.friendsCount !== 0
            Layout.topMargin: UtilScript.pt(16)
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            Text {
                anchors.fill:        parent
                text:                qsTr("Trusted Friends List")
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

        Rectangle {
            color:             "transparent"
            Layout.fillWidth:  true
            Layout.fillHeight: true
        }

        Rectangle {
            width:               UtilScript.pt(280)
            height:              UtilScript.pt(64)
            color:               "steelblue"
            radius:              UtilScript.pt(8)
            Layout.bottomMargin: UtilScript.pt(16)
            Layout.alignment:    Qt.AlignHCenter | Qt.AlignVCenter

            Text {
                anchors.fill:        parent
                text:                qsTr("Log out of VK")
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
                    VKHelper.logout();
                }
            }
        }
    }
}
