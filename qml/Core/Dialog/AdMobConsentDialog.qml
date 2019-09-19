import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12

import "../Misc"

import "../../Util.js" as UtilScript

Popup {
    id:               adMobConsentDialog
    anchors.centerIn: Overlay.overlay
    padding:          UtilScript.pt(UIHelper.screenDpi, 8)
    modal:            true
    closePolicy:      Popup.NoAutoClose

    signal personalizedAdsSelected()
    signal nonPersonalizedAdsSelected()

    background: Rectangle {
        color:        UIHelper.darkTheme ? "black" : "white"
        radius:       UtilScript.pt(UIHelper.screenDpi, 8)
        border.width: UtilScript.pt(UIHelper.screenDpi, 2)
        border.color: "steelblue"
    }

    contentItem: Rectangle {
        implicitWidth:  UtilScript.pt(UIHelper.screenDpi, 300)
        implicitHeight: UtilScript.pt(UIHelper.screenDpi, 300)
        color:          "transparent"

        ColumnLayout {
            anchors.fill: parent
            spacing:      UtilScript.pt(UIHelper.screenDpi, 8)

            Text {
                text:                qsTr("We keep this app free by showing ads. Ad network will <a href=\"https://policies.google.com/technologies/ads\">collect data and use a unique identifier on your device</a> to show you ads. <b>Do you allow to use your data to tailor ads for you?</b>")
                color:               UIHelper.darkTheme ? "white"     : "black"
                linkColor:           UIHelper.darkTheme ? "lightblue" : "blue"
                font.pointSize:      16
                font.family:         "Helvetica"
                horizontalAlignment: Text.AlignJustify
                verticalAlignment:   Text.AlignVCenter
                wrapMode:            Text.Wrap
                fontSizeMode:        Text.Fit
                minimumPointSize:    8
                textFormat:          Text.StyledText
                Layout.fillWidth:    true
                Layout.fillHeight:   true

                onLinkActivated: {
                    Qt.openUrlExternally(link);
                }
            }

            VKButton {
                implicitWidth:    UtilScript.pt(UIHelper.screenDpi, 280)
                implicitHeight:   UtilScript.pt(UIHelper.screenDpi, 64)
                text:             qsTr("Yes, show me relevant ads")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                onClicked: {
                    adMobConsentDialog.personalizedAdsSelected();
                    adMobConsentDialog.close();
                }
            }

            VKButton {
                implicitWidth:    UtilScript.pt(UIHelper.screenDpi, 280)
                implicitHeight:   UtilScript.pt(UIHelper.screenDpi, 64)
                text:             qsTr("No, show me ads that are less relevant")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                onClicked: {
                    adMobConsentDialog.nonPersonalizedAdsSelected();
                    adMobConsentDialog.close();
                }
            }
        }
    }
}
