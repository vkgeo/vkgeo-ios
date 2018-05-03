import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import "../Util.js" as UtilScript

Page {
    id: friendProfilePage

    header: Rectangle {
        height: friendProfilePage.safeAreaTopMargin + headerControlsLayout.height
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
                color:             "transparent"
                Layout.leftMargin: UtilScript.pt(8)
                Layout.fillHeight: true
                Layout.alignment:  Qt.AlignHCenter
            }

            Text {
                text:                qsTr("Friend profile")
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
    }

    footer: Rectangle {
        height: friendProfilePage.safeAreaBottomMargin
        color:  "lightsteelblue"
    }

    property bool online:              false

    property int safeAreaTopMargin:    0
    property int safeAreaBottomMargin: 0

    property string userId:            ""
    property string firstName:         ""
    property string lastName:          ""
    property string bigPhotoUrl:       ""
    property string status:            ""

    StackView.onStatusChanged: {
        if (StackView.status === StackView.Activating ||
            StackView.status === StackView.Active) {
            safeAreaTopMargin    = UIHelper.safeAreaTopMargin();
            safeAreaBottomMargin = UIHelper.safeAreaBottomMargin();
        }
    }

    Flickable {
        id:                   profileFlickable
        anchors.fill:         parent
        anchors.topMargin:    UtilScript.pt(16)
        anchors.bottomMargin: UtilScript.pt(16)
        contentWidth:         profileLayout.width
        contentHeight:        profileLayout.height
        clip:                 true

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }

        ColumnLayout {
            id:      profileLayout
            width:   profileFlickable.width
            spacing: UtilScript.pt(32)

            Rectangle {
                width:            UtilScript.pt(128)
                height:           UtilScript.pt(128)
                color:            "transparent"
                Layout.topMargin: UtilScript.pt(16)
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                OpacityMask {
                    id:           opacityMask
                    anchors.fill: parent

                    source: Image {
                        width:    opacityMask.width
                        height:   opacityMask.height
                        source:   friendProfilePage.bigPhotoUrl
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
                    x:        opacityMask.width  / 2 + opacityMask.width  / 2 * Math.sin(angle) - width  / 2
                    y:        opacityMask.height / 2 + opacityMask.height / 2 * Math.cos(angle) - height / 2
                    z:        1
                    width:    UtilScript.pt(16)
                    height:   UtilScript.pt(16)
                    source:   "qrc:/resources/images/main/avatar_online_label.png"
                    fillMode: Image.PreserveAspectFit
                    visible:  friendProfilePage.online

                    property real angle: Math.PI / 4
                }
            }

            Text {
                leftPadding:         UtilScript.pt(16)
                rightPadding:        UtilScript.pt(16)
                text:                "%1 %2".arg(friendProfilePage.firstName).arg(friendProfilePage.lastName)
                color:               "black"
                font.pointSize:      24
                font.family:         "Helvetica"
                font.bold:           true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment:   Text.AlignVCenter
                wrapMode:            Text.Wrap
                fontSizeMode:        Text.Fit
                minimumPointSize:    8
                Layout.fillWidth:    true
            }

            Text {
                leftPadding:         UtilScript.pt(16)
                rightPadding:        UtilScript.pt(16)
                text:                friendProfilePage.status
                color:               "black"
                font.pointSize:      16
                font.family:         "Helvetica"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment:   Text.AlignVCenter
                wrapMode:            Text.Wrap
                fontSizeMode:        Text.Fit
                minimumPointSize:    8
                Layout.fillWidth:    true
            }

            Rectangle {
                width:            UtilScript.pt(280)
                height:           UtilScript.pt(64)
                color:            "steelblue"
                radius:           UtilScript.pt(8)
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                Text {
                    anchors.fill:        parent
                    text:                qsTr("Open full profile")
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
                        if (!Qt.openUrlExternally("vk://vk.com/id%1".arg(friendProfilePage.userId))) {
                            Qt.openUrlExternally("https://m.vk.com/id%1".arg(friendProfilePage.userId));
                        }
                    }
                }
            }
        }
    }
}
