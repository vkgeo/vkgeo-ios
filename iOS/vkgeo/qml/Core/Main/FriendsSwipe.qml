import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

import "../../Util.js" as UtilScript

Item {
    id: friendsSwipe

    signal locateFriendOnMap(string id)

    function updateFriends() {
        friendsListModel.clear();

        var friends_list = VKHelper.getFriendsList();

        for (var i = 0; i < friends_list.length; i++) {
            friendsListModel.append(friends_list[i]);

            friendsListModel.set(i, { "locationAvailable": false, "updateTime": 0, "latitude": 0, "longitude": 0 });
        }
    }

    function trustedFriendLocationAvailable(id, update_time, latitude, longitude) {
        for (var i = 0; i < friendsListModel.count; i++) {
            var frnd = friendsListModel.get(i);

            if (id === frnd.id) {
                friendsListModel.set(i, { "locationAvailable": true, "updateTime": update_time,
                                          "latitude": latitude, "longitude": longitude });

                break;
            }
        }
    }

    Image {
        id:                       refreshImage
        anchors.top:              parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width:                    UtilScript.pt(64)
        height:                   UtilScript.pt(64)
        source:                   "qrc:/resources/images/main/refresh.png"
        fillMode:                 Image.PreserveAspectFit
        visible:                  false

        PropertyAnimation {
            target:   refreshImage
            property: "rotation"
            from:     0
            to:       360
            duration: 500
            loops:    Animation.Infinite
            running:  refreshImage.visible
        }
    }

    ListView {
        id:           friendsListView
        anchors.fill: parent
        z:            1
        orientation:  ListView.Vertical

        model: ListModel {
            id: friendsListModel
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
                leftPadding:  UtilScript.pt(16)
                rightPadding: UtilScript.pt(16)
                spacing:      UtilScript.pt(8)

                Rectangle {
                    id:                     avatarRectangle
                    anchors.verticalCenter: parent.verticalCenter
                    width:                  UtilScript.pt(64)
                    height:                 UtilScript.pt(64)
                    color:                  "transparent"

                    OpacityMask {
                        id:           opacityMask
                        anchors.fill: parent

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

                    Image {
                        id:       onlineImage
                        x:        opacityMask.width  / 2 + opacityMask.width  / 2 * Math.sin(angle) - width  / 2
                        y:        opacityMask.height / 2 + opacityMask.height / 2 * Math.cos(angle) - height / 2
                        z:        1
                        width:    UtilScript.pt(16)
                        height:   UtilScript.pt(16)
                        source:   "qrc:/resources/images/main/avatar_online_label.png"
                        fillMode: Image.PreserveAspectFit
                        visible:  online

                        property real angle: Math.PI / 4
                    }
                }

                Text {
                    width:               parent.width - parent.spacing * 2
                                                      - parent.leftPadding
                                                      - parent.rightPadding
                                                      - avatarRectangle.width
                                                      - showOnMapButton.width
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

                Image {
                    id:                     showOnMapButton
                    anchors.verticalCenter: parent.verticalCenter
                    width:                  UtilScript.pt(48)
                    height:                 UtilScript.pt(48)
                    source:                 buttonToShow(trusted, locationAvailable)
                    fillMode:               Image.PreserveAspectFit

                    function buttonToShow(trusted, location_available) {
                        if (trusted) {
                            if (location_available) {
                                return "qrc:/resources/images/main/button_show_on_map.png";
                            } else {
                                return "qrc:/resources/images/main/button_invite_trusted.png";
                            }
                        } else {
                            return "qrc:/resources/images/main/button_invite_untrusted.png";
                        }
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            if (trusted && locationAvailable) {
                                friendDelegate.listView.locateFriendOnMap(id);
                            } else {
                                // Invite
                            }
                        }
                    }
                }
            }
        }

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AlwaysOn
        }

        property bool refreshStarted: false

        onContentYChanged: {
            if (contentY < 0 - refreshImage.height) {
                if (!refreshStarted) {
                    refreshStarted = true;

                    refreshTimer.start();
                }
            } else {
                refreshImage.visible = false;

                refreshStarted = false;

                refreshTimer.stop();
            }
        }

        function locateFriendOnMap(id) {
            friendsSwipe.locateFriendOnMap(id);
        }

        Timer {
            id:       refreshTimer
            interval: 500

            onTriggered: {
                refreshImage.visible = true;

                VKHelper.updateFriends();
            }
        }
    }

    Component.onCompleted: {
        VKHelper.friendsUpdated.connect(updateFriends);
        VKHelper.trustedFriendLocationUpdated.connect(trustedFriendLocationAvailable);
    }
}
