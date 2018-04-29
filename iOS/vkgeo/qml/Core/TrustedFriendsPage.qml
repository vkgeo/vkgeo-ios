import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

import "../Util.js" as UtilScript

Page {
    id: trustedFriendsPage

    header: Rectangle {
        height: UtilScript.pt(48)
        color:  "lightsteelblue"

        Text {
            anchors.centerIn:    parent
            width:               parent.width - UtilScript.pt(8)
                                              - closeButton.width * 2
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
            id:                     closeButton
            anchors.right:          parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin:    UtilScript.pt(8)
            width:                  UtilScript.pt(80)
            height:                 UtilScript.pt(32)
            color:                  "steelblue"
            radius:                 UtilScript.pt(8)

            Text {
                anchors.fill:        parent
                text:                qsTr("Close")
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
    }

    ListView {
        anchors.fill: parent
        orientation:  ListView.Vertical

        model: ListModel {
            id: trustedFriendsListModel
        }

        delegate: Rectangle {
            width:        ListView.view.width
            height:       UtilScript.pt(80)
            clip:         true
            border.width: UtilScript.pt(1)
            border.color: "lightsteelblue"

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
                }
            }
        }

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AlwaysOn
        }
    }

    Component.onCompleted: {
        trustedFriendsListModel.clear();

        var friends_list = VKHelper.getFriends();

        for (var i = 0; i < friends_list.length; i++) {
            trustedFriendsListModel.append(friends_list[i]);
        }
    }
}
