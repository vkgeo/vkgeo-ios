import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2

import "../Misc"

import "../../Util.js" as UtilScript

Item {
    id: settingsSwipe

    Toast {
        id:              joinGroupToast
        anchors.top:     parent.top
        anchors.left:    parent.left
        anchors.right:   parent.right
        anchors.margins: UtilScript.pt(4)
        height:          UtilScript.pt(48)
        z:               1
        text:            qsTr("Group membership request sent")
    }

    Flickable {
        id:                   settingsFlickable
        anchors.fill:         parent
        anchors.topMargin:    UtilScript.pt(16)
        anchors.bottomMargin: UtilScript.pt(16)
        contentWidth:         settingsLayout.width
        contentHeight:        settingsLayout.height
        clip:                 true

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AlwaysOn
        }

        ColumnLayout {
            id:      settingsLayout
            width:   settingsFlickable.width
            spacing: UtilScript.pt(16)

            Text {
                leftPadding:         UtilScript.pt(16)
                rightPadding:        UtilScript.pt(16)
                text:                qsTr("You can see the location of trusted friends, if they also treat you as a trusted friend, and they <b>can see your location</b>.")
                color:               "black"
                font.pointSize:      16
                font.family:         "Helvetica"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment:   Text.AlignVCenter
                wrapMode:            Text.Wrap
                fontSizeMode:        Text.Fit
                minimumPointSize:    8
                textFormat:          Text.StyledText
                Layout.fillWidth:    true
                Layout.alignment:    Qt.AlignVCenter
            }

            Text {
                leftPadding:         UtilScript.pt(16)
                rightPadding:        UtilScript.pt(16)
                text:                textToShow(VKHelper.maxTrustedFriendsCount)
                color:               "black"
                font.pointSize:      16
                font.family:         "Helvetica"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment:   Text.AlignVCenter
                wrapMode:            Text.Wrap
                fontSizeMode:        Text.Fit
                minimumPointSize:    8
                Layout.fillWidth:    true
                Layout.alignment:    Qt.AlignVCenter

                function textToShow(max_count) {
                    if (max_count > 0) {
                        return qsTr("Currently you can have up to %1 trusted friends.").arg(max_count);
                    } else {
                        return qsTr("Currently you can't have trusted friends.");
                    }
                }
            }

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

            ToolSeparator {
                orientation:      Qt.Horizontal
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                leftPadding:         UtilScript.pt(16)
                rightPadding:        UtilScript.pt(16)
                text:                qsTr("You can see the location of tracked friends, if they treat you as a trusted friend, but they <b>cannot see your location</b>.")
                color:               "black"
                font.pointSize:      16
                font.family:         "Helvetica"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment:   Text.AlignVCenter
                wrapMode:            Text.Wrap
                fontSizeMode:        Text.Fit
                minimumPointSize:    8
                textFormat:          Text.StyledText
                Layout.fillWidth:    true
                Layout.alignment:    Qt.AlignVCenter
            }

            Text {
                leftPadding:         UtilScript.pt(16)
                rightPadding:        UtilScript.pt(16)
                text:                textToShow(VKHelper.maxTrackedFriendsCount)
                color:               "black"
                font.pointSize:      16
                font.family:         "Helvetica"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment:   Text.AlignVCenter
                wrapMode:            Text.Wrap
                fontSizeMode:        Text.Fit
                minimumPointSize:    8
                Layout.fillWidth:    true
                Layout.alignment:    Qt.AlignVCenter

                function textToShow(max_count) {
                    if (max_count > 0) {
                        return qsTr("Currently you can have up to %1 tracked friends.").arg(max_count);
                    } else {
                        return qsTr("Currently you can't have tracked friends. Please visit Store for details.");
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

            ToolSeparator {
                orientation:      Qt.Horizontal
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }

            VKButton {
                width:            UtilScript.pt(280)
                height:           UtilScript.pt(64)
                text:             qsTr("Store")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                onClicked: {
                    var component = Qt.createComponent("../StorePage.qml");

                    if (component.status === Component.Ready) {
                        mainStackView.push(component);
                    } else {
                        console.log(component.errorString());
                    }
                }
            }

            ToolSeparator {
                orientation:      Qt.Horizontal
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }

            VKButton {
                width:            UtilScript.pt(280)
                height:           UtilScript.pt(64)
                text:             qsTr("Support")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                onClicked: {
                    if (!Qt.openUrlExternally("vk://vk.com/vkgeo_app")) {
                        Qt.openUrlExternally("https://m.vk.com/vkgeo_app");
                    }
                }
            }

            VKButton {
                width:            UtilScript.pt(280)
                height:           UtilScript.pt(64)
                text:             qsTr("Join VKGeo group")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                onClicked: {
                    joinVKGeoGroupMessageDialog.open();
                }
            }

            VKButton {
                width:            UtilScript.pt(280)
                height:           UtilScript.pt(64)
                text:             qsTr("Join VKGames group")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                onClicked: {
                    joinVKGamesGroupMessageDialog.open();
                }
            }

            ToolSeparator {
                orientation:      Qt.Horizontal
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }

            VKButton {
                width:            UtilScript.pt(280)
                height:           UtilScript.pt(64)
                text:             qsTr("View my VK profile")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                onClicked: {
                    var component = Qt.createComponent("../ProfilePage.qml");

                    if (component.status === Component.Ready) {
                        var profile_page = mainStackView.push(component);

                        profile_page.userId            = VKHelper.userId;
                        profile_page.online            = false;
                        profile_page.locationAvailable = false;
                        profile_page.firstName         = VKHelper.firstName;
                        profile_page.lastName          = VKHelper.lastName;
                        profile_page.bigPhotoUrl       = VKHelper.bigPhotoUrl;
                        profile_page.screenName        = "id%1".arg(VKHelper.userId);
                        profile_page.status            = "";
                    } else {
                        console.log(component.errorString());
                    }
                }
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

    MessageDialog {
        id:              joinVKGeoGroupMessageDialog
        title:           qsTr("Join group")
        icon:            StandardIcon.Question
        text:            qsTr("Do you want to join the VKGeo group?")
        standardButtons: StandardButton.Yes | StandardButton.No

        onYes: {
            VKHelper.joinGroup("166101702");

            joinGroupToast.visible = true;
        }
    }

    MessageDialog {
        id:              joinVKGamesGroupMessageDialog
        title:           qsTr("Join group")
        icon:            StandardIcon.Question
        text:            qsTr("Do you want to join the VKGames group?")
        standardButtons: StandardButton.Yes | StandardButton.No

        onYes: {
            VKHelper.joinGroup("78616012");

            joinGroupToast.visible = true;
        }
    }
}
