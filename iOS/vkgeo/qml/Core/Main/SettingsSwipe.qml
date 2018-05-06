import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import "../Misc"

import "../../Util.js" as UtilScript

Item {
    id: settingsSwipe

    Flickable {
        id:                   settingsFlickable
        anchors.fill:         parent
        anchors.topMargin:    UtilScript.pt(16)
        anchors.bottomMargin: UtilScript.pt(16)
        contentWidth:         settingsLayout.width
        contentHeight:        settingsLayout.height
        clip:                 true

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }

        ColumnLayout {
            id:      settingsLayout
            width:   settingsFlickable.width
            spacing: UtilScript.pt(16)

            VKButton {
                width:            UtilScript.pt(280)
                height:           UtilScript.pt(64)
                text:             qsTr("Trusted friends list")
                enabled:          VKHelper.friendsCount > 0 && VKHelper.maxTrustedFriendsCount > 0
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

            VKButton {
                width:            UtilScript.pt(280)
                height:           UtilScript.pt(64)
                text:             qsTr("Tracked friends list")
                enabled:          VKHelper.friendsCount > 0 && VKHelper.maxTrackedFriendsCount > 0
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                onClicked: {
                    var component = Qt.createComponent("../TrackedFriendsPage.qml");

                    if (component.status === Component.Ready) {
                        mainStackView.push(component);
                    } else {
                        console.log(component.errorString());
                    }
                }
            }

            Rectangle {
                implicitHeight:    UtilScript.pt(64)
                color:             "transparent"
                Layout.fillWidth:  true
            }

            VKButton {
                width:            UtilScript.pt(280)
                height:           UtilScript.pt(64)
                text:             qsTr("Log out of VK")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                onClicked: {
                    VKHelper.logout();
                }
            }
        }
    }
}
