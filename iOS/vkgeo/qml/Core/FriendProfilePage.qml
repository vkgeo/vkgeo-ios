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
                text:                qsTr("Friend Profile")
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

    property int safeAreaTopMargin:    0
    property int safeAreaBottomMargin: 0

    StackView.onStatusChanged: {
        if (StackView.status === StackView.Activating ||
            StackView.status === StackView.Active) {
            safeAreaTopMargin    = UIHelper.safeAreaTopMargin();
            safeAreaBottomMargin = UIHelper.safeAreaBottomMargin();
        }
    }
}
