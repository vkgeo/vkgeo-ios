import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import "../Util.js" as UtilScript

Page {
    id: trustedFriendsPage

    header: Rectangle {
        height: trustedFriendsPage.safeAreaTopMargin + headerControlsLayout.height
        color:  "lightsteelblue"

        RowLayout {
            id:             headerControlsLayout
            anchors.bottom: parent.bottom
            anchors.left:   parent.left
            anchors.right:  parent.right
            height:         UtilScript.pt(48)
            spacing:        UtilScript.pt(4)

            Rectangle {
                width:             UtilScript.pt(80)
                height:            UtilScript.pt(32)
                color:             "steelblue"
                radius:            UtilScript.pt(8)
                Layout.leftMargin: UtilScript.pt(8)
                Layout.alignment:  Qt.AlignHCenter | Qt.AlignVCenter

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
                text:                qsTr("Trusted friends")
                color:               "white"
                font.pointSize:      16
                font.family:         "Helvetica"
                font.bold:           true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment:   Text.AlignVCenter
                wrapMode:            Text.Wrap
                fontSizeMode:        Text.Fit
                minimumPointSize:    8
                Layout.fillWidth:    true
                Layout.fillHeight:   true
            }

            Rectangle {
                width:              UtilScript.pt(80)
                height:             UtilScript.pt(32)
                color:              "steelblue"
                radius:             UtilScript.pt(8)
                Layout.rightMargin: UtilScript.pt(8)
                Layout.alignment:   Qt.AlignHCenter | Qt.AlignVCenter

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

                        for (var i = 0; i < trustedFriendsPage.friendsList.length; i++) {
                            var frnd = trustedFriendsPage.friendsList[i];

                            if (frnd.trusted) {
                                trusted_friends_list.push(frnd.userId);
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
    property int trustedFriendsCount:  0

    property var friendsList:          []

    StackView.onStatusChanged: {
        if (StackView.status === StackView.Activating ||
            StackView.status === StackView.Active) {
            safeAreaTopMargin    = UIHelper.safeAreaTopMargin();
            safeAreaBottomMargin = UIHelper.safeAreaBottomMargin();
        }
    }

    function updateModel() {
        trustedFriendsListModel.clear();

        for (var i = 0; i < friendsList.length; i++) {
            var frnd = friendsList[i];

            if ("%1 %2".arg(frnd.firstName).arg(frnd.lastName).toUpperCase()
                       .includes(filterTextField.text.toUpperCase())) {
                trustedFriendsListModel.append(frnd);
            }
        }
    }

    function setTrust(user_id, trusted) {
        if (trustedFriendsCount < VKHelper.maxTrustedFriendsCount || !trusted) {
            for (var i = 0; i < friendsList.length; i++) {
                var frnd = friendsList[i];

                if (user_id === frnd.userId) {
                    frnd.trusted = trusted;

                    friendsList[i] = frnd;

                    break;
                }
            }

            for (var j = 0; j < trustedFriendsListModel.count; j++) {
                var model_frnd = trustedFriendsListModel.get(j);

                if (user_id === model_frnd.userId) {
                    trustedFriendsListModel.set(j, { "trusted": trusted });

                    break;
                }
            }

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

    ColumnLayout {
        anchors.fill: parent
        spacing:      UtilScript.pt(8)

        TextField {
            id:               filterTextField
            placeholderText:  qsTr("Quick search")
            inputMethodHints: Qt.ImhNoPredictiveText
            Layout.topMargin: UtilScript.pt(8)
            Layout.fillWidth: true

            background: Rectangle {
                color:  "lightsteelblue"
                radius: UtilScript.pt(8)
            }

            onTextChanged: {
                trustedFriendsPage.updateModel();
            }

            onEditingFinished: {
                focus = false;
            }
        }

        ListView {
            orientation:       ListView.Vertical
            clip:              true
            Layout.fillWidth:  true
            Layout.fillHeight: true

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

                RowLayout {
                    anchors.fill: parent
                    spacing:      UtilScript.pt(8)

                    OpacityMask {
                        id:                opacityMask
                        width:             UtilScript.pt(64)
                        height:            UtilScript.pt(64)
                        Layout.leftMargin: UtilScript.pt(16)
                        Layout.alignment:  Qt.AlignHCenter | Qt.AlignVCenter

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
                        text:                "%1 %2".arg(firstName).arg(lastName)
                        color:               "black"
                        font.pointSize:      16
                        font.family:         "Helvetica"
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment:   Text.AlignVCenter
                        wrapMode:            Text.Wrap
                        fontSizeMode:        Text.Fit
                        minimumPointSize:    8
                        Layout.fillWidth:    true
                        Layout.fillHeight:   true
                    }

                    Switch {
                        checked:            trusted
                        Layout.rightMargin: UtilScript.pt(16)
                        Layout.alignment:   Qt.AlignHCenter | Qt.AlignVCenter

                        onToggled: {
                            if (!friendDelegate.listView.setTrust(userId, checked)) {
                                checked = !checked;
                            }
                        }
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AlwaysOn
            }

            function setTrust(user_id, trusted) {
                return trustedFriendsPage.setTrust(user_id, trusted);
            }
        }
    }

    Component.onCompleted: {
        friendsList = VKHelper.getFriendsList();

        for (var i = 0; i < friendsList.length; i++) {
            var frnd = friendsList[i];

            if (frnd.trusted) {
                trustedFriendsCount++;
            }
        }

        updateModel();
    }
}
