import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import VKHelper 1.0

import "../Util.js" as UtilScript

Page {
    id:         loginPage
    objectName: "loginPage"

    property int vkAuthState: VKHelper.authState

    onVkAuthStateChanged: {
        if (vkAuthState === VKAuthState.StateAuthorized) {
            mainWindow.closeLoginPage();
        }
    }

    Rectangle {
        anchors.fill: parent
        color:        "lightsteelblue"

        ColumnLayout {
            anchors.fill: parent
            spacing:      UtilScript.pt(32)

            Rectangle {
                color:             "transparent"
                Layout.fillWidth:  true
                Layout.fillHeight: true
            }

            Text {
                leftPadding:          UtilScript.pt(16)
                rightPadding:         UtilScript.pt(16)
                text:                 qsTr("Sign in with your VK account")
                color:                "white"
                font.pointSize:       32
                font.family:          "Helvetica"
                font.bold:            true
                horizontalAlignment:  Text.AlignHCenter
                wrapMode:             Text.Wrap
                fontSizeMode:         Text.Fit
                minimumPointSize:     8
                Layout.maximumHeight: parent.height / 2
                Layout.fillWidth:     true
                Layout.alignment:     Qt.AlignVCenter
            }

            Image {
                width:            UtilScript.pt(280)
                height:           UtilScript.pt(140)
                source:           "qrc:/resources/images/login/button_login.png"
                fillMode:         Image.PreserveAspectFit
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        VKHelper.login();
                    }
                }
            }

            Rectangle {
                color:             "transparent"
                Layout.fillWidth:  true
                Layout.fillHeight: true
            }
        }
    }
}
