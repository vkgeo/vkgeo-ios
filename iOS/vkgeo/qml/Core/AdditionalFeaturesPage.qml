import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtPurchasing 1.0

import "Misc"

import "../Util.js" as UtilScript

Page {
    id: additionalFeaturesPage

    header: Rectangle {
        height: additionalFeaturesPage.bannerViewHeight + additionalFeaturesPage.safeAreaTopMargin +
                                                          headerControlsLayout.height
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
                text:                qsTr("Additional features")
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

            VKButton {
                width:              UtilScript.pt(80)
                height:             UtilScript.pt(32)
                text:               qsTr("Close")
                Layout.rightMargin: UtilScript.pt(8)
                Layout.alignment:   Qt.AlignHCenter | Qt.AlignVCenter

                onClicked: {
                    mainStackView.pop();
                }
            }
        }
    }

    footer: Rectangle {
        height: additionalFeaturesPage.safeAreaBottomMargin
        color:  "lightsteelblue"
    }

    property int bannerViewHeight:     AdMobHelper.bannerViewHeight
    property int safeAreaTopMargin:    0
    property int safeAreaBottomMargin: 0

    StackView.onStatusChanged: {
        if (StackView.status === StackView.Activating ||
            StackView.status === StackView.Active) {
            safeAreaTopMargin    = UIHelper.safeAreaTopMargin();
            safeAreaBottomMargin = UIHelper.safeAreaBottomMargin();
        }
    }

    function getPrice(status, price) {
        if (status === Product.Registered) {
            var result = /([\d \.,]+)/.exec(price);

            if (Array.isArray(result) && result.length > 1) {
                return result[1].trim();
            } else {
                return qsTr("BUY");
            }
        } else {
            return qsTr("BUY");
        }
    }

    Store {
        id: store

        Product {
            id:         trackedFriendsProduct
            identifier: "vkgeo.unlockable.trackedfriends"
            type:       Product.Unlockable

            onPurchaseSucceeded: {
                mainWindow.disableAds           = true;
                mainWindow.enableTrackedFriends = true;

                transaction.finalize();
            }

            onPurchaseRestored: {
                mainWindow.disableAds           = true;
                mainWindow.enableTrackedFriends = true;

                transaction.finalize();
            }

            onPurchaseFailed: {
                if (transaction.failureReason === Transaction.ErrorOccurred) {
                    console.log(transaction.errorString);
                }

                transaction.finalize();
            }
        }

        Product {
            id:         increasedLimitsProduct
            identifier: "vkgeo.unlockable.increasedlimits"
            type:       Product.Unlockable

            onPurchaseSucceeded: {
                mainWindow.disableAds             = true;
                mainWindow.increaseTrackingLimits = true;

                transaction.finalize();
            }

            onPurchaseRestored: {
                mainWindow.disableAds             = true;
                mainWindow.increaseTrackingLimits = true;

                transaction.finalize();
            }

            onPurchaseFailed: {
                if (transaction.failureReason === Transaction.ErrorOccurred) {
                    console.log(transaction.errorString);
                }

                transaction.finalize();
            }
        }
    }

    Flickable {
        id:                   featuresFlickable
        anchors.fill:         parent
        anchors.topMargin:    UtilScript.pt(16)
        anchors.bottomMargin: UtilScript.pt(16)
        contentWidth:         featuresLayout.width
        contentHeight:        featuresLayout.height
        clip:                 true

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AlwaysOn
        }

        ColumnLayout {
            id:      featuresLayout
            width:   featuresFlickable.width
            spacing: UtilScript.pt(16)

            Rectangle {
                height:             UtilScript.pt(64)
                color:              "lightsteelblue"
                radius:             UtilScript.pt(8)
                visible:            !mainWindow.enableTrackedFriends
                Layout.leftMargin:  UtilScript.pt(16)
                Layout.rightMargin: UtilScript.pt(16)
                Layout.fillWidth:   true
                Layout.alignment:   Qt.AlignVCenter

                RowLayout {
                    anchors.fill:    parent
                    anchors.margins: UtilScript.pt(16)
                    spacing:         UtilScript.pt(4)

                    Text {
                        text:                qsTr("Tracked friends")
                        color:               "white"
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

                    VKButton {
                        width:            UtilScript.pt(80)
                        height:           UtilScript.pt(32)
                        text:             additionalFeaturesPage.getPrice(trackedFriendsProduct.status,
                                                                          trackedFriendsProduct.price)
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                        onClicked: {
                            trackedFriendsProduct.purchase();
                        }
                    }
                }
            }

            Rectangle {
                height:             UtilScript.pt(64)
                color:              "lightsteelblue"
                radius:             UtilScript.pt(8)
                visible:            !mainWindow.increaseTrackingLimits
                Layout.leftMargin:  UtilScript.pt(16)
                Layout.rightMargin: UtilScript.pt(16)
                Layout.fillWidth:   true
                Layout.alignment:   Qt.AlignVCenter

                RowLayout {
                    anchors.fill:    parent
                    anchors.margins: UtilScript.pt(16)
                    spacing:         UtilScript.pt(4)

                    Text {
                        text:                qsTr("Tracking limits x 3")
                        color:               "white"
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

                    VKButton {
                        width:            UtilScript.pt(80)
                        height:           UtilScript.pt(32)
                        text:             additionalFeaturesPage.getPrice(increasedLimitsProduct.status,
                                                                          increasedLimitsProduct.price)
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                        onClicked: {
                            increasedLimitsProduct.purchase();
                        }
                    }
                }
            }

            Rectangle {
                height:             UtilScript.pt(64)
                color:              "lightsteelblue"
                radius:             UtilScript.pt(8)
                Layout.leftMargin:  UtilScript.pt(16)
                Layout.rightMargin: UtilScript.pt(16)
                Layout.fillWidth:   true
                Layout.alignment:   Qt.AlignVCenter

                RowLayout {
                    anchors.fill:    parent
                    anchors.margins: UtilScript.pt(16)
                    spacing:         UtilScript.pt(4)

                    Text {
                        text:                qsTr("Restore purchases")
                        color:               "white"
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

                    VKButton {
                        width:            UtilScript.pt(80)
                        height:           UtilScript.pt(32)
                        text:             qsTr("OK")
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                        onClicked: {
                            store.restorePurchases();
                        }
                    }
                }
            }
        }
    }
}
