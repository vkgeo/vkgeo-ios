import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

import "../Util.js" as UtilScript

Page {
    id: trustedFriendsPage

    header: Rectangle {
        height: trustedFriendsPage.safeAreaTopMargin + headerControlsRectangle.height
        color:  "lightsteelblue"

        Rectangle {
            id:             headerControlsRectangle
            anchors.bottom: parent.bottom
            anchors.left:   parent.left
            anchors.right:  parent.right
            height:         UtilScript.pt(48)
            color:          "transparent"

            Rectangle {
                id:                     cancelButton
                anchors.left:           parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin:     UtilScript.pt(8)
                width:                  UtilScript.pt(80)
                height:                 UtilScript.pt(32)
                color:                  "steelblue"
                radius:                 UtilScript.pt(8)

                Text {
                    anchors.fill:        parent
                    text:                qsTr("Cancel")
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
                        mainStackView.pop();
                    }
                }
            }

            Text {
                anchors.centerIn:    parent
                width:               parent.width - UtilScript.pt(8)
                                                  - cancelButton.width
                                                  - cancelButton.leftMargin
                                                  - saveButton.width
                                                  - saveButton.rightMargin
                height:              parent.height
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

            Rectangle {
                id:                     saveButton
                anchors.right:          parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin:    UtilScript.pt(8)
                width:                  UtilScript.pt(80)
                height:                 UtilScript.pt(32)
                color:                  "steelblue"
                radius:                 UtilScript.pt(8)

                Text {
                    anchors.fill:        parent
                    text:                qsTr("Save")
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
                        var trusted_friends_list = [];

                        for (var i = 0; i < trustedFriendsListModel.count; i++) {
                            var frnd = trustedFriendsListModel.get(i);

                            if (typeof frnd.id      !== "undefined" &&
                                typeof frnd.trusted !== "undefined" && frnd.trusted) {
                                trusted_friends_list.push(frnd.id);
                            }
                        }

                        VKHelper.updateTrustedFriendsList(trusted_friends_list);

                        mainStackView.pop();
                    }
                }
            }
        }
    }

    footer: Rectangle {
        height: trustedFriendsPage.safeAreaBottomMargin
        color:  "lightsteelblue"
    }

    property int safeAreaTopMargin:    0
    property int safeAreaBottomMargin: 0

    StackView.onStatusChanged: {
        if (StackView.status === StackView.Activating ||
            StackView.status === StackView.Active) {
            safeAreaTopMargin    = UIHelper.safeAreaTopMargin();
            safeAreaBottomMargin = UIHelper.safeAreaBottomMargin();
        }
    }

    ListView {
        id:           friendsListView
        anchors.fill: parent
        orientation:  ListView.Vertical

        model: ListModel {
            id: trustedFriendsListModel
        }

        delegate: Rectangle {
            id:           friendDelegate
            width:        listView.width
            height:       UtilScript.pt(80)
            clip:         true
            border.width: UtilScript.pt(1)
            border.color: "lightsteelblue"

            property var listView: ListView.view

            Row {
                anchors.fill: parent
                leftPadding:  UtilScript.pt(8)
                rightPadding: UtilScript.pt(8)
                spacing:      UtilScript.pt(8)

                OpacityMask {
                    id:                     opacityMask
                    anchors.verticalCenter: parent.verticalCenter
                    width:                  UtilScript.pt(64)
                    height:                 UtilScript.pt(64)

                    source: Image {
                        width:    opacityMask.width
                        height:   opacityMask.height
                        source:   photoUrl
                        fillMode: Image.Stretch
                        visible:  false
                    }

                    maskSource: Image {
                        width:    opacityMask.width
                        height:   opacityMask.height
                        source:   "qrc:/resources/images/main/avatar_mask.png"
                        fillMode: Image.PreserveAspectFit
                        visible:  false
                    }
                }

                Text {
                    width:               parent.width - parent.spacing * 2
                                                      - parent.leftPadding
                                                      - parent.rightPadding
                                                      - opacityMask.width
                                                      - trustedSwitch.width
                    height:              parent.height
                    text:                "%1 %2".arg(firstName).arg(lastName)
                    color:               "black"
                    font.pointSize:      16
                    font.family:         "Helvetica"
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment:   Text.AlignVCenter
                    wrapMode:            Text.Wrap
                    fontSizeMode:        Text.Fit
                    minimumPointSize:    8
                }

                Switch {
                    id:                     trustedSwitch
                    anchors.verticalCenter: parent.verticalCenter
                    checked:                trusted

                    onToggled: {
                        if (!friendDelegate.listView.setTrust(index, checked)) {
                            checked = !checked;
                        }
                    }
                }
            }
        }

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AlwaysOn
        }

        property int trustedFriendsCount: 0

        function setTrust(index, trusted) {
            if (trustedFriendsCount < VKHelper.maxTrustedFriendsCount || !trusted) {
                var frnd_update = { "trusted": trusted };

                trustedFriendsListModel.set(index, frnd_update);

                if (trusted) {
                    trustedFriendsCount++;
                } else {
                    trustedFriendsCount--;
                }

                return true;
            } else {
                return false;
            }
        }

        Component.onCompleted: {
            trustedFriendsListModel.clear();

            var friends_list = VKHelper.getFriends();

            for (var i = 0; i < friends_list.length; i++) {
                trustedFriendsListModel.append(friends_list[i]);

                if (typeof friends_list[i].trusted !== "undefined" && friends_list[i].trusted) {
                    trustedFriendsCount++;
                }
            }
        }
    }
}
