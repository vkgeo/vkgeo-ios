import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0

import "Misc"

import "../Util.js" as UtilScript

Page {
    id: trackedFriendsPage

    header: PageHeader {
        bannerViewHeight: trackedFriendsPage.bannerViewHeight
        text:             qsTr("Tracked friends")

        onBack: {
            mainStackView.pop();
        }

        onDone: {
            var tracked_friends_list = [];

            for (var i = 0; i < trackedFriendsPage.friendsList.length; i++) {
                var frnd = trackedFriendsPage.friendsList[i];

                if (frnd.tracked) {
                    tracked_friends_list.push(frnd.userId);
                }
            }

            VKHelper.updateTrackedFriendsList(tracked_friends_list);

            mainStackView.pop();
        }
    }

    background: Rectangle {
        color: UIHelper.darkTheme ? "black" : "white"
    }

    readonly property int bannerViewHeight: AdMobHelper.bannerViewHeight

    property int trackedFriendsCount:       0

    property var friendsList:               []

    function updateModel() {
        trackedFriendsListModel.clear();

        for (var i = 0; i < friendsList.length; i++) {
            var frnd = friendsList[i];

            if ("%1 %2".arg(frnd.firstName).arg(frnd.lastName).toUpperCase()
                       .includes(filterTextField.filterText.toUpperCase())) {
                trackedFriendsListModel.append(frnd);
            }
        }
    }

    function setTrack(user_id, tracked) {
        if (trackedFriendsCount < VKHelper.maxTrackedFriendsCount || !tracked) {
            for (var i = 0; i < friendsList.length; i++) {
                var frnd = friendsList[i];

                if (user_id === frnd.userId) {
                    frnd.tracked = tracked;

                    friendsList[i] = frnd;

                    break;
                }
            }

            for (var j = 0; j < trackedFriendsListModel.count; j++) {
                var model_frnd = trackedFriendsListModel.get(j);

                if (user_id === model_frnd.userId) {
                    trackedFriendsListModel.set(j, {"tracked": tracked});

                    break;
                }
            }

            if (tracked) {
                trackedFriendsCount++;
            } else {
                trackedFriendsCount--;
            }

            return true;
        } else {
            return false;
        }
    }

    ColumnLayout {
        anchors.fill:      parent
        anchors.topMargin: UtilScript.pt(4)
        spacing:           UtilScript.pt(4)

        FilterTextField {
            id:               filterTextField
            placeholderText:  qsTr("Quick search")
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            onFilterTextChanged: {
                trackedFriendsPage.updateModel();
            }
        }

        ListView {
            orientation:       ListView.Vertical
            clip:              true
            Layout.fillWidth:  true
            Layout.fillHeight: true

            model: ListModel {
                id: trackedFriendsListModel
            }

            delegate: Rectangle {
                id:           friendDelegate
                width:        listView.width
                height:       UtilScript.pt(80)
                color:        "transparent"
                clip:         true
                border.width: UtilScript.pt(1)
                border.color: UIHelper.darkTheme ? "midnightblue" : "deepskyblue"

                readonly property var listView: ListView.view

                RowLayout {
                    anchors.fill:        parent
                    anchors.leftMargin:  UtilScript.pt(16)
                    anchors.rightMargin: UtilScript.pt(16)
                    spacing:             UtilScript.pt(8)

                    OpacityMask {
                        id:               opacityMask
                        width:            UtilScript.pt(64)
                        height:           UtilScript.pt(64)
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                        source: Image {
                            width:    opacityMask.width
                            height:   opacityMask.height
                            source:   photoUrl
                            fillMode: Image.PreserveAspectCrop
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
                        text:                "%1 %2".arg(firstName).arg(lastName)
                        color:               UIHelper.darkTheme ? "white" : "black"
                        font.pointSize:      16
                        font.family:         "Helvetica"
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment:   Text.AlignVCenter
                        wrapMode:            Text.Wrap
                        fontSizeMode:        Text.Fit
                        minimumPointSize:    8
                        textFormat:          Text.PlainText
                        Layout.fillWidth:    true
                        Layout.fillHeight:   true
                    }

                    Switch {
                        checked:          tracked
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                        onToggled: {
                            if (!friendDelegate.listView.setTrack(userId, checked)) {
                                checked = !checked;
                            }
                        }
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AlwaysOn
            }

            function setTrack(user_id, tracked) {
                return trackedFriendsPage.setTrack(user_id, tracked);
            }
        }
    }

    Component.onCompleted: {
        var friends_list = VKHelper.getFriendsList();

        for (var i = 0; i < friends_list.length; i++) {
            var frnd = friends_list[i];

            if (!frnd.trusted) {
                friendsList.push(frnd);

                if (frnd.tracked) {
                    trackedFriendsCount++;
                }
            }
        }

        updateModel();
    }
}
