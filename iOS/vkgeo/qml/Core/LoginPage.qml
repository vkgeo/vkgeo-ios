import QtQuick 2.9
import QtQuick.Controls 2.2
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
        id:           backgroundRectangle
        anchors.fill: parent
        color:        "lightsteelblue"

        Column {
            anchors.centerIn: parent
            spacing:          UtilScript.pt(32)

            Text {
                width:               backgroundRectangle.width - UtilScript.pt(32)
                text:                qsTr("Sign in with your VK account")
                color:               "white"
                font.pointSize:      32
                font.family:         "Helvetica"
                font.bold:           true
                horizontalAlignment: Text.AlignHCenter
                wrapMode:            Text.Wrap
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                width:                    UtilScript.pt(280)
                height:                   UtilScript.pt(140)

                background: Rectangle {
                    color: "transparent"
                }

                contentItem: Image {
                    source:   "qrc:/resources/images/login/button_login.png"
                    fillMode: Image.PreserveAspectFit
                }

                onClicked: {
                    VKHelper.login();
                }
            }
        }
    }
}
