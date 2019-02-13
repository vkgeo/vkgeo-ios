import QtQuick 2.12
import QtQuick.Controls 2.5
import QtPositioning 5.12
import VKHelper 1.0

import "Main"

import "../Util.js" as UtilScript

Page {
    id: mainPage

    header: Rectangle {
        height: Math.max(mainPage.safeAreaTopMargin, mainPage.bannerViewHeight)
        color:  "lightsteelblue"
    }

    footer: Rectangle {
        height: mainPage.safeAreaBottomMargin + tabBar.height
        color:  "lightsteelblue"

        TabBar {
            id:            tabBar
            anchors.top:   parent.top
            anchors.left:  parent.left
            anchors.right: parent.right
            contentHeight: Math.max(Math.max(mapTabButton.implicitHeight, peopleTabButton.implicitHeight),
                                    settingsTabButton.implicitHeight)

            background: Rectangle {
                color: "transparent"
            }

            TabButton {
                id:             mapTabButton
                implicitHeight: UtilScript.pt(48)

                background: Rectangle {
                    color: tabBar.currentIndex === 0 ? "steelblue" : "lightsteelblue"
                }

                contentItem: Image {
                    source:   "qrc:/resources/images/main/tab_map.png"
                    fillMode: Image.PreserveAspectFit
                }
            }

            TabButton {
                id:             peopleTabButton
                implicitHeight: UtilScript.pt(48)

                background: Rectangle {
                    color: tabBar.currentIndex === 1 ? "steelblue" : "lightsteelblue"
                }

                contentItem: Image {
                    source:   "qrc:/resources/images/main/tab_people.png"
                    fillMode: Image.PreserveAspectFit
                }
            }

            TabButton {
                id:             settingsTabButton
                implicitHeight: UtilScript.pt(48)

                background: Rectangle {
                    color: tabBar.currentIndex === 2 ? "steelblue" : "lightsteelblue"
                }

                contentItem: Image {
                    source:   "qrc:/resources/images/main/tab_settings.png"
                    fillMode: Image.PreserveAspectFit
                }
            }
        }
    }

    property bool appInForeground:     Qt.application.active

    property int safeAreaTopMargin:    0
    property int safeAreaBottomMargin: 0
    property int bannerViewHeight:     AdMobHelper.bannerViewHeight
    property int vkAuthState:          VKHelper.authState

    onAppInForegroundChanged: {
        if (appInForeground) {
            positionSource.active = true;
            updateTimer.running   = true;
        } else {
            positionSource.active = false;
            updateTimer.running   = false;
        }
    }

    onVkAuthStateChanged: {
        if (vkAuthState === VKAuthState.StateNotAuthorized) {
            NotificationHelper.showNotification("NOT_LOGGED_IN_NOTIFICATION", qsTr("You are not logged into your VK account"),
                                                                              qsTr("Tap to open the application"));
        } else if (vkAuthState === VKAuthState.StateAuthorized) {
            NotificationHelper.hideNotification("NOT_LOGGED_IN_NOTIFICATION");

            VKHelper.updateFriends();
        }
    }

    StackView.onStatusChanged: {
        if (StackView.status === StackView.Activating ||
            StackView.status === StackView.Active) {
            safeAreaTopMargin    = UIHelper.getSafeAreaTopMargin();
            safeAreaBottomMargin = UIHelper.getSafeAreaBottomMargin();
        }
    }

    function updateTrackedFriendsData() {
        VKHelper.updateTrackedFriendsData(true);
    }

    SwipeView {
        anchors.fill: parent
        currentIndex: tabBar.currentIndex
        interactive:  false

        MapSwipe {
            id: mapSwipe

            onOpenProfilePage: {
                friendsSwipe.openProfilePage(user_id);
            }
        }

        FriendsSwipe {
            id: friendsSwipe

            onLocateFriendOnMap: {
                mapSwipe.locateItemOnMap(user_id);

                tabBar.setCurrentIndex(0);
            }
        }

        SettingsSwipe {
            id: settingsSwipe
        }
    }

    PositionSource {
        id:                          positionSource
        updateInterval:              1000
        preferredPositioningMethods: PositionSource.AllPositioningMethods

        onPositionChanged: {
            if (position.latitudeValid && position.longitudeValid) {
                VKHelper.updateLocation(position.coordinate.latitude,
                                        position.coordinate.longitude);

                VKHelper.updateBatteryStatus(BatteryHelper.getBatteryStatus(),
                                             BatteryHelper.getBatteryLevel());
            }
        }
    }

    Timer {
        id:       updateTimer
        interval: 1000
        repeat:   true

        onTriggered: {
            VKHelper.updateTrackedFriendsData(false);

            mapSwipe.updateMapItemsStates();
        }
    }

    Component.onCompleted: {
        VKHelper.dataSent.connect(updateTrackedFriendsData);
        VKHelper.friendsUpdated.connect(updateTrackedFriendsData);
    }
}
